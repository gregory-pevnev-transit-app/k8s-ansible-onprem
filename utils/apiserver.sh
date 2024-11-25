# Public
curl -k https://34.170.215.229:6443/livez?verbose

# Private
kubectl get --raw='/readyz?verbose'
