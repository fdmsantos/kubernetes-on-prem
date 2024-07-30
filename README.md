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
| GitOps                | fluxcd                                                                                                                            | 2.3.0        |

### Ip Management

| IP                | Function                  |
|-------------------|---------------------------|
| 192.168.56.2      | k8s-master-01             |
| 192.168.56.3      | k8s-master-02             |
| 192.168.56.4      | k8s-master-03             |
| 192.168.56.5      | k8s-worker-01             |
| 192.168.56.6      | k8s-worker-02             |
| 192.168.56.7      | k8s-worker-03             |
| 192.168.56.100    | Kube-apiserver LB         |
| 10.0.0.0/16       | Pod Network CIDR          |
| 10.96.0.0/12      | Service Cluster IP        |
| 192.168.56.112/28 | LoadBalancer External IPs |

## Deploy 

* On `cluster-deploy` folder

### VMS

* Build

```shell
packer init .
packer build -force -parallel-builds=1 .  
```

* Create

```shell
vagrant plugin install vagrant-hosts
vagrant box add k8s-master output-master/package.box --force
vagrant box add k8s-worker output-worker/package.box --force
vagrant up
```

### Configure Cluster

* First Master
  * run `first-master.sh`
* Others Master
  * run `others-master.sh`
* Workers
  * run `workers.sh`
* Local Machine with kubeconfig configured
  * run `/infrastructure/deploy-cilium.sh`
  * run `bootstrap-flux.sh` # Need change the values
* For run Kube-Bench in all machines
  * execute `kube-bench.sh`

### Vault Configuration

[Ha With Raft](https://developer.hashicorp.com/vault/docs/platform/k8s/helm/examples/ha-with-raft)

* Unseal Vault

```shell
kubectl exec -ti vault-0 -n vault -- vault operator init 
kubectl exec -ti vault-0 -n vault -- vault operator unseal
```

* Join HA Cluster

```shell
kubectl exec -ti vault-1 -n vault -- vault operator raft join http://vault-0.vault-internal:8200
kubectl exec -ti vault-1 -n vault -- vault operator unseal
```

* Configure Mysql

```sh
vault write database/config/wordpress-mysql \
plugin_name=mysql-legacy-database-plugin \
connection_url="{{username}}:{{password}}@tcp(wordpress-mysql.wordpress:3306)/" \
allowed_roles="wordpress-mysql" \
username="root" \
password="rootpassword"

vault write database/roles/wordpress-mysql \
db_name=wordpress-mysql \
creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
default_ttl="1h" \
max_ttl="24h"
```

* Configure Kubernetes Authentication

[Link](https://medium.com/@seifeddinerajhi/securely-inject-secrets-to-pods-with-the-vault-agent-injector-3238eb774342)

```shell
vault write auth/kubernetes/config \
token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt


vault policy write wordpress-app - <<EOF
path "database/creds/wordpress-mysql" {
  capabilities = ["read"]
}
EOF


vault write auth/kubernetes/role/wordpress-app \
bound_service_account_names=wordpress-app \
bound_service_account_namespaces=wordpress \
policies=wordpress-app \
ttl=24h
```

## Usefully Links

### HA Cluster

[Creating Highly Available Clusters with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

[Options for Highly Available Topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/#stacked-etcd-topology)

[High Availability Considerations](https://github.com/kubernetes/kubeadm/blob/main/docs/ha-considerations.md#options-for-software-load-balancing)

### Issues To Follow

[kube-vip requires super-admin.conf with Kubernetes](https://github.com/kube-vip/kube-vip/issues/684)
[helm: possibility to control creation of GatewayClass](https://github.com/cilium/cilium/pull/33446)
[gateway-api v1.1.0 standard-install breaks envoy-gateway and cilium-operator](https://github.com/kubernetes-sigs/gateway-api/issues/3075)

#### Kube DNS Issue

* Workaround

```shell
kubectl edit configmaps -n kube-system coredns
# Replace "forward . /etc/resolv.conf" with "forward . 8.8.8.8"

kubectl -n kube-system rollout restart deployment coredns
```

[Cilium Connectivity test using external dns lookups failing when bpf masquarade enabled in native routing mode](https://github.com/cilium/cilium/issues/32559)
[External DNS not resolved in native routing](https://github.com/cilium/cilium/issues/29113)
[https://github.com/cilium/cilium/issues/26010](https://github.com/cilium/cilium/issues/26010)
[Medium Article](https://medium.com/@nahelou.j/play-with-cilium-native-routing-in-kind-cluster-5a9e586a81ca)

## Work In Progress

* Configure Cluster with Ansible
* Install [Helm](https://helm.sh/docs/intro/install/) via Packer
* Install [Cilium CLI](https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/) via Packer
* Install [Cilium Hubble](https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/#hubble-setup) via Packer