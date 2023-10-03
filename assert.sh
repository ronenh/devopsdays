#!/usr/bin/env bash

TOPAZ_SVC=localhost:9292

NO_COLOR='\033[0m'
OK_COLOR='\033[32;01m'
ERR_COLOR='\033[31;01m'
ATTN_COLOR='\033[33;01m'

echo ">>> check permissions"
cat test/assertions.json | jq -c '.assertions[] | select (first(.check_permission))' | (
    while read BODY; do
        REQ=$(echo $BODY | jq '.check_permission')
        EXP=$(echo $BODY | jq '.expected')
        RSP=$(grpcurl -insecure -d "${REQ}" ${TOPAZ_SVC} aserto.directory.reader.v2.Reader.CheckPermission | jq '.check // false')

        if [ "$EXP" = "$RSP" ]; then
            echo -e "${OK_COLOR}PASS${NO_COLOR} REQ:$(echo ${REQ} | jq -c .)"
        else
            echo -e "${ERR_COLOR}FAIL${NO_COLOR} REQ:$(echo ${REQ} | jq -c .) ${ATTN_COLOR}EXP:$(echo ${EXP} | jq -c .)${NO_COLOR}"
        fi
    done
)
echo "<<< check permissions"
echo -e "\n"

echo ">>> check relations"
cat test/assertions.json | jq -c '.assertions[] | select (first(.check_relation))' | (
    while read BODY; do
        REQ=$(echo $BODY | jq '.check_relation')
        EXP=$(echo $BODY | jq '.expected')
        RSP=$(grpcurl -insecure -d "${REQ}" ${TOPAZ_SVC} aserto.directory.reader.v2.Reader.CheckRelation | jq '.check // false')

        if [ "$EXP" = "$RSP" ]; then
            echo -e "${OK_COLOR}PASS${NO_COLOR} REQ:$(echo ${REQ} | jq -c .)"
        else
            echo -e "${ERR_COLOR}FAIL${NO_COLOR} REQ:$(echo ${REQ} | jq -c .) ${ATTN_COLOR}EXP:$(echo ${EXP} | jq -c .)${NO_COLOR}"
        fi
    done
)
echo "<<< check relations"
echo -e "\n"
