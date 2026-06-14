# Database
This directory contains the database files, and scripts for local development.

> [!NOTE]
> use arg `-h` to see the available options for each script and usage.

## Local Development

> [!CAUTION]
> ### Prerequisites
> - Port `5432` is available 
> - Docker is installed

#### Setup database
```powershell
.\setup.ps1 -d
```
*Use flag -h, for options*

#### Inject sql

```powershell
.\initdb.ps1 -rc -l
```
*Use flag -h, for options*

## Delployment

In order, execute the .sql files:
- db.sql
- sp.sql