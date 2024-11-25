# Get IP-Ranges for each Node
kubectl get nodes -o jsonpath='{.items[*].spec.podCIDR}'
