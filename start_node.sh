#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "$DIR/.env"

$BINARY_FILE \
--datadir "$DATA_DIR" \
--syncmode "full" \
--ws \
--rpc \
--rpcaddr 0.0.0.0 \
--rpcport 8545 \
--wsaddr 0.0.0.0 \
--wsport 8546 \
--port 30311 \
--rpccorsdomain "*" \
--wsorigins "*" \
--rpcvhosts "*" \
--networkid 88 \
--identity $NODE_NAME \
--keystore $KEYSTORE_DIR \
--password $PASSWORD_FILE \
--announce-txs \
--ethstats "$NODE_NAME:$WS_SECRET@$NETSTATS_HOST:$NETSTATS_PORT" \
--verbosity 4 > $TOMO_DEFAULT_PATH/logs/fullnode.txt 2>&1