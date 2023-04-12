require "sqlite3"

def create_schema(db)
    db.execute <<-SQL
    CREATE TABLE type (
        type_id INTEGER PRIMARY KEY,
        display_name TEXT NOT NULL,
        parent_type_id INTEGER, -- if something has a parent_type, it is 'transient' data and in the final version will not be persisted to disk
        FOREIGN KEY(parent_type_id) REFERENCES types
    );
    SQL
    db.execute <<-SQL
    CREATE TABLE rule (
        rule_id INTEGER PRIMARY KEY,
        from_type_id INTEGER NOT NULL,
        to_type_id INTEGER NOT NULL,
        hardcoded_derivation TEXT, -- the derivation can either be something hardcoded like 'regex' or 'css_selector', or can be arbitrary code
        hardcoded_derivation_param1 TEXT,
        js_script TEXT,
        FOREIGN KEY(from_type_id) REFERENCES types,
        FOREIGN KEY(to_type_id) REFERENCES types
    );
    SQL
    db.execute <<-SQL
    -- A datum is a blob stored on disk. Typically this is a URL, a downloaded webpage, or a leaf "JSON" type field.
    CREATE TABLE datum (
        datum_id INTEGER PRIMARY KEY,
        content BLOB NOT NULL,
        sha2_hash TEXT NOT NULL,
        type_id INTEGER NOT NULL,
        parent_datum_id INTEGER,
        FOREIGN KEY(type_id) REFERENCES types,
        FOREIGN KEY(parent_datum_id) REFERENCES datum,
        UNIQUE(sha2_hash, type_id, parent_datum_id),
        UNIQUE(content, type_id, parent_datum_id)
    );
    SQL
    db.execute <<-SQL
    -- A seed is a special source datum input manually by the user
    CREATE TABLE seed (
        datum_id INTEGER PRIMARY KEY,
        FOREIGN KEY(datum_id) REFERENCES datum
    );
    SQL
    db.execute <<-SQL
    -- Before a rule is applied to a particular datum, there will be 1 'application' and 0 'application_results'. Afterwards, the 1 'application' will be updated, and there will be 0, 1, or more 'application_results'--one row per result..
    CREATE TABLE application (
        source_datum_id INTEGER NOT NULL,
        derivation_id INTEGER NOT NULL,
        task_id INTEGER, -- may be erased once DONE
        error TEXT,
        status INTEGER, -- One of DONE, NOT_STARTED, IN_PROGRESS, ERROR
        FOREIGN KEY(source_datum_id) REFERENCES datum,
        FOREIGN KEY(derived_datum_id) REFERENCES datum,
        FOREIGN KEY(task_id) REFERENCES task
    );
    SQL
    db.execute <<-SQL
    -- An application produces zero or more datums as output. This links the input and any output(s).
    CREATE TABLE application_result (
        application_id INTEGER NOT NULL,
        source_datum_id INTEGER NOT NULL,
        derived_datum_id INTEGER NOT NULL,
        task_id INTEGER NOT NULL, -- Probably always present?
        FOREIGN KEY(application_id) REFERENCES application,
        FOREIGN KEY(source_datum_id) REFERENCES datum,
        FOREIGN KEY(derived_datum_id) REFERENCES datum,
        FOREIGN KEY(task_id) REFERENCES task
    );
    SQL
    db.execute <<-SQL
    -- There is one task created for each application. A task is an asynchonous unit of work a worker thread can complete.
    CREATE TABLE task (
        task_id INTEGER PRIMARY_KEY,
        job_id INTEGER NOT NULL,
        application_id INTEGER, -- Most tasks will have an application_id, but not all
        status INTEGER, -- One of NOT_STARTED, IN_PROGESS, ERROR, DONE
        progress REAL, -- Percentage between 0 and 1
        attempts INTEGER,
        claimed BOOLEAN,
        FOREIGN KEY(job_id) references job,
        FOREIGN KEY(application_id) references application,
    );
    SQL
    db.execute <<-SQL
    -- A progress bar refers to either a task (atomic) or a batch_job (conceptual grouping)
    CREATE TABLE job (
        job_id INTEGER PRIMARY_KEY,
        parent_job_id INTEGER, -- Some tasks are subtasks, some are top-level tasks
        task_id INTEGER, -- Some tasks are conceptual groups (NULL), some are leaf-level tasks
        subjobs_total INTEGER,
        subjobs_complete INTEGER,
        status INTEGER, -- One of NOT_STARTED, IN_PROGESS, ERROR, DONE
        progress REAL, -- Percentage between 0 and 1
        FOREIGN KEY(parent_job_id) references jobs,
        FOREIGN KEY(task_id) references tasks,
    );

    SQL
end

db = SQLite3::Database.new "test.db"
create_schema db
