# Working with Data

Cloud native applications work very well with the polyglot model for data
storage. That is, multiple data store technologies are used together in an
application, taking advantage of their strengths. For example, a SQL database
for transactional data (MySQL); an object store to store files (S3); a Cache
store for ephemeral data (Redis); a NoSQL database for document storage or key
value stores (DynamoDB).

*In-memory*: Datastores that store data in memory instead of disk. Usually
employed for ephemeral data, and are insanely fast. Examples: Redis, Memached.

## Datastore Types

*Datastore*: Refers to services/technologies that store data at the application
level (usually user block storage as underlying mechanism).

### Object Store

Used for storing files such as static web assets, images, videos, etc. Highly
durable and available, very cheap. Stores files as objects: contain the file and
associated metadata. Examples: AWS S3, Google Cloud Storage, Azure Blob Storage,
MinIO (on-prem).

### Databases

*Database*: Used for storing structured data with well-defined formats. There
are many different types of databases with very different underlying mechanisms
and adequate for different use cases. The following table briefly describes
them.


| Database      | Description                                                                                                                                                                                                                                                                                                                                                |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Key/value     | A very large hash table that stores some value under a unique key. Used for data that needs to be retreived only using said key or part of it. Some key value datastores allow for compound keys and ordering: for example searching for customerid-orderid, this is a compound key with the key prefix customerid. Examples: DynamoDB, Redis (in-memory). |
| Document      | Similar to key value datastore except it enforces a particular document format, most commonly JSON (although internal DB engines use more efficient document format based on JSON such as MongoDB's BSON). They can be used much like a relational database and map nicely into objects. Examples: MongoDB, CouchDB.                                       |
| Relational    | Enforces a strict schema that organizes data into tables. Very mature and the most widely adopted good for data that has a lot of relations and require transactions. Examples: MySQL, PostgreSQL, MariaDB, Oracle Database.                                                                                                                               |
| Graph         |                                                                                                                                                                                                                                                                                                                                                            |
| Column family |                                                                                                                                                                                                                                                                                                                                                            |
| Time-series   |                                                                                                                                                                                                                                                                                                                                                            |
| Search        |                                                                                                                                                                                                                                                                                                                                                            |