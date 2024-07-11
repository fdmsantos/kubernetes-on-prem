helm repo add cilium https://helm.cilium.io/
API_SERVER_IP=192.168.56.100
API_SERVER_PORT=6443
helm install cilium cilium/cilium --version 1.15.6 \
    --namespace kube-system \
    --set kubeProxyReplacement=true \
    --set k8sServiceHost=${API_SERVER_IP} \
    --set k8sServicePort=${API_SERVER_PORT} \
    --set gatewayAPI.enabled=true
