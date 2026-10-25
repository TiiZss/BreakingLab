FROM tiizss/mysql-5.7:5.7
COPY init.sql /docker-entrypoint-initdb.d/01-bricks.sql
