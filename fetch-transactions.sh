#!/bin/bash
cd "$(dirname "$0")"
COOKIEFILE="/tmp/cookie-mint.txt"
USEOLDCOOKIE=true

source config.sh

if [ -z $CSVDIR ]; then
  echo "Unable to load config file. Exiting."
  exit 1
fi

if [ ! -d $CSVDIR ]; then
  echo "CSV directory does not exist. Exiting."
  exit 1
fi

CSVFILE="$CSVDIR/$(date +"%Y-%m-%d_%H-%M-%S").csv"

if [ -f $COOKIEFILE ]; then
  if ! $USEOLDCOOKIE; then
    echo "" > $COOKIEFILE
    echo "Cleared cookie file."
  fi
else
  touch $COOKIEFILE
  echo "Created cookie file."
fi

function checkLoggedIn {
  URL="https://wwws.mint.com/overview.event"
  LINES=`curl -v -b $COOKIEFILE -c $COOKIEFILE $URL 2>&1 | wc -l`
  if [ $LINES -gt 75 ]; then
    echo "Currently logged in."
    ISLOGGEDIN=true
  else
    echo "Not logged in."
    ISLOGGEDIN=false
  fi
}

checkLoggedIn

if ! $ISLOGGEDIN; then

  echo "Submitting login form..."
  URL="https://wwws.mint.com/loginUserSubmit.xevent"
  DATA="username=$USERNAME&password=$PASSWORD&task=L"
  curl -v -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "$DATA" -b $COOKIEFILE -c $COOKIEFILE $URL &>/dev/null

  checkLoggedIn

  if ! $ISLOGGEDIN; then
    echo "Error logging in. Exiting."
    exit 1
  fi

fi

if [ $1 == "loginonly" ]; then
  echo "Login only flag detected. Exiting."
  exit 0
fi

echo "Fetching transactions..."
URL="https://wwws.mint.com/transactionDownload.event"
curl -b $COOKIEFILE -c $COOKIEFILE $URL 2>/dev/null > $CSVFILE
echo "Transactions saved to: $CSVFILE"
