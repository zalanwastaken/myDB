# MyDB - A Simple File-Based Database for LOVE2D

## Introduction

MyDB is a lightweight, file-based database designed for small to medium-sized datasets. It leverages JSON files for storage and is tailored for projects needing an easy-to-manage database solution.

This project is primarily a hobby endeavor and may not receive frequent updates. Use it as-is for non-critical applications.

---

## Features

- **JSON-based storage**: Each table is stored as a separate JSON file, making it easy to read and manage.
- **Database and table management**: Create, update, and manage databases and their tables effortlessly.
- **Support for structured tables**: Use structured tables with predefined keys for consistency.
- **Lightweight**: No additional dependencies beyond LOVE2D and a JSON library.
- **Dynamic merging**: Combines existing data with new entries seamlessly.
- **Simple utilities**: Includes helper functions for database validation and recovery.

---

## Functions Overview

### **Database Functions**

#### `createDB(dbname)`
Creates a new database directory with metadata stored in an `info.json` file.

**Parameters:**
- `dbname`: The name of the database.

**Throws an error** if the database already exists.

---

#### `dbExists(dbname)`
Checks if a database exists.

**Parameters:**
- `dbname`: The name of the database.

**Returns:**  
`true` if the database exists, otherwise `false`.

---

#### `getDbInfo(dbname)`
Retrieves the metadata (`info.json`) of a specified database.

**Parameters:**
- `dbname`: The name of the database.

**Returns:**  
The metadata as a table, or `nil` if the database does not exist.

---

### **Table Functions**

#### `createTable(dbname, tablename, data)`
Creates a new table in a database and populates it with initial data.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.
- `data`: The initial data as a Lua table.

**Throws an error** if the table already exists or the database is missing.

---

#### `tableExists(dbname, tablename)`
Checks if a table exists in a database.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.

**Returns:**  
`true` if the table exists, otherwise `false`.

---

#### `getTableData(dbname, tablename)`
Retrieves the data from a specified table.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.

**Returns:**  
The table's data as a Lua table.

---

#### `modifyTable(dbname, tablename, data)`
Modifies an existing table's data by merging new data with the existing content.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.
- `data`: The new data to merge (as a Lua table).

**Throws an error** if the table does not exist or the database is missing.

---

### **Structured Table Functions**

#### `createStructTable(dbname, tablename, struct)`
Creates a structured table with predefined keys. Each entry must match the structure.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.
- `struct`: A table defining the structure of each entry.

**Throws an error** if the table or database does not exist.

---

#### `addStructData(dbname, tablename, vals)`
Adds data to a structured table. Data must adhere to the table's predefined structure.

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.
- `vals`: The data to add, adhering to the structure.

**Throws an error** if keys are missing or the structure does not match.

---

#### `getStructData(dbname, tablename, sno)`
Retrieves data from a structured table. Optionally, fetch a specific record by its serial number (`sno`).

**Parameters:**
- `dbname`: The database name.
- `tablename`: The table name.
- `sno`: (Optional) The record index to fetch.

**Returns:**  
- The entire table's data if no `sno` is provided.
- A single record if `sno` is specified.

---

### **Filesystem Utilities**

#### `removeDbFile(dbname, file)`
Deletes a file from the database directory. **This function does not update the database's metadata.**

**Parameters:**
- `dbname`: The database name.
- `file`: The name of the file to remove.

---

#### `fixTableInfo(dbname)`
Synchronizes the database's metadata (`info.json`) with the actual tables in the directory.

**Parameters:**
- `dbname`: The database name.

---

## Notes

- **Structured Tables**: These tables enforce data consistency by requiring all entries to match a predefined structure.
- **Data Storage**: All data is stored as JSON files within the database directory.
- **Error Handling**: Errors are raised for operations on missing databases or tables.

---
## Disclaimer

This is a hobby project and will not be updated frequently, if at all. Please use it at your own risk and for non-critical applications.
