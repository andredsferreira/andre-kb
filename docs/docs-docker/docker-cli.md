## Docker CLI

### Image Management

| Command                                                  | Description                                                                               |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| docker build -t image_name:version build_context_path    | The build_context_path is usually ".", to indicate the current local directory.           |
| docker build -f dockerfile_path/Dockerfile .             |                                                                                           |
| docker build --pull -t image_name:version .              | The --pull flags updates the base image version.                                          |
| docker build --build-arg BUILD_ARGUMENT=argument_value . | Indicates a build argument that is present in the Dockerfile.                             |
| docker compose --build up                                | Builds (and rebuilds, remove the --build flag if you don't want) with compose.            |
| docker compose down -v                                   | Tears everything down from compose (including volumes, remove -v flag if you don't want). |
| docker images                                            |                                                                                           |
| docker history image_name                                | See layer changes in a image, very useful!                                                |
| docker rmi image_id                                      |                                                                                           |
| docker pull nginx:alpine                                 |                                                                                           |
| docker push myregistry/image_name:version                |                                                                                           |
| docker buildx ls                                         | List build containers for BuildKit                                                        |

### Container Management

| Command                                                                                     | Description                                              |
| ------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| docker run -d --rm --name container_name image_name:latest -p HOST_PORT:CONTAINER_PORT      |                                                          |
| docker run -d --name container_name image_name:latest -p 127.0.0.1:HOST_PORT:CONTAINER_PORT | Only the Docker host can access the published port.      |
| docker run --restart unless-stopped image_name                                              | Restarts the container (unless it was manually stopped). |
| docker container create --name container_name image_name:version                            |                                                          |
| docker ps -a                                                                                |                                                          |
| docker ps -q                                                                                | Only display container ids.                              |
| docker rm container_name                                                                    |                                                          |
| docker start container_name                                                                 |                                                          |
| docker stop container_name                                                                  |                                                          |
| docker restart container_name                                                               |                                                          |
| docker kill container_name                                                                  |                                                          |
| docker update --restart no image_name                                                       | Updates container to the default restart policy.         |

### Logs & Debugging

| Command                                   | Description                                                                                         |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------- |
| docker logs -f container_name             |                                                                                                     |
| docker logs --tail 100 container_name     |                                                                                                     |
| docker logs --since 2h container_name     |                                                                                                     |
|                                           |                                                                                                     |
| docker exec -it container_name bash       |                                                                                                     |
| docker exec container_name ls /home/user/ |                                                                                                     |
| docker container attach container_name    | Attaches host's STDIN, STDOUT, and STDERR to a running container. To dettach use CTRL+p and CTRL+q. |
|                                           |                                                                                                     |
| docker inspect container_name             |                                                                                                     |
| docker stats container_name               |                                                                                                     |

### Volume Management

| Command                                                                                                   | Description                                                                                                                                             |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| docker volume create volume_name                                                                          |                                                                                                                                                         |
| docker volume ls                                                                                          |                                                                                                                                                         |
| docker volume inspect volume_name                                                                         |                                                                                                                                                         |
| docker volume rm volume_name                                                                              |                                                                                                                                                         |
| docker run -d --name container_name --mount type=volume,src=volume_name,dst=mount_path image_name:version | If it's mounted over existing data in the mount_path (inside the container), the data will be hidden (not deleted) until the volume is unmounted again. |

### Network Management

| Command                                               | Description |
| ----------------------------------------------------- | ----------- |
| docker network create --driver bridge network_name    |             |
| docker network ls                                     |             |
| docker network inspect bridge                         |             |
| docker network connect network_name container_name    |             |
| docker network disconnect network_name container_name |             |

### System Management

| Command                          | Description |
| -------------------------------- | ----------- |
| docker system df                 |             |
| docker system info               |             |
| docker version                   |             |
|                                  |             |
| docker system prune -a --volumes |             |
| docker container prune           |             |
| docker volume prune              |             |
| docker network prune             |             |
