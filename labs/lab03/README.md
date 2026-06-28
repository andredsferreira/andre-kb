### LAB03: Containerizing Go Application

**Description**

The main purpose of this lab is to properly setup a containerized
(using Docker) application written in Go. Thus, the focus is on
guaranteeing that there is a good setup of DEV environment (using
Docker Compose) and there is a production ready (or as close as
possible) CI/CD pipeline. This means the Go code itself it's not
production ready and may not follow the best patterns for a production
use case, or a particular use case.

**Running**

This command runs the application and also rebuilds (remove the
--build flag if you don't want to rebuild, just remember that any
modifications to the source code will need to be rebuilt in order to
be seen).

NOTE: Run the command on this directory.

```bash
docker compose up --build -d
```

**Stopping**

Just stops the app and removes the containers and networks.

```bash
docker compose down
```

**Cleaning**

This will also remove the named volumes and thus the DB data.

```bash
docker compose down -v
```
