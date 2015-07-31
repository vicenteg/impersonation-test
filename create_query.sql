CREATE TABLE IF NOT EXISTS pokes (foo INT, bar STRING);
LOAD DATA LOCAL INPATH '/opt/mapr/hive/hive-1.0/examples/files/kv1.txt'
	OVERWRITE INTO TABLE pokes;
SELECT * FROM pokes;
