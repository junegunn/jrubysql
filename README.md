jrubysql
========
An SQL client for any JDBC-compliant database. Written in JRuby.

Installation
------------

```
gem install jrubysql
```

Usage
-----

```
usage: jrubysql [options]
       jrubysql -t DBMS_TYPE -h HOSTNAME [-u USERNAME] [-p [PASSWORD]] [-d DATABASE]
       jrubysql -c CLASSNAME -j JDBC_URL [-u USERNAME] [-p [PASSWORD]] [-d DATABASE]

    -t, --type DBMS_TYPE             Database type: mysql/oracle/postgres/sqlserver/cassandra
    -h, --host HOST                  DBMS host address

    -c, --class-name CLASSNAME       Class name of the JDBC driver
    -j, --jdbc-url JDBC_URL          JDBC URL for the connection

    -u, --user USERNAME              Username
    -p, --password [PASSWORD]        Password
    -d, --database DATABASE          Name of the database (optional)

    -f, --filename FILENAME          SQL script file
    -e, --execute SQLSCRIPT          SQL script
    -o, --output OUTPUT_TYPE         Output type: cterm|term|csv (default: cterm)

        --help                       Show this message
        --version                    Show version
```

Connecting to the database
--------------------------

### Setting up CLASSPATH
Add the appropriate JDBC drivers to the CLASSPATH.

```
export CLASSPATH=$CLASSPATH:~/lib/mysql-connector-java-5.1.17-bin.jar:~/lib/ojdbc6.jar
```

### With type (-t) and hostname (-h)

```
# Supports MySQL/Oracle/PostgreSQL/MSSQL/SQLite/Cassandra CQL3

jrubysql -t mysql -h localhost -d test -u user -p
jrubysql -t oracle -h localhost:1521/orcl -u user -p password
jrubysql -t postgres -h localhost -u root
jrubysql -t sqlserver -h localhost -u user -p password

jrubysql -t sqlite -h my.db                     # For SQLite, host = DB file

jrubysql -t cassandra -h localhost
jrubysql -t cassandra -h localhost -d keyspace  # Optional keyspace
```

### Connect with class name of JDBC driver (-c) and JDBC URL (-j)

```
# You can connect to any database with its JDBC driver
# SQLite
bin/jrubysql -c org.sqlite.JDBC -j jdbc:sqlite:my.db

# PostgreSQL
bin/jrubysql -corg.postgresql.Driver -jjdbc:postgresql://localhost/test

# MySQL
bin/jrubysql -ccom.mysql.jdbc.Driver -jjdbc:mysql://localhost/test -uuser -p
```

Screenshot
----------
![](https://github.com/junegunn/jrubysql/raw/master/screenshots/simpsons.png)

Copyright
---------
Copyright (c) 2012 Junegunn Choi. See LICENSE.txt for
further details.

