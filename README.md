# devopsdays

DevOpsDays Indy 2023 demo

## Prerequisites:
* Install topaz, using `brew install aserto-dev/tap/topaz`
* Install the policy CLI, using `brew install opcr-io/tap/policy`
* Install golang, using `brew install golang`
* Install graphviz, using `brew install graphviz`
* Install jq, using ` brew install jq`
* Install grpcurl, using ` brew install grpcurl`


## Getting started

* Clone the repo `git clone https://github.com/aserto-proj/devopsdays.git`

* `cd devopsdays` all the following commands must be executed from the root of the cloned directory!

* `make install` will install the required version of the `topaz` container image.

* `make build` will compile the OPA policy in the `rego` directory, using `policy build rego --tag ghcr.io/aserto-proj/devopsdays:latest`.

* `make push` will publish the OPA policy container image to `ghcr.io`, using `policy push ghcr.io/aserto-proj/devopsdays:latest`.

* `make configure` will configure the authorizer to use the published policy container image.

* `make manifest` will load the manifest into the edge directory instance, using `topaz load ./model/manifest.yaml`.

* `make data` will load the objects and relations defined in the `data` directory into the edge directory instance, using `topaz import --directory=./data`.

* `make test` will run the `check` assertions, which are defined in `test/assertions.json` to validate the correctness of the authorization model, using the `assert.sh` script, which executes the gRPC `aserto.directory.reader.v2.Reader.CheckPermission` and `aserto.directory.reader.v2.Reader.CheckRelation` calls against the edge directory instance.

* `make graph` will create a graphical visualization of the `data/relations.json` data, using

## Making changes

The following describes the required actions after making changes.

### Changing the `manifest.yaml`
When changing the manifest, redeploy the manifest using:

```make manifest```

### Changing the `data/*.json`
When changing the data, `objects.json` or `relations.json`, redeploy the data using

```make data```

### Changing the OPA policy `rego/*`
When changing the OPA rego policy in the `rego` directory, rebuild and publish the policy using:

```
make build
make push
```

### Resetting the edge directory
To reset the setup execute:

```
make clean
```

This will remove the edge directory data store and configuration file located in:

```
$HOME/.config/topaz/cfg/config.yaml
$HOME/.config/topaz/db/directory.db
```

### Working locally
Shortcut to build (and validate the rego) and test:

```
make build && make configure-local && sleep .5 && make manifest && make data && make test
```
