#!/bin/bash
cd "$(dirname "$0")"
echo "Starting daily run..."
./fetch-transactions.sh
./process-transactions.sh
./run-reports.sh
echo "Daily run complete."
