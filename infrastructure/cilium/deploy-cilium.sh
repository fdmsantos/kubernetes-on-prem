helm repo add cilium https://helm.cilium.io/
helm install cilium cilium/cilium \
    --version 1.15.6 \
    --namespace kube-system \
    -f values.yml

helm upgrade cilium cilium/cilium \
    --version 1.15.6 \
    --namespace kube-system \
    -f values.yml

kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium