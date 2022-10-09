FROM postgres:11-bullseye

COPY init-polarion-db.sh /docker-entrypoint-initdb.d/