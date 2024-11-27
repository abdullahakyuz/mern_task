#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y
sudo hostnamectl set-hostname kube-worker

sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /etc/apt/trusted.gpg.d/kubernetes.asc
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

sudo apt-get install -y docker.io

sudo apt-get install -y kubelet=1.28.2-00 kubeadm=1.28.2-00 kubectl=1.28.2-00 kubernetes-cni

sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl start docker
sudo systemctl enable docker

sudo usermod -aG docker ubuntu
newgrp docker

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo bash -
sudo apt-get install -y nodejs build-essential mongodb

sudo systemctl start mongodb
sudo systemctl enable mongodb

sudo npm install -g express-generator
sudo npm install -g create-react-app

wget https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py
sudo pip install pyopenssl --upgrade
sudo pip3 install ec2instanceconnectcli

MASTER_IP="${master-private}"
TOKEN=$(mssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t ${master-id} -r ${region} ubuntu@${master-ip} kubeadm token list | awk 'NR == 2 {print $1}')
CA_CERT_HASH=$(mssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t ${master-id} -r ${region} ubuntu@${master-ip} openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')

sudo kubeadm join ${MASTER_IP}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${CA_CERT_HASH} --ignore-preflight-errors=All

echo "Kubernetes Worker Node kurulumu ve master node'a bağlanma tamamlandı."