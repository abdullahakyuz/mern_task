#!/bin/bash

# Sistem güncellemelerini yap
sudo apt-get update -y
sudo apt-get upgrade -y
sudo hostnamectl set-hostname kube-worker

# Gerekli bağımlılıkları kur
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

# Kubernetes ve Docker depolarını ekle
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/trusted.gpg.d/kubernetes.asc
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# Docker kurulumu
sudo apt-get install -y docker.io

# Kubernetes araçlarını yükle
sudo apt-get install -y kubelet=1.28.2-00 kubeadm=1.28.2-00 kubectl=1.28.2-00 kubernetes-cni

# Kubernetes sürücülerini durdur ve 'hold' et
sudo apt-mark hold kubelet kubeadm kubectl

# Docker servisini başlat ve otomatik başlatmayı etkinleştir
sudo systemctl start docker
sudo systemctl enable docker

# Docker'ı ubuntu kullanıcısına ekle
sudo usermod -aG docker ubuntu
newgrp docker

# Kubernetes kernel parametrelerini ayarla
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Containerd yapılandırmasını ayarla
sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Kubernetes imajlarını çek
sudo kubeadm config images pull

# Kubernetes worker node olarak bağlan
sudo kubeadm join --token <TOKEN> <MASTER_IP>:6443 --discovery-token-ca-cert-hash sha256:<CA_CERT_HASH>

# Kubernetes yapılandırma dosyasını taşı
sudo mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Node.js ve MongoDB kurulumları
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt-get install -y nodejs build-essential mongodb

# MongoDB servisini başlat ve otomatik başlatmayı etkinleştir
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Express ve React için gerekli araçları kur
sudo npm install -g express-generator
sudo npm install -g create-react-app

echo "Kubernetes Worker Node ve MERN ortamı kurulumu tamamlandı."

# Prometheus ve Grafana için Kubernetes kaynaklarını uygula
sudo kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/bundle.yaml
sudo kubectl create -f https://raw.githubusercontent.com/grafana/grafana/master/deploy/kubernetes/grafana-deployment.yaml

# Docker MongoDB imajını çek ve çalıştır
sudo docker pull mongo:latest
sudo docker run -d -p 27017:27017 --name mongodb mongo:latest

# Jenkins için Kubernetes erişim izinlerini yapılandır
sudo chown jenkins:jenkins /home/ubuntu/.kube/config
sudo chmod 600 /home/ubuntu/.kube/config

# Kubelet servisini başlat ve etkinleştir
sudo systemctl start kubelet
sudo systemctl enable kubelet

# Kubernetes Worker Node'a başarılı şekilde bağlanıp çalıştığınızı doğrulamak için 'kubectl get nodes' komutunu çalıştırın
sudo kubectl get nodes

echo "Kubernetes Worker Node ve Jenkins ile diğer servisler kuruldu ve çalışmaya başladı."
