#! /bin/bash
apt-get update -y
apt-get upgrade -y
hostnamectl set-hostname kube-worker
apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet=1.28.2-1.1 kubeadm=1.28.2-1.1 kubectl=1.28.2-1.1 kubernetes-cni docker.io
apt-mark hold kubelet kubeadm kubectl
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
newgrp docker
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
mkdir /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py
pip install pyopenssl --upgrade
pip3 install ec2instanceconnectcli
apt install -y mssh
until [[ $(mssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t ${master-id} -r ${region} ubuntu@${master-id} kubectl get no | awk 'NR == 2 {print $2}') == Ready ]]; do echo "master node is not ready"; sleep 3; done;
kubeadm join ${master-private}:6443 --token $(mssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t ${master-id} -r ${region} ubuntu@${master-id} kubeadm token list | awk 'NR == 2 {print $1}') --discovery-token-ca-cert-hash sha256:$(mssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t ${master-id} -r ${region} ubuntu@${master-id} openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //') --ignore-preflight-errors=All