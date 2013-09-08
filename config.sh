#!/bin/bash
USERNAME="username@email.com"
PASSWORD="password"
CSVDIR="~/"
MYSQLUSER="root"
MYSQLPASS="root"
MYSQLDB="dbname"
MYSQLTBL="transactions"
REPORTEMAIL="name@email.com"

LOCALCONFIG="config.local.sh"
if [ -f $LOCALCONFIG ]; then
  echo "Using local config file."
  source $LOCALCONFIG
else
  echo "File not found: '$LOCALCONFIG'"
fi
