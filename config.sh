#!/bin/bash
USERNAME="username@email.com"
PASSWORD="password"
CSVDIR="~/"

LOCALCONFIG="config.local.sh"
if [ -f $LOCALCONFIG ]; then
  echo "Using local config file."
  source $LOCALCONFIG
fi
