## C-Groups configuration

It is necessary to configure C-Groups the following way for correct runtime:
1. Using version 1 (Un-unified) -> `systemd.unified_cgroup_hierarchy=0`
  1. Makes sure `memory.max_usage_in_bytes` and `memory.memsw.max_usage_in_bytes` are present
  2. The equivalent files are not available on C-Groups V2 until 6.15
2. Recording swap-space usage usage alongside memory usage -> `swapaccount=1` => Enables `memory.memsw.*`

Configure with:
```sh
# 1) Configure the c-groups version in the GRUB
sudo vim /etc/default/grub
# Parameters:
#   GRUB_CMDLINE_LINUX_DEFAULT="systemd.unified_cgroup_hierarchy=0 swapaccount=1"
#   GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0 swapaccount=1"

# 2) Update the GRUB -> Configures C-Groups => Still requires a reboot of the system
sudo update-grub

# 3) Rebooting the system
sudo reboot
```

## Kernel modules

Check with:
```sh
cut -f1 -d " "  /proc/modules | grep -e overlay -e nf_conntrack -e br_netfilter -e ip_vs
```

## ContainerD

Can add the current user to the ContainerD users group via `sudo usermod -a -G containerd-users "$USER"` to check that ContainerD service is running properly.

```sh
# Checking connectivity
ctr version

# Checking whether an image can be pulled
ctr image pull docker.io/library/nginx:latest
ctr image ls

# Checking whether a container can be run from the pulled image
#    -> Requires admin-level permission
sudo ctr run docker.io/library/nginx:latest nginx-tester

# Checking and connecting to the task
# Note: Use `ctr -n=k8s.io ...` for K8s / CRI-CTL integration
ctr tasks list
sudo ctr tasks exec -t --exec-id shell TASK sh
sudo ctr tasks kill TASK --signal 9
```

### CRI-CTL

Can set up `crictl` utility to confirm that ContainerD is properly set up to be used as a CRI.


Setup:
```sh
# 1. Installing CRI-CTL
VERSION="v1.26.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

# 2. Configuring to
#   1) Point to ContainerD - NOT DOCKER
#   2) Disable debug-messages - Enable if necessary
cat | sudo tee /etc/crictl.yaml << EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF
```

Usage:
```sh
# Checking the info
crictl info

# Checking that images can be pulled (Cannot pull private images with `ctr`)
crictl pull [image]
crictl images

# Using together with `ctr` to run an image
```
