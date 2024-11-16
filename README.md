# MyDB - A Simple File-Based Database for LOVE2D

## Introduction

MyDB is a lightweight, file-based database designed for small to medium-sized datasets. It stores data as JSON files and is suitable for use in projects where a simple, easy-to-manage database solution is required.

Please note that this is a hobby project and will not be updated much, if at all. Use it at your own discretion.

## Features

- **Simple JSON-based storage**: Stores each table as a separate JSON file.
- **Table creation**: Allows creating new databases and tables easily.
- **Data retrieval and modification**: Retrieve and modify data within tables.
- **Lightweight**: Minimal dependencies and very easy to integrate into your project.

## Functions

### `createDB(name)`
Creates a new database. The database will be stored as a directory, with metadata stored in `info.json`.

**Parameters:**
- `name`: The name of the database.

### `createTable(dbname, tablename, data)`
Creates a new table within an existing database.

**Parameters:**
- `dbname`: The name of the database.
- `tablename`: The name of the table.
- `data`: The initial data to store in the table (as a table).

### `getTableData(dbname, tablename)`
Retrieves the data from a specified table in the database.

**Parameters:**
- `dbname`: The name of the database.
- `tablename`: The name of the table.

### `modifyTable(dbname, tablename, data)`
Modifies the data in an existing table. Only the provided keys will be updated.

**Parameters:**
- `dbname`: The name of the database.
- `tablename`: The name of the table.
- `data`: The new data to update in the table.

## Notes

- The data is stored in the form of JSON files inside the database folder.
- Each table is represented as a separate JSON file inside the database directory.
- When modifying data, only the keys present in the provided data will be updated.

## Disclaimer

This is a hobby project and will not be updated frequently, if at all. Please use it at your own risk and for non-critical applications.
