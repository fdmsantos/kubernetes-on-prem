# kubernetes-on-prem

Setting up and running an on-prem or cloud agnostic Kubernetes cluster (Stacked etcd topology)

## Architecture

* [Stacked etcd topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/#stacked-etcd-topology)
* Cluster Deployment: Kubeadm
* Load Balancer for kube-apiserver: Kube-Vip ARP
* CRI: Docker Engine (containerd)

## Deploy 

* On `cluster` folder

### Packer

```shell
packer init master.pkr.hcl
packer build -force master.pkr.hcl
```

### Vagrant

```shell
vagrant plugin install vagrant-hosts
vagrant box add k8s-master output-ubuntu/package.box --force
vagrant up
```

## Usefully Links

### HA Cluster

[Creating Highly Available Clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

[Options for Highly Available Topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/#stacked-etcd-topology)

[High Availability Considerations](https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#options-for-software-load-balancing)