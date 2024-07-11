source "vagrant" "master" {
  communicator = "ssh"
  source_path = "bento/ubuntu-22.04"
  provider = "virtualbox"
  add_force = true
}

build {
  name = "k8s-master"
  sources = ["source.vagrant.master"]

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

  # Install ContainerD
  provisioner "shell" {
    inline = [
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install -y containerd.io",
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

  # Install Helm
  provisioner "shell" {
    inline = [
      "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3",
      "chmod 700 get_helm.sh",
      "./get_helm.sh",
      "rm get_helm.sh"
    ]
  }

  # Install Kube-Bench
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /opt/kube-bench",
      "sudo curl -L https://github.com/aquasecurity/kube-bench/releases/download/v0.8.0/kube-bench_0.8.0_linux_amd64.tar.gz -o /opt/kube-bench.tar.gz",
      "sudo tar -xvf /opt/kube-bench.tar.gz -C /opt/kube-bench",
      "sudo mv /opt/kube-bench/kube-bench /usr/local/bin/",
      "sudo rm /opt/kube-bench.tar.gz"
    ]
  }
}

