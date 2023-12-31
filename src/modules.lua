

















do








local new_modules = false












local stmts = {}













stmts.create_project_table = [[
CREATE TABLE IF NOT EXISTS project (
   project_id INTEGER PRIMARY KEY,
   name STRING UNIQUE NOT NULL ON CONFLICT IGNORE,
   repo STRING,
   repo_type STRING DEFAULT 'git',
   repo_alternates STRING,
   home STRING,
   website STRING
);
]]




stmts.create_version_table = [[
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
]]




stmts.create_bundle_table = [[
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
]]




stmts.create_code_table = [[
CREATE TABLE IF NOT EXISTS code (
   code_id INTEGER PRIMARY KEY,
   hash TEXT UNIQUE ON CONFLICT IGNORE NOT NULL,
   binary BLOB NOT NULL
);
]]




stmts.create_module_table = [[
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
]]















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
   end

   return conn
end

_Bridge.new_modules_db = new_modules_db

if not _Bridge.modules_conn then
   _Bridge.modules_conn = new_modules_db(_Bridge.bridge_modules_home)
   new_modules = true
end


























local new_project = [[
INSERT INTO project (name, repo, repo_alternates, home, website)
VALUES (:name, :repo, :repo_alternates, :home, :website)
;
]]




local get_project_id = [[
SELECT project_id FROM project
WHERE project.name = ?
;
]]




local update_project = [[
UPDATE project
SET
   repo = :repo,
   repo_alternates = :repo_alternates,
   home = :home,
   website = :website
WHERE
   name = :name
;
]]







local get_version = [[
SELECT CAST (version.version_id AS REAL) FROM version
WHERE edition = :edition
AND stage = :stage
AND major = :major
AND minor = :minor
AND patch = :patch
AND special = :special
AND project = :project
;
]]




local new_version_snapshot = [[
INSERT INTO version (edition, project)
VALUES (:edition, :project)
;
]]




local new_version = [[
INSERT INTO version (edition, project, major, minor, patch)
VALUES (:edition, :project, :major, :minor, :patch)
;
]]







local get_code_id_by_hash = [[
SELECT CAST (code.code_id AS REAL) FROM code
WHERE code.hash = ?;
]]




local new_code = [[
INSERT INTO code (hash, binary)
VALUES (:hash, :binary)
;
]]







local new_bundle = [[
INSERT INTO bundle (project, version)
VALUES (?, ?)
;
]]



local get_latest_bundle = [[
SELECT CAST (bundle.bundle_id AS REAL), time FROM bundle
WHERE bundle.project = ?
AND bundle.version = ?
ORDER BY
   time DESC,
   bundle_id DESC
LIMIT 1
;
]]







local add_module = [[
INSERT INTO module (version, name, bundle,
                    branch, vc_hash, project, code, time)
VALUES (:version, :name, :bundle,
        :branch, :vc_hash, :project, :code, :time)
;
]]


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








if new_modules then
   print "importing modules bundle"
   import("all_modules.bundle")
end






end

