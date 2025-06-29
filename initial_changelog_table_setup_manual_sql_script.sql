-- This script needs to be run one time before using Liquibase to manage database changes in the fresh database.

CREATE SCHEMA IF NOT EXISTS db_change_logs;

-- This SQL script creates a schema and two tables for Liquibase change logs.
-- The first table stores the change log entries, and the second table manages locks to prevent concurrent changes.

 CREATE TABLE IF NOT EXISTS db_change_logs.databasechangelog (
   ID varchar(255) NOT NULL,
   AUTHOR varchar(255) NOT NULL,
   FILENAME varchar(255) NOT NULL,
   DATEEXECUTED TIMESTAMP NOT NULL,
   ORDEREXECUTED INTEGER NOT NULL,
   EXECTYPE varchar(10) NOT NULL,
   MD5SUM varchar(35),
   DESCRIPTION varchar(255),
   COMMENTS varchar(255),
   TAG varchar(255),
   LIQUIBASE varchar(20),
   CONTEXTS varchar(255),
   LABELS varchar(255),
   DEPLOYMENT_ID varchar(10)
 );
 
 CREATE TABLE IF NOT EXISTS db_change_logs.databasechangeloglock (
   id INTEGER NOT NULL PRIMARY KEY,
   LOCKED BOOLEAN NOT NULL,
   LOCKGRANTED TIMESTAMP ,
   LOCKEDBY varchar(255)
 );