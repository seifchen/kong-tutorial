#! /usr/bin/env bash
docker run -d -p 1337:1337 --network kong-net \
	-e "DB_ADAPTER=postgres" \
	-e "DB_HOST=kong-database" \
	-e "DB_PORT=5432"  \
	-e "DB_USER=${KONG_PG_USER}" \
	-e "DB_PASSWORD=${KONG_PG_PWD}" \
	-e "DB_DATABASE=kong" -e "NODE_ENV=development" \
	--name konga \
	pantsel/konga
