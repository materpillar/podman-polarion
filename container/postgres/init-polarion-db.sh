#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER polarion WITH PASSWORD 'polarion' CREATEROLE;
	CREATE DATABASE polarion OWNER polarion ENCODING 'UTF8';;
	CREATE DATABASE polarion_history OWNER polarion ENCODING 'UTF8';
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "polarion" <<-EOSQL
	CREATE EXTENSION dblink;
	SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'public';
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "polarion_history" <<-EOSQL
	CREATE EXTENSION dblink;
	SELECT p.proname FROM pg_catalog.pg_namespace n JOIN pg_catalog.pg_proc p ON p.pronamespace = n.oid WHERE n.nspname = 'public';
EOSQL
