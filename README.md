# kubernetes-on-prem

Setting up and running an on-prem or cloud agnostic Kubernetes cluster (Stacked etcd topology)

## Cluster

| Specification         | Tool                                                                                                                              | Version Used |
|-----------------------|-----------------------------------------------------------------------------------------------------------------------------------|--------------|
| VMS Build             | Packer                                                                                                                            | v1.11.1      |
| VMS Hosting           | Virtual Box                                                                                                                       | 6.1          |
| VMS Deployment        | Vagrant                                                                                                                           | 2.4.1        |
| Kubernetes Topology   | [Stacked etcd topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/#stacked-etcd-topology) | v1.30.2      |
| Kubernetes Deployment | Kubeadm                                                                                                                           | v1.30.2      |
| Package Manager       | helm                                                                                                                              | 3.15.2       |
| kube-apiserver LB     | Kube-Vip ARP                                                                                                                      | 0.4.0        |
| CRI                   | containerd                                                                                                                        | 1.30.0       |
| CNI                   | cillium                                                                                                                           | 1.15.6       |
| CIS Benchmarks        | kube-bench                                                                                                                        | 0.8.0        |

### Ip Management

| IP             | Function           |
|----------------|--------------------|
| 192.168.56.2   | k8s-master-01      |
| 192.168.56.3   | k8s-master-02      |
| 192.168.56.4   | k8s-master-03      |
| 192.168.56.5   | k8s-worker-01      |
| 192.168.56.6   | k8s-worker-02      |
| 192.168.56.7   | k8s-worker-03      |
| 192.168.56.100 | Kube-apiserver LB  |
| 10.0.0.0/16    | Pod Network CIDR   |
| 10.96.0.0/12   | Service Cluster IP |

## Deploy 

* On `cluster-deploy` folder

### Build VMS

```shell
packer init .
packer build -force -parallel-builds=1 .  
```

### Create VMS

```shell
vagrant plugin install vagrant-hosts
vagrant box add k8s-master output-master/package.box --force
vagrant box add k8s-worker output-worker/package.box --force
vagrant up
```

### Configure VMS

* k8s-master-01 => apply cluster/commands/first-master.sh

## Usefully Links

### HA Cluster

[Creating Highly Available Clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

[Options for Highly Available Topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/#stacked-etcd-topology)

[High Availability Considerations](https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#options-for-software-load-balancing)

### Issues To Follow

[kube-vip requires super-admin.conf with Kubernetes](https://github.com/kube-vip/kube-vip/issues/684)

## Work In Progress

* Configure Cluster with Ansible
* Install [Helm](https://helm.sh/docs/intro/install/) via Packer
* Install [Cilium CLI](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/) via Packer
* Install [Cilium Hubble](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/#hubble-setup) via Packer