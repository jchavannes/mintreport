#!/bin/bash
cd "$(dirname "$0")"
REPORTFILE="/tmp/reportfile.txt"
source config.sh

if [ -f $REPORTFILE ]; then
  echo "" > $REPORTFILE
fi

function runQuery {
  echo "Running report '$1'..."
  echo "<p><h3>$1</h3>" >> $REPORTFILE
  mysql -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB -H -e "$2" >> $REPORTFILE
  echo "</p>" >> $REPORTFILE
}

function sendEmail {
  echo "Sending email to $REPORTEMAIL..."
  mail -a "Content-Type: text/html" -s "Daily Report" "$REPORTEMAIL" < $REPORTFILE
}

runQuery "Transactions from last 7 days" '
SELECT
	date,
	description,
	amount,
	transactionType,
	category,
	accountName
FROM transactions
WHERE date > DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY date DESC;
'

runQuery "14 month summary" '
SELECT
	CONCAT(MONTHNAME(date), " ", YEAR(date)) AS "month",
	COUNT(*) AS "qty",
	SUM(IF(transactionType = "credit", amount, 0)) AS "credits",
	SUM(IF(transactionType = "debit", amount, 0)) AS "debits",
	SUM(IF(transactionType = "credit", amount, IF(transactionType = "debit", -amount, 0))) AS "total"
FROM transactions
WHERE date > CAST(DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 13 MONTH), "%Y-%m-01") AS DATE)
GROUP BY month
ORDER BY CAST(DATE_FORMAT(date, "%Y-%m-01") AS DATE) DESC;
'

runQuery "3 month summary per account" '
SELECT
	CONCAT(MONTHNAME(date), " ", YEAR(date)) AS "month",
	accountName,
	COUNT(*) AS "qty",
	SUM(IF(transactionType = "credit", amount, 0)) AS "credits",
	SUM(IF(transactionType = "debit", amount, 0)) AS "debits",
	SUM(IF(transactionType = "credit", amount, IF(transactionType = "debit", -amount, 0))) AS "total"
FROM transactions
WHERE date > CAST(DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 2 MONTH), "%Y-%m-01") AS DATE)
GROUP BY accountName, month
ORDER BY CAST(DATE_FORMAT(date, "%Y-%m-01") AS DATE) DESC, accountName ASC;
'

sendEmail
