# Liquibase from Java with PostgreSQL (Using XML-Based Change Logs)

This project demonstrates how to run Liquibase from a Java application using a PostgreSQL database. It supports Java 8 and above and can be executed either with Maven or as a standalone Java application.

## 🔧 Features

- Supports any Java version ≥ 8
- PostgreSQL integration via JDBC
- XML-based Liquibase changelogs
- Configurable changelog and target schema
- Maven and non-Maven execution options

## 🗂 Project Overview

- Uses a PostgreSQL database connection.
- Change log schema and target schema are configurable in the `Main.java` file.
- Supports easy migration to MySQL or other databases by replacing the PostgreSQL JDBC dependency in `pom.xml`.

## ⚙️ Configuration

1. **Database Settings:**
   - Update the database connection properties in `src/main/resources/db.properties`.

2. **Liquibase Schema:**
   - To store the `DATABASECHANGELOG` table in a schema other than `public`, update `Main.java` accordingly.
   - Ensure the schema exists in the database **before running the application**.

3. **Java Version (Maven Builds Only):**
   - If using Maven, ensure the correct Java version is set under the Maven Compiler Plugin in `pom.xml`:
     ```xml
     <properties>
         <maven.compiler.source>1.8</maven.compiler.source>
         <maven.compiler.target>1.8</maven.compiler.target>
     </properties>
     ```
   - This step is **not required** when running the application directly via `Main.java`.

## 🚀 Running the Project

In the root directory of the project, execute the following command:

```bash
mvn clean compile exec:java


## 📄 License

© 2025 Rhythm Pangotra. All rights reserved.

This project is **not open source**. No part of this codebase may be copied, modified, distributed, or used without the **express written permission** of the author.

For licensing inquiries, contact: rhythmpangotra.be@gmail.com
