#!/bin/sh
#
# convert mysql slow query log to CSV
# and import into ElasticSearch
#
# requires python and esimport
# > pip install esimport
#
# Author: Brent Ashley <bashley@controlcase.com>
#

logfile=$1
if [ -z $logfile ]
then
	echo Syntax: $0 mysql_slow_log_file
	exit 1
fi

echo Parsing $logfile into CSV file...
# remove any high order ascii characters with tr
cat $logfile | tr -d '[\200-\377]' | awk -f mysql-slow-log-to-csv.awk > slow.csv

echo Importing CSV to elasticsearch...
python -m esimport -s localhost:9200 -f slow.csv -i logs -t mysql_slow -m mysql-slow-es-map.json -rm

