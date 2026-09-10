# Troubleshooting deployments 

## Service is inaccessible, Browser reports service is unavailable

Verify the IP Addresses exposed in DNS using `dig ${DNSNAME}`. 

1. reconfigure the caddyfile of the `proxy` service and add `respond "Hello Test"` to the port 80 configuration. Uncomment or remove the port 443 section to avoid timeouts.
2. redeploy the services using ansible.
3. check the presence of the networks using `docker network ls`.
4. check the presence of the proxy service using `docker service ps sdg_proxy`.
5. check if the proxy service can access using `wget -pSO - http://localhost`. This should always work.
6. check if `sdg_proxy` is accessible from other containers via `ping sdg_proxy`. This should work if the networks are present. 
7. check if `sdg_proxy` is accessible from all containers via `curl http://sdg_proxy` or `wget -qSO - http://sdg_proxy`. In case of problems this will time out.
8. check if **all** exposing hosts can access the exposed ports via localhost using `curl http://localhost`.
9. check if **all** exposing hosts can access the exposed ports via the IP Addresses shown in DNS using `curl http://${DNS_IPADDR}`.
10. check if internal hosts within the same subnet can access the exposed ports via the IP Addresses shown in DNS name using `curl http://${DNS_IPADDR}`.
11. check if external hosts can access the exposed ports via the IP Addresses shown in DNS using  `curl http://${DNS_IPADDR}`.
12. check if **all** exposing hosts can access the exposed ports via DNS name using `curl http://${DNSNAME}`.
13. check if internal hosts within the same subnet can access the exposed ports via DNS name using `curl http://${DNSNAME}`.
14. check if external hosts can access the exposed ports via DNS name using  `curl http://${DNSNAME}`.
15. re-include the HTTPS configuration. 
16. redeploy the services using ansible
17. verify that no certificate failures or timeouts should show up in the logs of `sdg_proxy`.
18. Check if external hosts can access the exposed ports via DNS name using  `curl https://${DNSNAME}`. This should return an empty line. 

 
### Diagnostics: 
 
- if step 3 does not show any overlay networks, check the overall swarm configuration. 
- if in step 4 no proxy service is running,  check the service logs using `docker service logs --since $ISOTIME -t sdg_proxy`. This is typically a configuration error in the `Caddyfile`. 
- If step 5 fails, there is a non-fatal configuration error in the `Caddyfile`. 
- step 6 should not fail at this point. 
- If step 7 and/or 8 fail, it is required to reset the main ingress AND the service network. Normally all overlay networks are affected. If only step 8 fails, run `sudo systemctl restart docker.service` on all swarm nodes. Otherwise continue to section ***Fix Overlay Networks***
- If step 8 works, step 9 MUST work as well.
- If step 10 fails, there is a networking problem at Switch level. This requires more tests to check the network. 
- if step 11 fails, there is a firewall problem. Verify that all ip addresses are exposed correctly. 
- if step 12,13, or 14 fails, there is a DNS problem.
- if step 18 fails, there is a configuration in the `Caddyfile` error. 

### Fix Overlay Networks

To fix the service network just rename the service network in the network section of the config file and redeploy. 

The ingress network is a combined load-balancer and overlay network and only exists implicitly. There can be only one ingress network, although the [documentation](https://docs.docker.com/engine/swarm/networking/) suggests otherwise.
To fix the main ingress network: 

```bash
docker network rm ingress
docker network create --driver overlay --ingress ingress
```

After that the docker daemon has to be restarted on all swarm nodes. Only after the restart, docker accepts any service configurations for the new ingress. 

```bash
sudo systemctl restart docker.service
```

**Note** the `.service` is mandatory, because there are several `systemd` components with the name docker. 
