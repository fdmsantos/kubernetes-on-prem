sudo nano /etc/fstab # Comment swap line
sudo reboot
sudo nano /etc/sysctl.conf # uncomment net.ipv4.ip_forward = 1
sudo sysctl -p
sudo kubeadm join 192.168.56.100:6443 --apiserver-advertise-address={{vm-ip}} --token {{token}} --discovery-token-ca-cert-hash {{discover-token}} --control-plane --certificate-key {{certificate_key}} --ignore-preflight-errors=NumCPU,Mem
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
