#!/bin/bash
source config.sh

function runQuery {
  mysql -u $MYSQLUSER -p$MYSQLPASS $MYSQLDB -e "$1"
}

# All transactions from last 7 days
runQuery '
SELECT
	date,
	description,
	amount,
	transactionType,
	category,
	accountName
FROM transactions
WHERE date > DATE_SUB(NOW(), interval 7 day)
ORDER BY date DESC;
'

# 14 month summary
runQuery '
SELECT
	CONCAT(MONTHNAME(date), " ", YEAR(date)) AS "month",
	COUNT(*) AS "qty",
	SUM(IF(transactionType = "credit", amount, 0)) AS "credits",
	SUM(IF(transactionType = "debit", amount, 0)) AS "debits",
	SUM(IF(transactionType = "credit", amount, IF(transactionType = "debit", -amount, 0))) AS "total"
FROM transactions
WHERE date > CAST(DATE_FORMAT(DATE_SUB(NOW(), interval 13 month), "%Y-%m-01") AS DATE)
GROUP BY month
ORDER BY CAST(DATE_FORMAT(date, "%Y-%m-01") AS DATE) DESC;
'

# 3 month summary per account
runQuery '
SELECT
	CONCAT(MONTHNAME(date), " ", YEAR(date)) AS "month",
	accountName,
	COUNT(*) AS "qty",
	SUM(IF(transactionType = "credit", amount, 0)) AS "credits",
	SUM(IF(transactionType = "debit", amount, 0)) AS "debits",
	SUM(IF(transactionType = "credit", amount, IF(transactionType = "debit", -amount, 0))) AS "total"
FROM transactions
WHERE date > CAST(DATE_FORMAT(DATE_SUB(NOW(), interval 2 month), "%Y-%m-01") AS DATE)
GROUP BY accountName, month
ORDER BY CAST(DATE_FORMAT(date, "%Y-%m-01") AS DATE) DESC, accountName ASC;
'
