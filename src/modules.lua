

















do












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






end
