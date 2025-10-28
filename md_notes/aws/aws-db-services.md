# Amazon RDS

Amazon RDS (Relational Database Service) provides a managed DBMS for a
relational database.

Two types of relational databases:

*Online Transaction Processing (OLTP)*: Optimized for applications that read and
write very frequently. Queries are simple and predictable. Usually used for
applications.

*OLAP*: Optimized for few writes and more reads. Used for large and complex
queries against very larga data sets. Common use case includes data wharehouses.

# Database engines provided by RDS

| Engine               | Use case           |
| -------------------- | ------------------ |
| MySQL                | Mainly OLTP        |
| MariaDB              | Mainly OLTP        |
| Oracle               | Both OLTP and OLAP |
| PostgreSQL           | Mainly OLTP        |
| Amazon Aurora        | OLTP               |
| Microsoft SQL Server | Both OLTP and OLAP |
