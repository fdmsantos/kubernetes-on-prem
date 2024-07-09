packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
  }
}

source "vagrant" "ubuntu" {
  communicator = "ssh"
  source_path = "bento/ubuntu-22.04"
  provider = "virtualbox"
  add_force = true
}

build {
  sources = ["source.vagrant.ubuntu"]

  # Install Kubelet, Kubeadm and Kubectl
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
      "sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo systemctl enable --now kubelet"
    ]
  }

  # Install Docker
  provisioner "shell" {
    inline = [
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin",
      "sudo rm /etc/containerd/config.toml"
    ]
  }

  provisioner "file" {
    source = "containerd/config.toml"
    destination = "/tmp/containerd-config.toml"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/containerd-config.toml /etc/containerd/config.toml"]
  }

  # Upload Kube Vip Manifest File configure HA Kube Api Server
  provisioner "file" {
    source = "kube-vip.yaml"
    destination = "/tmp/kube-vip.yaml"
  }

  provisioner "shell" {
    inline = ["sudo mv /tmp/kube-vip.yaml /etc/kubernetes/manifests/kube-vip.yaml"]
  }
}

# sudo swapoff -a
# sudo kubeadm init --control-plane-endpoint "192.168.56.100:6443" --upload-certs --ignore-preflight-errors=NumCPU,Mem
# Issue To Fix: https://github.com/kube-vip/kube-vip/issues/684