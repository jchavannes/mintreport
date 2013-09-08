#!/bin/bash
source config.sh

if [ -z $CSVDIR ]; then
  echo "Unable to load config file"
  exit 1
fi

FILE=`ls -t $CSVDIR/ | head -n 1`
echo "Using CSV file: '$CSVDIR/$FILE'."

echo "Using MySQL table: $MYSQLTBL"
TMPCSV="/tmp/$MYSQLTBL.csv"

echo "Copying to temp file: '$TMPCSV'..."
cp $CSVDIR/$FILE $TMPCSV

echo "Formatting date..."
sed -i -r 's#([0-9]{1,2})\/([0-9]{2})\/([0-9]{4})#\3-\1-\2#' $TMPCSV
sed -i -r 's#([0-9]{4}-)([0-9]{1})(-[0-9]{2})#\10\2\3#' $TMPCSV

echo "Changing owner to MySQL..."
chown mysql:mysql $TMPCSV

echo "Truncating $MYSQLTBL table..."
mysql -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB -e "TRUNCATE $MYSQLTBL"

echo "Importing CSV data into MySQL..."
mysqlimport -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB --ignore-lines=1 --fields-terminated-by=',' --fields-enclosed-by='"' $TMPCSV
