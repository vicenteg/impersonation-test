#!/bin/bash 

##
# Create a table as the super user, then see that a non super user cannot
# drop it.
# 
# Create a table as a regular user, see that the regular user can create and
# drop tables.
##

. assert.bash

JDBC_URL='jdbc:hive2://localhost:10000/default;saslQop=auth-conf;ssl=true'
CREATE_QUERYFILE="create_query.sql"
CREATE_QUERYFILE2="create_query2.sql"
DROP_QUERYFILE="drop_query.sql"
DROP_QUERYFILE2="drop_query2.sql"

SUPERUSER='mapr'
SUPERUSER_PASS='mapr'

USER='ec2-user'
PASS='mapr'

echo -n "create table as superuser: should exit 0 (success): "
output=$(/opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" -n $SUPERUSER -p $SUPERUSER_PASS -f $CREATE_QUERYFILE 2>&1 ) ; assert "$? -eq 0" && echo ok

echo -n "create table as regular user: should exit 0 (success): "
output=$(/opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" -n $USER -p $PASS -f $CREATE_QUERYFILE2 2>&1 ) ; assert "$? -eq 0" && echo ok

echo -n "drop table created by regular user as regular user. Should exit 0 (success): "
output=$(/opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" -n $USER -p $PASS -f $DROP_QUERYFILE2 2>&1 )  ; assert "$? -eq 0" && echo ok

echo -n "drop table created by superuser as regular user. Should exit 2 (fail): "
output=$(/opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" -n $USER -p $PASS -f $DROP_QUERYFILE 2>&1 )  ; assert "$? -eq 2" && echo ok

echo -n "drop table create by superuser as superuser. Should exit 0 (success): "
output=$(/opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" -n $SUPERUSER -p $SUPERUSER_PASS -f $DROP_QUERYFILE 2>&1 ) ; assert "$? -eq 0" && echo ok

