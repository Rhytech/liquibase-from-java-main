--liquibase formatted sql for running the function to match column between schemas

--changeset Rhythm:run_column_count_matcher runAlways:TRUE
--preconditions onFail:HALT onError:HALT
--precondition-sql-check expectedResult:"true" SELECT public.fn_check_archived_tables_column_count('public', 'archive_x_tables');
SELECT 'archive tables column count matched';