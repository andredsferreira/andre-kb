Running on the EC2 instance manually:

```bash
docker run -d \
  --name lab05 \
  --restart unless-stopped \
  -p 8080:8080 \
  -e DB_SECRET_ID='rds!db-f7f32c46-58b7-442b-ab30-82b02387ee3e' \
  -e PSQL_HOST=terraform-98f7738dd7247086f722c65595.c70myqw8u1g1.eu-west-2.rds.amazonaws.com \
  -e PSQL_PORT=5432 \
  -e PSQL_USER=lab05 \
  -e PSQL_DATABASE=lab05 \
  -e AWS_REGION=eu-west-2 \
  andredsferreiraa/lab05:latest
```
