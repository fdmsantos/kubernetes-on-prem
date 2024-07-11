sudo swapoff -a
sudo nano /etc/sysctl.conf # uncomment net.ipv4.ip_forward = 1
sudo sysctl -p
sudo sed -i 's#path: /etc/kubernetes/admin.conf#path: /etc/kubernetes/super-admin.conf#' /etc/kubernetes/manifests/kube-vip.yaml
sudo kubeadm init --control-plane-endpoint "192.168.56.100:6443" --apiserver-advertise-address=192.168.56.2 --pod-network-cidr=10.0.0.0/16 --upload-certs --ignore-preflight-errors=NumCPU,Mem --skip-phases=addon/kube-proxy
sudo sed -i 's#path: /etc/kubernetes/super-admin.conf#path: /etc/kubernetes/admin.conf#' /etc/kubernetes/manifests/kube-vip.yaml
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
