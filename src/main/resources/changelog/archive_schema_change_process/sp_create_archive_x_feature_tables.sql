DROP PROCEDURE IF EXISTS public.sp_create_archive_x_feature_tables;

CREATE OR REPLACE PROCEDURE public.sp_create_archive_x_feature_tables(drop_existing BOOLEAN DEFAULT FALSE)
LANGUAGE plpgsql
AS $$
BEGIN

    CREATE SCHEMA IF NOT EXISTS archive_x_tables;

	IF drop_existing THEN
      DROP TABLE IF EXISTS archive_x_tables.archive_x_table CASCADE;
      DROP TABLE IF EXISTS archive_x_tables.archive_x_child_table CASCADE;
    END IF;
	
    CREATE TABLE IF NOT EXISTS archive_x_tables.archive_x_table
    AS TABLE public.x_table WITH NO DATA;

    CREATE TABLE IF NOT EXISTS archive_x_tables.archive_x_child_table
    AS TABLE public.x_child_table WITH NO DATA;
	
END
$$