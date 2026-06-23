docker build -f Dockerfile -t image_name:version .
docker build --pull -f Dockerfile -t image_name:version .

docker container prune
docker image prune
docker volume prune
docker network prune

docker system df

docker run --rm -d --name container_name image_name:version
docker run --rm -d --name container_name --mount nam