#!/usr/bin/env bash

TOPAZ_SVC=localhost:8282

NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERR_COLOR='\033[31;01m'
ATTN_COLOR='\033[33;01m'

echo ">>> check decisions"
cat test/decisions.json | jq -c '.decisions[] ' | (
    while read BODY; do
        REQ=$(echo $BODY | jq '.is_req')
        EXP=$(echo $BODY | jq '.expected')

        RSP=$(grpcurl -insecure -d "${REQ}" ${TOPAZ_SVC} aserto.authorizer.v2.Authorizer.Is | jq '.decisions[].is // false')

        if [ "$EXP" = "$RSP" ]; then
            echo -e "${OK_COLOR}PASS${NO_COLOR} REQ:$(echo ${REQ} | jq -c .)"
        else
            echo -e "${ERR_COLOR}FAIL${NO_COLOR} REQ:$(echo ${REQ} | jq -c .) ${ATTN_COLOR}EXP:$(echo ${EXP} | jq -c .)${NO_COLOR}"
        fi
    done
)
echo "<<< check decisions"
echo -e "\n"
