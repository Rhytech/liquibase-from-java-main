DROP FUNCTION IF EXISTS public.fn_check_x_feature_tables_column_count;

CREATE OR REPLACE FUNCTION public.fn_check_x_feature_tables_column_count(
    source_schema VARCHAR(100),
    archive_schema VARCHAR(100)
) RETURNS TABLE (
    does_column_count_match BOOLEAN,
    message_column_count_mismatch VARCHAR(512)
)
LANGUAGE plpgsql
AS $$
DECLARE
    table_pairs TEXT[][] := ARRAY[
        ['x_table', 'archive_x_table'],
        ['x_child_table', 'archive_x_child_table']
    ];

    source_count BIGINT;
    archive_count BIGINT;
    i INT;
    source_table VARCHAR(100);
    archive_table VARCHAR(100);
BEGIN
    does_column_count_match := TRUE;
    message_column_count_mismatch := 'All tables column count match';

    FOR i IN 1 .. array_length(table_pairs, 1) LOOP
        source_table := table_pairs[i][1];
        archive_table := table_pairs[i][2];

        EXECUTE format(
            'SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = %L AND table_name = %L',
            source_schema, source_table
        ) INTO source_count;

        EXECUTE format(
            'SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = %L AND table_name = %L',
            archive_schema, archive_table
        ) INTO archive_count;

        IF source_count IS DISTINCT FROM archive_count THEN
            does_column_count_match := FALSE;
            message_column_count_mismatch := format(
                'Column count mismatch: %I has %s columns vs %I has %s columns',
                source_table, source_count,
                archive_table, archive_count
            );
            RETURN NEXT;
        END IF;
    END LOOP;

    RETURN NEXT;
END;
$$;