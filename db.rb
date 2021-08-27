require "sqlite3"

def create_schema(db)
    db.execute <<-SQL
    CREATE TABLE types (
        type_id INTEGER PRIMARY KEY,
        display_name TEXT NOT NULL,
        parent_type_id INTEGER,
        FOREIGN KEY(parent_type_id) REFERENCES types
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE derivations (
        derivation_id INTEGER PRIMARY KEY,
        from_type_id INTEGER NOT NULL,
        to_type_id INTEGER NOT NULL,
        hardcoded_derivation TEXT,
        js_script TEXT,
        FOREIGN KEY(from_type_id) REFERENCES types,
        FOREIGN KEY(to_type_id) REFERENCES types
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE data (
        datum_id INTEGER PRIMARY KEY,
        content BLOB NOT NULL,
        sha2_hash TEXT NOT NULL,
        type_id INTEGER NOT NULL,
        parent_datum_id INTEGER,
        FOREIGN KEY(type_id) REFERENCES types,
        FOREIGN KEY(parent_datum_id) REFERENCES data,
        UNIQUE(sha2_hash, type_id, parent_datum_id),
        UNIQUE(content, type_id, parent_datum_id)
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE seeds (
        datum_id INTEGER PRIMARY KEY,
        FOREIGN KEY(datum_id) REFERENCES data
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE derivation_progress (
        immediate_done BOOLEAN NOT NULL,
        source_datum_id INTEGER NOT NULL,
        derivation_id INTEGER NOT NULL,
        FOREIGN KEY(source_datum_id) REFERENCES data,
        FOREIGN KEY(derivation_id) REFERENCES derivations,
        PRIMARY KEY (source_datum_id, derivation_id)
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE data_progress (
        source_datum_id INTEGER PRIMARY KEY,
        all_done BOOLEAN,
        FOREIGN KEY(source_datum_id) REFERENCES data
    );
    SQL
    db.execute <<-SQL
    -- Before derivation is done for a particular blob+derivation type, there will be 1 'derives', with no derived_blob. after, there may be 1 or more results--no output is represented by a row with NULL derived_blob. 'status' should be used to distinguish these 2 cases.
    CREATE TABLE derives (
        source_datum_id INTEGER NOT NULL,
        derived_datum_id INTEGER,
        derivation_id INTEGER NOT NULL,
        task_id INTEGER,
        error TEXT,
        status INTEGER, -- One of DONE, NOT_STARTED, IN_PROGRESS, ERROR
        FOREIGN KEY(source_datum_id) REFERENCES data,
        FOREIGN KEY(derived_datum_id) REFERENCES data,
        FOREIGN KEY(task_id) REFERENCES tasks
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE tasks (
        task_id INTEGER PRIMARY_KEY,
        derivation_id INTEGER,
        status INTEGER, -- One of NOT_STARTED, IN_PROGESS, ERROR, DONE
        progress REAL, -- Percentage between 0 and 1
        attempts INTEGER,
        claimed BOOLEAN
    );
    SQL
end

db = SQLite3::Database.new "test.db"
create_schema db

