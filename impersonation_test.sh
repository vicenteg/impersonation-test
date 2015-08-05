#!/bin/bash

##
# Create a table as the super user, then see that a non super user cannot
# drop it.
#
# Create a table as a regular user, see that the regular user can create and
# drop tables.
##

. assert.bash

WAREHOUSE_PATH='/mapr/*/user/hive/warehouse'
SASL_JDBC_URL='jdbc:hive2://localhost:10000/default;auth=maprsasl;saslQop=auth-conf;ssl=true'
PAM_JDBC_URL='jdbc:hive2://localhost:10000/default;ssl=true'
MAPREDUCE_QUERY="mr_query.sql"
MAPREDUCE_QUERY2="mr_query2.sql"
CREATE_QUERYFILE="create_query.sql"
CREATE_QUERYFILE2="create_query2.sql"
DROP_QUERYFILE="drop_query.sql"
DROP_QUERYFILE2="drop_query2.sql"

SUPERUSER='mapr'
USER='ec2-user'

if [ $1 == "pam" ]; then
	JDBC_URL=$PAM_JDBC_URL
	SUPERUSER_CREDS="-n $SUPERUSER -p mapr"
	USER_CREDS="-n $USER -p mapr"
fi

if [ $1 == "sasl" ]; then
	JDBC_URL=$SASL_JDBC_URL
	SUPERUSER_CREDS=""
	USER_CREDS=""

	echo -n "test that $USER has a current ticket: "
	output=$(maprlogin print)
	if assert "$? -eq 0"; then
		echo ok
	else
		echo "$output"
		exit 1
	fi

	echo -n "test that $SUPERUSER has a current ticket: "
	output=$(maprlogin print)
	if assert "$? -eq 0"; then
		echo ok
	else
		echo "$output"
		exit 1
	fi
fi

echo -n "create table as superuser: should exit 0 (success): "
output=$(sudo -u $SUPERUSER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $SUPERUSER_CREDS -f $CREATE_QUERYFILE 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "check that $SUPERUSER owns the table file: "
owner=$(stat -c "%U" $WAREHOUSE_PATH/pokes);
if  assert "$owner == $SUPERUSER"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "create table as regular user: should exit 0 (success): "
output=$(sudo -u $USER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $USER_CREDS -f $CREATE_QUERYFILE2 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "check that $USER owns the table file: "
owner=$(stat -c "%U" $WAREHOUSE_PATH/pokes2)
if assert "$owner == $USER"; then
	echo ok
else
	echo $output
	exit 1
fi

echo -n "submit query as $USER that triggers mapreduce job: "
output=$(sudo -u $USER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $USER_CREDS -f $MAPREDUCE_QUERY2 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "submit query as $SUPERUSER that triggers mapreduce job: "
output=$(sudo -u $SUPERUSER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $USER_CREDS  -f $MAPREDUCE_QUERY 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi


echo -n "drop table created by regular user as regular user. Should exit 0 (success): "
output=$(sudo -u $USER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $USER_CREDS -f $DROP_QUERYFILE2 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "drop table created by superuser as regular user. Should exit 2 (fail): "
output=$(sudo -u $USER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $USER_CREDS -f $DROP_QUERYFILE 2>&1 )
if assert "$? -eq 2"; then
	echo ok
else
	echo "$output"
	exit 1
fi

echo -n "drop table create by superuser as superuser. Should exit 0 (success): "
output=$(sudo -u $SUPERUSER /opt/mapr/hive/hive-1.0/bin/beeline -u "$JDBC_URL" $SUPERUSER_CREDS -f $DROP_QUERYFILE 2>&1 )
if assert "$? -eq 0"; then
	echo ok
else
	echo "$output"
	exit 1
fi

