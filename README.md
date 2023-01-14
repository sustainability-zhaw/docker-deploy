# docker-deploy

An Ansible playbook for deploying the SDG Dashboard on Docker Swarm.

## Deployment

This repository uses the auto deployment feature of the `ghcr.io/phish108/ansible-docker:7.1.3-2` container.

```
docker run -it --rm 
           -v ${PRIVATE_SSH_KEYS}:/sshkeys \
           -v ${INVENTORY_PATH}:/inventory \
           -v ${CONFIGS_PATH}:/configs \
           -v $(pwd):/ansible \
           ghcr.io/phish108/ansible-docker:7.1.3-2
```

## Preparations 

**Important** This repository needs to be complemented by a host inventory, configs, secrets, local settings, and, of course, **private ssh keys**.

It is recommended to have two separate ***private*** repositories for these purposes: 

The first repository should hold the host inventory of the docker swarm. This repository needs to provide the file `/inventory/main.yaml` and `/inventory/known_hosts` to the playbook.

The second repository needs to provide the following files:

- `Caddyfile` - for configuring the reverse proxy.
- `authomator_config.yaml` - for preparing OAuth2/OIDC connections with IDPs. 
- `ad_resolver.json` - for providing access to the organisational LDAP/Active Directory system.
- `configs.yaml` - for providing configuration options for for the different components. 

The playbook `main.yaml` expects these files under `/configs`.

Finally, you need private keys for the connecting to the servers. These keys should be ***local*** to the machine that you are using or at least secrets to the used cicd platform. For these processes I have a separate set of connection keys, stored in the folder `~/.autossh`. This separates my personal keys from deployment keys. 
