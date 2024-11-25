#! /bin/bash
# Sistem güncellemesi ve hostname ayarı
apt-get update -y
apt-get upgrade -y
hostnamectl set-hostname kube-master

# Kubernetes için gerekli bağımlılıkların kurulumu
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet=1.28.2-1.1 kubeadm=1.28.2-1.1 kubectl=1.28.2-1.1 kubernetes-cni docker.io

# Kubernetes bileşenlerini sabitle
apt-mark hold kubelet kubeadm kubectl

# Docker başlat ve etkinleştir
systemctl start docker
systemctl enable docker

# Docker için kullanıcı yetkisi ver
usermod -aG docker ubuntu
newgrp docker

# Kubernetes için ağ yapılandırması
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# Containerd yapılandırması
mkdir /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# Kubernetes cluster başlatma
kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16 --ignore-preflight-errors=All

# Kubectl yapılandırması
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Flannel ağ eklentisini uygulama
su - ubuntu -c 'kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml'

# Local Path Storage ayarları
su - ubuntu -c 'kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml'
sudo -i -u ubuntu kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Node.js, npm ve MongoDB kurulumu
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs build-essential
apt-get install -y mongodb

# MongoDB'yi başlat ve etkinleştir
systemctl start mongodb
systemctl enable mongodb

# Express.js kurulumu
npm install -g express-generator

# React kurulumu
npm install -g create-react-app

# Kullanıcı bilgilendirme mesajı
echo "Kubernetes Master Node ve MERN ortamı kurulumu tamamlandı."
