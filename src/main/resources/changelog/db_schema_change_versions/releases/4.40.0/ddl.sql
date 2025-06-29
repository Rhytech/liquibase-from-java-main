--liquibase formatted sql

--changeset Rhythm:x_feature_table_1 runAlways:false
CREATE TABLE IF NOT EXISTS public.x_table (
    id BIGINT PRIMARY KEY,
    estimated_delivery_time TIMESTAMP,
    a_json JSONB, -- Storing Hierarchical JSON data
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
    	
--changeset Rhythm:x_feature_table_2 runAlways:false
CREATE TABLE IF NOT EXISTS public.x_child_table (
  x_id BIGINT PRIMARY KEY,
  delivery_status VARCHAR(10),
  updated_time TIMESTAMP,
  CONSTRAINT fk_x_child_table FOREIGN KEY (x_id) REFERENCES x_table(id)
);