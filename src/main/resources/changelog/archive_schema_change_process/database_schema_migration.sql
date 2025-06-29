--liquibase formatted sql for making ddl or dml changes for archiving purpose

--changeset Rhythm:x_feature_archiving_arc_x_ids runAlways:false
CREATE TABLE IF NOT EXISTS public.arc_x_ids (
  id BIGINT PRIMARY KEY
);

--changeset Rhythm:x_feature_archiving_archive_table_logs runAlways:false
CREATE TABLE IF NOT EXISTS public.archive_table_logs (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  log_uid VARCHAR(40),
  log_version INT,
  sp_name VARCHAR(255),
  log_status TEXT,
  script_success_till VARCHAR(255),
  total_records_archived BIGINT,
  start_time VARCHAR(255),
  end_time VARCHAR(255),
  archived_date VARCHAR(255)
);

--changeset Rhythm:x_feature_archiving_app_config runAlways:false
CREATE TABLE IF NOT EXISTS public.app_config (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid_value UUID NOT NULL DEFAULT gen_random_uuid(),
    config_name VARCHAR(255) NOT NULL,
    config_value VARCHAR(255),
    UNIQUE (config_name)
);

--changeset Rhythm:x_feature_archiving_archive_table_logs_idx_sp_name runAlways:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 select count(*) from pg_indexes where indexname in ('archive_table_logs_idx_sp_name') and tablename = 'archive_table_logs' and schemaname = 'public';
CREATE INDEX IF NOT EXISTS archive_table_logs_idx_sp_name
ON public.archive_table_logs (sp_name);

--changeset Rhythm:x_feature_sp_create_archive_traytracking_tables runAlways:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 SELECT COUNT(*) FROM information_schema.tables  WHERE table_schema = 'archive_x_tables' AND table_name = 'archive_x_table';
CALL public.sp_create_archive_x_feature_tables(true);

--changeset Rhythm:x_feature_archiving_1 runAlways:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 select count(*) from pg_indexes where indexname in ('archive_cart_pkey') and schemaname = 'archive_x_tables';
ALTER TABLE archive_x_tables.archive_x_table
ADD CONSTRAINT archive_x_table_pkey PRIMARY KEY (id);

--changeset Rhythm:x_feature_archiving_2 runAlways:false
INSERT INTO public.app_config (config_name, config_value)
SELECT config_name,config_value FROM (
    VALUES 
        ('ENABLE_ONLY_X_FEATURE_TABLES_ARCHIVING_PROCESS', '0'),
        ('IS_X_FEATURE_TABLES_ARCHIVING_RUNNING', '0'),
        ('ARCHIVING_X_FEATURE_TABLES_NUMBER_OF_DAYS', '3'),
        ('ARCHIVING_X_FEATURE_TABLES_LIMIT_ROWS', '500000')
) AS vals(config_name, config_value)
WHERE NOT EXISTS (
    SELECT 1 FROM public.app_config ac
    WHERE ac.config_name = vals.config_name
);

--changeset Rhythm:x_feature_archiving_3 runAlways:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:1 SELECT count(*) FROM information_schema.tables where table_schema = 'cron' and table_name = 'job';
SELECT cron.schedule(
  'archive_x_tables_11PM_01AM_ET',
  '0 03-05 * * *', -- The cron schedule here in the parameter has to be in UTC timezone. Runs at 11PM, 12AM, and 1AM ET (i.e., 03, 04, 05 UTC)
  'select public.fn_archive_x_feature_tables() AS job_status;'
);

--changeset Rhythm:x_feature_archiving_archive_x_child_table_idx_x_id runAlways:false
--preconditions onFail:MARK_RAN onError:HALT
--precondition-sql-check expectedResult:0 select count(*) from pg_indexes where indexname in ('archive_x_child_table_idx_x_id') and tablename = 'archive_x_child_table' and schemaname = 'archive_x_tables';
CREATE INDEX IF NOT EXISTS archive_x_child_table_idx_x_id
ON archive_x_tables.archive_x_child_table (x_id);