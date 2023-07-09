#!/bin/bash

if [[ -z "$1" ]]; then
  echo "give db endpoint"
  exit 1
fi

# Database credentials
DB_HOST=$1
DB_PORT="5432"
DB_NAME="PostgresTestDb"
DB_USER="postgres"
DB_PASSWORD="12453265"

# SQL statements to create tables
SQL_QUERY_1="CREATE SEQUENCE IF NOT EXISTS public.users_id_seq;"
SQL_QUERY_2="CREATE TABLE IF NOT EXISTS public.users
(
    id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    name character varying(100) COLLATE pg_catalog.\"default\",
    email character varying(100) COLLATE pg_catalog.\"default\",
    CONSTRAINT users_pkey PRIMARY KEY (id)
);"
SQL_QUERY_3="INSERT INTO users (name, email) VALUES
    ('John Doe', 'john.doe@example.com'),
    ('Jane Smith', 'jane.smith@example.com'),
    ('Alice Johnson', 'alice.johnson@example.com');"


# Connect to the database and execute the SQL queries
psql -h $DB_HOST -p $DB_PORT -d $DB_NAME -U $DB_USER -W $DB_PASSWORD -c "$SQL_QUERY_1; $SQL_QUERY_2; $SQL_QUERY_3"

