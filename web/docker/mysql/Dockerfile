ARG mysql_version

FROM mysql:${mysql_version}
ADD ./init.sql /docker-entrypoint-initdb.d/
