#!/usr/bin/env bash

TOPAZ_SVC=localhost:8282

cat test/queries.json | jq -c '.queries[] ' | (
    while read BODY; do
        REQ=$(echo $BODY | jq '.query_req')
        RSP=$(grpcurl -insecure -d "${REQ}" ${TOPAZ_SVC} aserto.authorizer.v2.Authorizer.Query )
        echo $RSP
    done
)
