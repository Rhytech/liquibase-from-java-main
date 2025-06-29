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
import java.io.InputStream;
import java.util.Properties;

public class PropertiesReader {

    public Properties getProperties() throws IOException {
        Properties properties = new Properties();
        InputStream inputStream = getClass().getResourceAsStream("/db.properties");

        properties.load(inputStream);
        return properties;
    }
}
