jrubysql
========
JDBC-backed SQL client for any RDBMS with JDBC driver. Only runs on JRuby.

Installation
------------
```
gem install jrubysql
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
# Supports MySQL/Oracle/PostgreSQL/MSSQL

jrubysql -t mysql -h localhost -d test -u user -p
jrubysql -t oracle -h localhost:1521/orcl -u user -p password
jrubysql -t postgres -h localhost -u root
jrubysql -t sqlserver -h 192.168.62.26 -u user -p password
```

### Connect with class name of JDBC driver (-c) and JDBC URL (-j)

```
# You can connect to any database with its JDBC driver

bin/jrubysql -corg.postgresql.Driver -jjdbc:postgresql://localhost/test
bin/jrubysql -ccom.mysql.jdbc.Driver -jjdbc:mysql://localhost/test -uuser -p
```

TODO
----
TESTS!!!

Copyright
---------
Copyright (c) 2012 Junegunn Choi. See LICENSE.txt for
further details.

