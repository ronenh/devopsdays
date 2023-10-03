SHELL 	   := $(shell which bash)

NO_COLOR   :=\033[0m
OK_COLOR   :=\033[32;01m
ERR_COLOR  :=\033[31;01m
WARN_COLOR :=\033[36;01m
ATTN_COLOR :=\033[33;01m

VERSION    ?= $(shell svu)
COMMIT     ?= $(shell git rev-parse --short HEAD 2>/dev/null)
DATE       ?= $(shell date "+%FT%T%z")
GOPATH     ?= $(shell go env GOPATH)
TOPAZ	   ?= /Users/ronenhilewicz/aserto-dev/topaz/dist/topaz_darwin_arm64/topaz

POLICY_HOST  := ghcr.io
POLICY_ORG   := ronenh
POLICY_REPO  := devopsdays
POLICY_TAG   := latest
POLICY_IMAGE := ${POLICY_HOST}/${POLICY_ORG}/${POLICY_REPO}:${POLICY_TAG}
POLICY_NAME  := ${POLICY_REPO}

CONTAINER_NAME := topaz
CONTAINER_VERSION := console03

.PHONY: all
all: manifest data test

.PHONY: test-all
test-all: clean configure manifest data test

.PHONY:
version:
	@${TOPAZ} version

.PHONY: install
install:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} stop
	@${TOPAZ} install --container-name=${CONTAINER_NAME} --container-version=${CONTAINER_VERSION}

.PHONY: configure
configure: grpc-health-probe-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} stop
	@${TOPAZ} configure --policy-name ${POLICY_NAME} --resource=${POLICY_IMAGE} -d
	@${TOPAZ} start --container-name=${CONTAINER_NAME} --container-version=${CONTAINER_VERSION}
	@grpc-health-probe -addr=localhost:8484 -connect-timeout=30s -rpc-timeout=30s

.PHONY: configure-local
configure-local: grpc-health-probe-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} stop
	@${TOPAZ} configure --policy-name ${POLICY_NAME}  --local-policy-image ${POLICY_IMAGE} -d
	@${TOPAZ} start --container-name=${CONTAINER_NAME} --container-version=${CONTAINER_VERSION}
	@grpc-health-probe -addr=localhost:8484 -connect-timeout=30s -rpc-timeout=30s

.PHONY: manifest
manifest:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} load ./model/manifest.yaml --insecure --no-check

.PHONY: data
data:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@cat ./data/citadel.json | ds-load publish -i

.PHONY: test
test:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} test exec ./test/assertions.json --insecure --no-check --summary
	@${TOPAZ} test exec ./test/decisions.json --insecure --no-check --summary

.PHONY: graph
graph: rel2dot-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@rel2dot --input data/relations.json -f | dot -Tpng > relations.png

.PHONY: clean
clean: grpc-health-probe-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} stop
	@rm ${HOME}/.config/topaz/db/directory.db
	@${TOPAZ} start --container-name=${CONTAINER_NAME} --container-version=${CONTAINER_VERSION}
	@grpc-health-probe -addr=localhost:8484 -connect-timeout=30s -rpc-timeout=30s

.PHONY: build
build:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@policy build rego --tag ${POLICY_HOST}/${POLICY_ORG}/${POLICY_REPO}:${POLICY_TAG}

.PHONY: push
push:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@policy push ${POLICY_HOST}/${POLICY_ORG}/${POLICY_REPO}:${POLICY_TAG}

.PHONY: restart
restart: grpc-health-probe-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@${TOPAZ} stop
	@${TOPAZ} start --container-name=${CONTAINER_NAME} --container-version=${CONTAINER_VERSION}
	@grpc-health-probe -addr=localhost:8484 -connect-timeout=30s -rpc-timeout=30s

.PHONY: grpcui
grpcui: grpcui-bin
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@(grpcui -insecure -port 58282 -open-browser localhost:8282 &) &> /dev/null
	@(grpcui -insecure -port 59292 -open-browser localhost:9292 &) &> /dev/null
	@echo -e "${WARN_COLOR}authorizer http://localhost:58282 ${NO_COLOR}"
	@echo -e "${WARN_COLOR}directory  http://localhost:59292 ${NO_COLOR}"

.PHONY: ${GOPATH}/bin/grpcui
grpcui-bin:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@go install github.com/fullstorydev/grpcui/cmd/grpcui@latest

.PHONY: ${GOPATH}/bin/grpcurl
grpcurl-bin:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

.PHONY: ${GOPATH}/bin/grpc-health-probe
grpc-health-probe-bin:
	@echo -e "${ATTN_COLOR}==> $@ ${NO_COLOR}"
	@go install github.com/grpc-ecosystem/grpc-health-probe@latest
