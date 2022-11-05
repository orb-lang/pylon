# Modules

This module is responsible for:


-  Building the `bridge.modules` database if it doesn't already exist


-  Containing `br import`, so that our self\-contained binary can populate the
    `bridge.modules` database from an included `.bundle` file\.


##### do guard

As is standard for our directly\-loaded code, we wrap in a `do` block, to
imitate the behavior of a module\.

```lua
do
```


### Sentinel

If we create a new `bridge.modules` this is set to `true`\.

```lua
local new_modules = false
```


## SQL for bridge\.modules

\#Todo
      into genuine SQL blocks\.

\#Todo


```lua
local stmts = {}
```


### CREATE

These SQL statements create the bridge\.modules database\.

Currently, we have no migrations\.  When we do, they will follow the pattern
[established in helm](https://gitlab.com/special-circumstance/helm/-/blob/trunk/doc/md/helm/historian.md)\.


#### create\_project\_table

```sql
CREATE TABLE IF NOT EXISTS project (
   project_id INTEGER PRIMARY KEY,
   name STRING UNIQUE NOT NULL ON CONFLICT IGNORE,
   repo STRING,
   repo_type STRING DEFAULT 'git',
   repo_alternates STRING,
   home STRING,
   website STRING
);
```


#### create\_version\_table

```sql
CREATE TABLE IF NOT EXISTS version (
   version_id INTEGER PRIMARY KEY,
   stage STRING DEFAULT 'SNAPSHOT' COLLATE NOCASE,
   edition STRING default '',
   special STRING DEFAULT 'no' COLLATE NOCASE,
   major INTEGER DEFAULT 0,
   minor INTEGER DEFAULT 0,
   patch INTEGER DEFAULT 0,
   project INTEGER NOT NULL,
   UNIQUE (project, stage, edition, special, major, minor, patch)
      ON CONFLICT IGNORE,
   FOREIGN KEY (project)
      REFERENCES project (project_id)
);
```


#### create\_bundle\_table

```sql
CREATE TABLE IF NOT EXISTS bundle (
   bundle_id INTEGER PRIMARY KEY,
   time DATETIME DEFAULT CURRENT_TIMESTAMP,
   project INTEGER NOT NULL,
   version INTEGER NOT NULL,
   FOREIGN KEY (project)
      REFERENCES project (project_id)
   FOREIGN KEY (version)
      REFERENCES version (version_id)
);
```


#### create\_code\_table

```sql
CREATE TABLE IF NOT EXISTS code (
   code_id INTEGER PRIMARY KEY,
   hash TEXT UNIQUE ON CONFLICT IGNORE NOT NULL,
   binary BLOB NOT NULL
);
```


#### create\_module\_table

```sql
CREATE TABLE IF NOT EXISTS module (
   module_id INTEGER PRIMARY KEY,
   time DATETIME DEFAULT CURRENT_TIMESTAMP,
   name STRING NOT NULL,
   type STRING DEFAULT 'luaJIT-2.1-bytecode',
   branch STRING,
   vc_hash STRING,
   project INTEGER NOT NULL,
   version INTEGER NOT NULL,
   bundle INTEGER,
   code INTEGER NOT NULL,
   FOREIGN KEY (project)
      REFERENCES project (project_id)
      ON DELETE RESTRICT
   FOREIGN KEY (version)
      REFERENCES version (version_id)
   FOREIGN KEY (bundle)
      REFERENCES bundle (bundle_id)
      ON DELETE CASCADE
   FOREIGN KEY (code)
      REFERENCES code (code_id)
);
```


#### create\_module\_table\_index

Indexing the time and name gives a modest boost in performance, we can shave
more time with a new schema, that work is elsewhere\.

```sql
CREATE INDEX IF NOT EXISTS module_time_idx ON module (time DESC, name);
```


#### create\_voltron\_table

```sql
CREATE TABLE IF NOT EXISTS voltron (
   voltron_id INTEGER PRIMARY KEY,
   voltron LUATEXT NOT NULL,
   name TEXT NOT NULL,
   project INTEGER,
   time DATETIME DEFAULT (strftime('%Y-%m-%dT%H:%M:%f', 'now')),
   active INTEGER NOT NULL DEFAULT 1 CHECK (active = 0 or active = 1),
   -- add version in a real migration
   FOREIGN KEY (project)
      REFERENCES project (project_id)
);
```


## Create bridge\.modules

If it exists already, we have a conn on `_Bridge`\.

If not, we can create it\. We have the technology\.


### \_Bridge\.new\_modules\_db\(conn\_home\)

  We want to retain the ability to instantiate a modules database, the
motivating case being an in\-memory version for testing\.

```lua
local function new_modules_db(conn_home)
   local yes, conn;
   if type(conn_home) == 'string' then
      yes, conn = pcall(sql.open, conn_home, 'rwc')
      if not yes then
         error("Could not create " .. conn_home
               .. ", consider creating the directory or setting"
               .. " $BRIDGE_MODULES.")
      end
   end
   if conn then
      conn:exec(stmts.create_project_table)
      conn:exec(stmts.create_version_table)
      conn:exec(stmts.create_bundle_table)
      conn:exec(stmts.create_code_table)
      conn:exec(stmts.create_module_table)
      conn:exec(stmts.create_module_table_index)
      conn:exect(stmts.create_voltron_table)
   end

   return conn
end

_Bridge.new_modules_db = new_modules_db

if not _Bridge.modules_conn then
   _Bridge.modules_conn = new_modules_db(_Bridge.bridge_modules_home)
   new_modules = true
end
```


# Import

Imports a bundle file into the database\.


### SQL

This is going to be a copy\-paste of SQL statements in [Orb's database code](https://gitlab.com/special-circumstance/pylon/-/blob/trunk/doc/md/orb/compile/database.md)\.

Eventually I do want a single home for all this logic, and being as it's core
to initializing bridge, that will probably be in pylon\.

For extra points, it should be in a SQL\-specific `.orb` file, and transcluded
into Lua source blocks, but we have several steps we need to accomplish before
that is tractable\.

### project


#### new\_project

```sql
INSERT INTO project (name, repo, repo_alternates, home, website)
VALUES (:name, :repo, :repo_alternates, :home, :website)
;
```


#### get\_project

```sql
SELECT project_id FROM project
WHERE project.name = ?
;
```


#### update\_project

```sql
UPDATE project
SET
   repo = :repo,
   repo_alternates = :repo_alternates,
   home = :home,
   website = :website
WHERE
   name = :name
;
```


### version


#### get\_version\_snapshot

```sql
SELECT CAST (version.version_id AS REAL) FROM version
WHERE edition = :edition
AND stage = :stage
AND major = :major
AND minor = :minor
AND patch = :patch
AND special = :special
AND project = :project
;
```


#### new\_version\_snapshot

```sql
INSERT INTO version (edition, project)
VALUES (:edition, :project)
;
```


#### new\_version

```sql
INSERT INTO version (edition, project, major, minor, patch)
VALUES (:edition, :project, :major, :minor, :patch)
;
```


### code


#### get\_code\_id\_by\_hash

```sql
SELECT CAST (code.code_id AS REAL) FROM code
WHERE code.hash = ?;
```


#### new\_code

```sql
INSERT INTO code (hash, binary)
VALUES (:hash, :binary)
;
```


### bundle


#### new\_bundle

```sql
INSERT INTO bundle (project, version)
VALUES (?, ?)
;
```

#### get\_latest\_bundle

```sql
SELECT CAST (bundle.bundle_id AS REAL), time FROM bundle
WHERE bundle.project = ?
AND bundle.version = ?
ORDER BY
   time DESC,
   bundle_id DESC
LIMIT 1
;
```


### module


#### add\_module

```sql
INSERT INTO module (version, name, bundle,
                    branch, vc_hash, project, code, time)
VALUES (:version, :name, :bundle,
        :branch, :vc_hash, :project, :code, :time)
;
```

```lua
local function _commitBundle(conn, bundle)
   -- #todo verify byecode hashes, load bytecodes (but don't execute)
   -- #todo verify bundle hash, and signature if possible/present
   --
   -- upsert project
   local project_id = conn:prepare(get_project_id)
                          :bind(bundle.project.name):step()
   if not project_id then
      conn:prepare(new_project):bindkv(bundle.project):step()
      project_id = conn:prepare(get_project_id)
                          :bind(bundle.project.name):step()
   end
   project_id = project_id[1]
   conn:prepare(update_project):bindkv(bundle.project):step()
   -- upsert version (what to do if version exists?)
   bundle.version.project = project_id
   conn:prepare(new_version):bindkv(bundle.version):step()
   local version_id = conn:prepare(get_version)
                          :bindkv(bundle.version):step()
   if not version_id then
      error "failed to create version"
   end
   version_id = version_id[1]
   -- make bundle, get bundle id
   conn:prepare(new_bundle):bind(project_id, version_id):step()
   local bundle_info = conn:prepare(get_latest_bundle)
                         :bind(project_id, version_id):step()
   if not bundle_info then
      error "failed to create bundle"
   end
   local bundle_id, now = bundle_info[1], bundle_info[2]
   local mod_stmt = conn:prepare(add_module)
   for _, mod in ipairs(bundle.modules) do
      -- commit code
      local code_id = conn:prepare(get_code_id_by_hash)
                         :bind(mod.hash):step()
      if not code_id then
         conn:prepare(new_code):bindkv(mod):step()
         code_id = conn:prepare(get_code_id_by_hash)
                         :bind(mod.hash):step()
         if not code_id then
            error ("failed to commit code for" .. mod.name)
         end
      end
      code_id = code_id[1]
      -- add module info
      mod.code = code_id
      mod.project = project_id
      mod.version = version_id
      mod.bundle = bundle_id
      mod.time = now
      mod_stmt:bindkv(mod):step()
      mod_stmt:reset()
   end
end
```

```lua
local function import(file_name)
   local file = io.open(file_name, "r")
   if not file then
      error("can't open " .. file_name)
   end
   -- load() the file
   local bundles, err = load(file:read("a"))
   file:close()
   if not bundles then
      error(err)
   end
   setfenv(bundles, {})
   local bundles = bundles()

   local conn = _Bridge.modules_conn
   conn:exec "BEGIN TRANSACTION;"
   if bundles.project then
      -- single-bundled project
      _commitBundle(conn, bundles)
   else
      for _, bundle in ipairs(bundles) do
         _commitBundle(conn, bundle)
      end
   end
   conn:exec "COMMIT;"
end

_Bridge.import = import
```


### Try to load default bundle file

Our bootstrap will assume that `br` is living in the `build` directory\.

```lua
if new_modules then
   print "importing modules bundle"
   import("all_modules.bundle")
end
```



### Voltron

  Voltron 'stealth\-migrates', which we'll make official with migration 2, when
that happens\.

```sql
SELECT name
FROM sqlite_master
WHERE type = 'table' AND name = 'voltron'
;
```

```sql
SELECT name FROM voltron WHERE active = 1;
```

For now we need a shim to create our new tables

```lua
local conn = _Bridge.modules_conn

local has_voltron = conn:prepare(check_voltron) :value()

if not has_voltron then
   conn:exec(stmts.create_module_table_index)
   conn:exec(stmts.create_voltron_table)
   _Bridge.volts = {}
else
   local volts = {}
   for i, name in conn:prepare(get_voltron_names) :cols() do
      volts[name] = true
   end
   _Bridge.volts = volts
end
```


##### End of do guard

```lua
end
```
