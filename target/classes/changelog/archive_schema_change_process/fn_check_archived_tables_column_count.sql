DROP FUNCTION IF EXISTS public.fn_check_archived_tables_column_count;

CREATE OR REPLACE FUNCTION public.fn_check_archived_tables_column_count(
    source_schema VARCHAR(100),
    archive_schema VARCHAR(100)
) RETURNS VARCHAR(512)
LANGUAGE plpgsql
AS $$
DECLARE
    v_result BOOLEAN;
    v_result_message VARCHAR(512);
BEGIN
	
	SELECT distinct does_column_count_match,message_column_count_mismatch
	INTO v_result, v_result_message
	FROM public.fn_check_x_feature_tables_column_count(source_schema, archive_schema) 
	ORDER BY does_column_count_match DESC LIMIT 1;
	
	IF v_result THEN
		RETURN CAST(v_result AS VARCHAR(512));
	ELSE
		RETURN CONCAT(CAST(v_result AS VARCHAR(512)),' - ',v_result_message);
	END IF;
END;
$$;