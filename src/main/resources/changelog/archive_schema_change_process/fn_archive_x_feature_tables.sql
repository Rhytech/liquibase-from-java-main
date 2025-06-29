DROP FUNCTION IF EXISTS public.fn_archive_x_feature_tables;

CREATE OR REPLACE FUNCTION public.fn_archive_x_feature_tables()
RETURNS VARCHAR(255)
LANGUAGE plpgsql
AS $$
DECLARE
    enable_archiving_process BOOLEAN DEFAULT FALSE;
    archiving_number_of_days INT;
    archiving_limit_rows BIGINT;
    is_archiving_running BOOLEAN DEFAULT FALSE;
	start_time VARCHAR(50);
	end_time VARCHAR(50);
BEGIN

    SELECT CASE WHEN config_value IN ('1', 'true') THEN TRUE 
                ELSE FALSE 
			END 
	INTO enable_archiving_process
    FROM public.app_config 
    WHERE config_name = 'ENABLE_ONLY_X_FEATURE_TABLES_ARCHIVING_PROCESS';

	enable_archiving_process := COALESCE(enable_archiving_process,FALSE);
	
	IF NOT enable_archiving_process THEN
        RETURN 'Skipping the job since it is disabled in app config table.';
    END IF;
	
    SELECT CASE WHEN config_value = '1' THEN TRUE 
                ELSE FALSE 
			END 
	INTO is_archiving_running
    FROM public.app_config 
    WHERE config_name = 'IS_X_FEATURE_TABLES_ARCHIVING_RUNNING';

	is_archiving_running := COALESCE(is_archiving_running,FALSE);
	
    IF is_archiving_running THEN
        RETURN 'Skipping the job since it is already running.';
    END IF;

    SELECT config_value::INT 
	INTO archiving_number_of_days
    FROM public.app_config
    WHERE config_name = 'ARCHIVING_X_FEATURE_TABLES_NUMBER_OF_DAYS'
	AND config_value ~ '^[0-9]+$';

    SELECT config_value::BIGINT 
	INTO archiving_limit_rows
    FROM public.app_config
    WHERE config_name = 'ARCHIVING_X_FEATURE_TABLES_LIMIT_ROWS'
	AND config_value ~ '^[0-9]+$';
	
	start_time := TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS TZ');

    UPDATE public.app_config
    SET config_value = '1'
    WHERE config_name = 'IS_X_FEATURE_TABLES_ARCHIVING_RUNNING';
	
    CALL public.sp_archive_x_feature_tables(archiving_number_of_days, archiving_limit_rows);

    UPDATE public.app_config
    SET config_value = '0'
    WHERE config_name = 'IS_X_FEATURE_TABLES_ARCHIVING_RUNNING';
	
	end_time := TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS TZ');
	
	RETURN CONCAT('Job started at : ',start_time,', and completed at : ', end_time );

END;
$$;