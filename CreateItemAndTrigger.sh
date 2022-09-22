#! /bin/bash

ZABBIX_USER="Admin"
ZABBIX_PASS="zabbix"
ZABBIX_API="http://192.168.126.152/api_jsonrpc.php"


ZABBIX_AUTH_TOKEN=$(curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${ZABBIX_USER}"\",\"password\":\""${ZABBIX_PASS}"\"},\"auth\": null,\"id\":0}" $ZABBIX_API |  jq -r .result)

GET_HOST_ID=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"item.create\",
    \"params\": {
        \"name\": \"$1\",
        \"key_\": \"snmptrap[$2]\",
        \"hostid\": \"10529\",
        \"type\": 17,
        \"value_type\": 2,
        \"tags\": [
            {
                \"tag\": \"Application\",
                \"value\": \"Trap\"
            }
        ],
        \"delay\": \"{\$UPDATE_INTERVAL_PORT}\"
    },
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
)

echo $GET_HOST_ID

AFF=$(curl -s -H 'Content-Type: application/json-rpc' -d "

{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": [
        {
            \"description\": \"{TRAP} $1\",
            \"expression\": \"length(last(/B3_CPQSM2-MIB/snmptrap[$2]))>=1\",
            \"priority\": \"$3\"
        }
    ],
    \"auth\": \"${ZABBIX_AUTH_TOKEN}\",
    \"id\": 1
}" ${ZABBIX_API}
)
echo $AFF
