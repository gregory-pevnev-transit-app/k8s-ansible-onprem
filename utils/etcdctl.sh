export ETCDCTL_API=3
export ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt
export ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key

etcdctl --endpoints https://localhost:2379 put foo bar
etcdctl --endpoints https://localhost:2379 get foo

etcdctl --endpoints https://localhost:2379 check perf
