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

import java.io.IOException;

public class Main {
    public static void main(String[] args) {
        try {
            // Load DB connection and Liquibase settings
            PropertiesReader propertiesReader = new PropertiesReader();

            // Create and run LiquibaseRunner
            LiquibaseRunner liquibaseRunner = new LiquibaseRunner(
                    propertiesReader.getProperties(),
                    "db_change_logs",  // changelog schema
                    "public"           // update schema
            );

            liquibaseRunner.run();
            System.out.println("Liquibase migration completed successfully.");

        } catch (IOException e) {
            System.err.println("Failed to load properties: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Liquibase migration failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}