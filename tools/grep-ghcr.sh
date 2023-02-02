#!/bin/sh

echo "containers:" > configs/containers.yaml
echo -n "  dashboard_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/sustainability-dashboard/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  adresolver_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/ad-resolver/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  schema_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/dgraph-schema/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  authomator_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/phish108/authomator/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  dspace_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/extraction-dspace/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  evento_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/extraction-evento/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  sdgindexer_sha: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/sdg-indexer/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
echo -n "  keywords: " >> configs/containers.yaml
curl -s https://api.github.com/repos/sustainability-zhaw/keywords/git/refs | jq -r '.[] | select(.ref == "refs/heads/main") | .object.sha[0:7]' >> configs/containers.yaml
