#!/bin/sh
host="${POSTGRES_HOST:-127.0.0.1}"
user="${POSTGRES_USER:-postgres}"
db="${POSTGRES_DB:-$POSTGRES_USER}"
export PGPASSWORD="${POSTGRES_PASSWORD:-}"

# Try simple SELECT 1 using psql
result=$(psql \
    --host "$host" \
    --username "$user" \
    --dbname "$db" \
    --quiet --no-align --tuples-only \
    -c "SELECT 1" 2>/dev/null)

# If result equals 1 → success
if [ "$result" = "1" ]; then
    exit 0
fi

exit 1

#set -eo pipefail
#host="${POSTGRES_HOST:-127.0.0.1}"

#host="$(hostname -i || echo '127.0.0.1')"
#user="${POSTGRES_USER:-postgres}"
#db="${POSTGRES_DB:-$POSTGRES_USER}"
#export PGPASSWORD="${POSTGRES_PASSWORD:-}"

#args=(
	# force postgres to not use the local unix socket (test "external" connectibility)
#	--host "$host"
#	--username "$user"
#	--dbname "$db"
#	--quiet --no-align --tuples-only
#)

#if select="$(echo 'SELECT 1' | psql "${args[@]}")" && [ "$select" = '1' ]; then
#	exit 0
#fi

#exit 1
