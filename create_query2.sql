DROP TABLE IF EXISTS pokes2;
CREATE TABLE pokes2 (foo INT, bar STRING);
LOAD DATA LOCAL INPATH '/opt/mapr/hive/hive-1.0/examples/files/kv1.txt'
	OVERWRITE INTO TABLE pokes2;
