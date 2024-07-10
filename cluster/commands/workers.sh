sudo swapoff -a
sudo nano /etc/sysctl.conf # uncomment net.ipv4.ip_forward = 1
sudo sysctl -p
sudo kubeadm join 192.168.56.100:6443 --token {{token}} --discovery-token-ca-cert-hash {{token}}