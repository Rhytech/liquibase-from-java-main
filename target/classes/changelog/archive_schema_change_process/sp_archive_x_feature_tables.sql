DROP PROCEDURE IF EXISTS public.sp_archive_x_feature_tables;

CREATE OR REPLACE PROCEDURE public.sp_archive_x_feature_tables(
    IN number_of_days INTEGER DEFAULT 3,
    IN limit_rows BIGINT DEFAULT 50000
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_error_message TEXT;
    v_start_time TIMESTAMP;
    v_total_records_archived BIGINT := 0;
    v_script_success_till TEXT := 'START';
    v_selected_date TIMESTAMP;
    v_result BOOLEAN;
    v_result_message TEXT;
	v_schema_name VARCHAR(100) := 'public';
	v_archive_schema_name VARCHAR(100) := 'archive_x_tables';
BEGIN

	-- Date for archiving data to be selected as per UTC since cron job will be scheduled as per UTC 
    v_selected_date := (((NOW() AT TIME ZONE 'UTC') - (number_of_days || ' days')::INTERVAL)::DATE)::TIMESTAMP;
	
	-- Database server timezone
    v_start_time := NOW();

    INSERT INTO public.archive_table_logs (
        log_uid, log_version, sp_name, log_status, script_success_till,
        total_records_archived, start_time, end_time, archived_date
    )
    VALUES (
        gen_random_uuid(), 0, 'sp_archive_x_feature_tables', 'START',
        v_script_success_till, 0, v_start_time, NULL, v_selected_date
    );

    SELECT does_column_count_match, message_column_count_mismatch
    INTO v_result, v_result_message
    FROM public.fn_check_x_feature_tables_column_count(v_schema_name,v_archive_schema_name)
    ORDER BY does_column_count_match DESC LIMIT 1;

    IF NOT v_result THEN
        v_error_message := v_result_message;
		RAISE EXCEPTION '%', v_error_message;
    END IF;

    TRUNCATE public.arc_x_ids;

    INSERT INTO public.arc_x_ids (id)
    SELECT id FROM public.x_table
    WHERE estimated_delivery_time < v_selected_date
    LIMIT limit_rows
	ON CONFLICT DO NOTHING;

    v_total_records_archived := (SELECT COUNT(*) FROM public.arc_x_ids);

    BEGIN
        -- Start transaction
        v_script_success_till := 'BEFORE INSERT INTO archive_x_child_table';

        INSERT INTO archive_x_tables.archive_x_child_table
        SELECT * FROM public.x_child_table
        WHERE x_id IN (SELECT id FROM public.arc_x_ids)
		ON CONFLICT DO NOTHING;

        v_script_success_till := 'INSERT INTO archive_x_child_table';

        INSERT INTO archive_x_tables.archive_x_table
        SELECT * FROM public.x_table
        WHERE id IN (SELECT id FROM public.arc_x_ids)
		ON CONFLICT DO NOTHING;

        v_script_success_till := 'INSERT INTO archive_x_table';
		
		v_script_success_till = 'ALL INSERTION SUCCESS';
		
        DELETE FROM public.x_child_table
        WHERE x_id IN (SELECT id FROM public.arc_x_ids);
	
		v_script_success_till := 'DELETE FROM x_child_table';

        DELETE FROM public.x_table
        WHERE id IN (SELECT id FROM public.arc_x_ids);
	
		v_script_success_till := 'DELETE FROM x_table';

        v_script_success_till := 'ALL DELETION SUCCESS';

        v_script_success_till := 'ALL SUCCESS';

        INSERT INTO public.archive_table_logs (
            log_uid, log_version, sp_name, log_status, script_success_till,
            total_records_archived, start_time, end_time, archived_date
        )
        VALUES (
            gen_random_uuid(), 0, 'sp_archive_x_feature_tables', 'END',
            v_script_success_till, v_total_records_archived,
            v_start_time, NOW(), v_selected_date
        );
		
		RAISE NOTICE 'Archiving completed successfully for % rows.', v_total_records_archived;

		EXCEPTION WHEN OTHERS THEN
	
			GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
	
			INSERT INTO public.archive_table_logs (
				log_uid, log_version, sp_name, log_status, script_success_till,
				total_records_archived, start_time, end_time, archived_date
			)
			VALUES (
				gen_random_uuid(), 0, 'sp_archive_x_feature_tables',
				'FAILED WHILE ARCHIVING - ' || v_error_message, v_script_success_till,
				0, v_start_time, NOW(), v_selected_date
			);
			
			RAISE NOTICE 'An error occurred while archiving: %', v_error_message;
  
    END;
	
	EXCEPTION WHEN OTHERS THEN

        GET STACKED DIAGNOSTICS v_error_message = MESSAGE_TEXT;
		
		INSERT INTO public.archive_table_logs (
        log_uid, log_version, sp_name, log_status, script_success_till,
        total_records_archived, start_time, end_time, archived_date
		)
		VALUES (
			gen_random_uuid(), 0, 'sp_archive_x_feature_tables', 'START',
			'START', 0, v_start_time, NULL, v_selected_date
		);

        INSERT INTO public.archive_table_logs (
            log_uid, log_version, sp_name, log_status, script_success_till,
            total_records_archived, start_time, end_time, archived_date
        )
        VALUES (
            gen_random_uuid(), 0, 'sp_archive_x_feature_tables',
            'FAILED BEFORE START OF ARCHIVING - ' || v_error_message, v_script_success_till,
            0, v_start_time, NOW(), v_selected_date
        );
		
		RAISE NOTICE 'An error occurred before archiving: %', v_error_message;

END;
$$;