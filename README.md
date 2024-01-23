# docker-deploy

An Ansible playbook for deploying the SDG Dashboard to a Docker Swarm.

This is part of the open deployment strategy. This strategy consists of three repositories: 

1. The System Inventory 
2. The Support Files
3. The Ansible Playbook (this repository)

**Important** Both the System Inventory and the Support Files are and remain private.

## Deployment

This playbook expects an inventory with at least one `mainnode` host configured. The playbook expects that the host is a master node of a docker swarm and that the inventory user is capable to run all docker commands without requireing a password. 

This repository uses the auto deployment feature of the `phish108/ansible:9.1.0-2` container image. 

If all repos have been cloned adjacent to each other, one can use `docker compose run`

```
docker compose run --rm deploy
```

The compose file expects to have the following repository names: 

- `.` -> `/ansible`
- `~/.autossh` -> `/sshkeys` (for password free ssh keys)
- `../deploy-configs` -> `/configs` 
- `../inventory-docker` -> `/inventory`


For more fine grained control: 

```
docker run -it --rm 
           -v ${PRIVATE_SSH_KEYS}:/sshkeys \
           -v ${INVENTORY_PATH}:/inventory \
           -v ${SUPPORT_FILES_PATH}:/configs \
           -v $(pwd):/ansible \
           phish108/ansible:9.1.0-2
```

## Preparations 

**Important** This repository needs to be complemented by a host inventory, configs, secrets, local settings, and, of course, **private ssh keys**.

It is recommended to have two separate ***private*** repositories for these purposes: 

The first repository should hold the host inventory of the docker swarm. This repository needs to provide the file `/inventory/main.yaml` and `/inventory/known_hosts` to the playbook.

The second repository needs to provide the support files with the service configuration.

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
  - `message-queue`
    - `rabbitmq.conf` - the main rabbitmq configuration, mostly loading the definitions for users and exchanges
    - `00-users.json` - the user config for identifiable services
    - `02-queues-exchanges.json` - definition for all queues and exchanges
  - `webhook`
    - `config.json` - configuration for the keywords-webhook endpoint (!! contains credentials !!)

The Structure of the `containers.yaml` file: 

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

The containers.yaml file provides the reference to the the most recent versions of the service containers. 

## Configuration of the message queue

The message is handled by rabbitmq. 

The minimum configuration for our purposes is provided in `contrib/message-queue`. 

The configuration is designed as such, so the the definitions for users, exchanges, queues etc. are configured separately under `/etc/rabbitmq/definitions.d/` in the rabbitmq container.

Important note:

The configuration of the services must match rabbitmq's definition, otherwise the system won't work. 

- The service names for connecting to the message queue should not be touched. The default is the name of the service.

- The passwords match the passwords set in rabbitmq and in the respective service. The default is  `guest`.

- The main exchange must match for ALL services and the message queue. The default is in local development `zhaw-km`, in dev-deployment `zhaw_content`.

If services appear not to work do the following: 

1. Check the username and password configuration of all services to match those set for rabbitmq.
2. Check the exchange name of all services use the same configuration as rabbitmq.
