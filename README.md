# docker-deploy

An Ansible playbook for deploying the SDG Dashboard on Docker Swarm.

## Deployment

This repository uses the auto deployment feature of the `ghcr.io/phish108/ansible-docker:7.2.0-1` container.

```
docker run -it --rm 
           -v ${PRIVATE_SSH_KEYS}:/sshkeys \
           -v ${INVENTORY_PATH}:/inventory \
           -v ${CONFIGS_PATH}:/configs \
           -v $(pwd):/ansible \
           ghcr.io/phish108/ansible-docker:7.2.0-1
```

## Preparations 

**Important** This repository needs to be complemented by a host inventory, configs, secrets, local settings, and, of course, **private ssh keys**.

It is recommended to have two separate ***private*** repositories for these purposes: 

The first repository should hold the host inventory of the docker swarm. This repository needs to provide the file `/inventory/main.yaml` and `/inventory/known_hosts` to the playbook.

The second repository needs to provide the following files:

- `Caddyfile` - for configuring the reverse proxy.
- configuration files for the different components. Namely: ad_resolver, authomator, extractor, indexer, and webhook. 
- `configs.yaml` - for providing configuration options for for the different components. 
- `containers.yaml` - with the latest container sha for the deployment.

The playbook `main.yaml` expects these files under `/configs`.

Finally, you need private keys for the connecting to the servers. These keys should be ***local*** to the machine that you are using or at least secrets to the used cicd platform. For these processes I have a separate set of connection keys, stored in the folder `~/.autossh`. This separates my personal keys from deployment keys. 

The deployment installs a protected [graphiql](https://github.com/graphql/graphiql/blob/main/examples/graphiql-cdn/index.html) instance.

The layout of the inventory configs is as follows: 

- `Caddyfile` - the configuration of the caddy TLS termination and reverse proxy
- `configs.yaml` - docker swarm settings that are specific to the instance
- `containers.yaml` - docker image tags to deploy
- `graphiql`
  - `index.html` - self loading and self maintaining graphiql instance
- `services`
  - `ad_resolver`
    -  `ad_resolver.json` - config file for ad-resolver (!! contains credentials !!)
  - `authomator` 
    - `authomator_config.yaml` 
    - `keys.jwks` - private keys for signing and encryption (!! credentials !!)
    - `pubkeys.jwks`  - public keys for signing and encryption
  - `extractor` 
    - `digitial_collection.json` - configuration for the OAI extrator
    - `evento.json` - configuration for the Evento Spider
  - `indexer`
    - `config.json` - configuration for the indexer
  - `webhook`
    - `config.json` - configuration for the keywords-webhook endpoint (!! contains credentials !!)

 Structure of the `containers.yaml` file: 

 ```yaml
containers:
  dashboard_sha: 7d191b6
  adresolver_sha: b73cba8
  schema_sha: a719f16
  authomator_sha: df07b2d
  dspace_sha: e48a854
  evento_sha: d58f8d3
  sdgindexer: 459a702
  keywords: 44ddb4e
 ```