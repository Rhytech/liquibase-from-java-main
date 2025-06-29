/*
 * Copyright (c) 2025 Rhythm Pangotra
 * All rights reserved.
 *
 * This source code is proprietary and confidential.
 * Unauthorized copying, modification, distribution, or use of this file,
 * via any medium, is strictly prohibited without the express written
 * permission of the author.
 *
 * For permission requests, contact: rhythmpangotra.be@gmail.com
 */

package dev.rhythm.liquibase;

import liquibase.command.CommandScope;

import java.util.Properties;

public class LiquibaseRunner {

    private static final String CHANGELOG_PATH = "/changelog/changelog-master.xml";

    private final Properties properties;
    private final String changeLogSchema;
    private final String updateSchema;

    public LiquibaseRunner(Properties properties, String changeLogSchema, String updateSchema) {
        this.properties = properties;
        this.changeLogSchema = changeLogSchema;
        this.updateSchema= updateSchema;
    }

    public void run() {
        try {
            doRun();
        } catch (Exception e) {
            throw new RuntimeException("Error running Liquibase changelog", e);
        }
    }

    private void doRun() throws Exception {
        try {
            new CommandScope("update")
                    .addArgumentValue("changeLogFile", CHANGELOG_PATH)
                    .addArgumentValue("url", properties.getProperty("url"))
                    .addArgumentValue("username", properties.getProperty("username"))
                    .addArgumentValue("password", properties.getProperty("password"))
                    .addArgumentValue("defaultSchemaName", changeLogSchema)
                    .addArgumentValue("searchPath", updateSchema) // PostgreSQL-specific
                    .execute();

            System.out.println("Liquibase update executed successfully.");
        } catch (Exception e) {
            System.err.println("Liquibase update failed: " + e.getMessage());
            throw e;
        }
    }
}