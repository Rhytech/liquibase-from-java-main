--liquibase formatted sql for creating archive schema

--changeset Rhythm:create_archive_x_tables_schema runAlways:false
CREATE SCHEMA IF NOT EXISTS archive_x_tables;