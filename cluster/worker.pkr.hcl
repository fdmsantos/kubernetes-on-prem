source "vagrant" "worker" {
  communicator = "ssh"
  source_path = "bento/ubuntu-22.04"
  provider = "virtualbox"
  add_force = true
}

build {
  name = "k8s-worker"
  sources = ["source.vagrant.worker"]

  # Install Kubelet and Kubeadm
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
      "sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm",
      "sudo apt-mark hold kubelet kubeadm",
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
}

