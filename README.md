# Setting Up The App On Localhost

## Prerequisite
- Have Python 3.7 downloaded
- Have Pip installed

## Running the App Locally
- pull the latest version of the app from github
- Go to the app folder on gitbash and run the commands:
  - "pip install -r requirements.txt"
  - "install pandas"
  - "install flask"
- To check all test pass run "python -m pytest tests"
  - This will run all the tests and if they pass you can move to the next stage
- Finally run the app by typing "flask run"
- Should then say "running on `<ipadress>`" Copy this ip adress in the browser to view the webpage.

# Setting-up-K8-master-and-agent-node-on-AWS

### Creating EC2 instances for master and worker node
-----------------------------
Master node:
- storage: t2 medium
- Ports: 6443, 443
Agent node:
- storage: t2 micro
- Ports: 6443, 443

### Set up docker and k8 on master and agent nodes:
-----------------------
On both the master and agent nodes.
[Source](https://computingforgeeks.com/deploy-kubernetes-cluster-on-ubuntu-with-kubeadm/)

**Step 1: Install Kubernetes Servers**
```
sudo apt update
sudo apt -y upgrade && sudo systemctl reboot
# server will reboot, give it some time
```

**Step 2: Install kubelet, kubeadm and kubectl**
```
sudo apt update
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```
sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
```
kubectl version --client && kubeadm version
# check version of kubectl
```

**Step 3: Disable Swap**
```
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
```
```
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system
```
**Step 4: Install Docker runtime**
```
# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
```

### Setting up master node
-------------------------------
We now need to set up the master node.
```
lsmod | grep br_netfilter
sudo systemctl enable kubelet # enable kubectl
```
```
# initialize the machine that will run the control plane components
sudo kubeadm config images pull
[config/images] Pulled k8s.gcr.io/kube-apiserver:v1.22.2
[config/images] Pulled k8s.gcr.io/kube-controller-manager:v1.22.2
[config/images] Pulled k8s.gcr.io/kube-scheduler:v1.22.2
[config/images] Pulled k8s.gcr.io/kube-proxy:v1.22.2
[config/images] Pulled k8s.gcr.io/pause:3.5
[config/images] Pulled k8s.gcr.io/etcd:3.5.0-0
[config/images] Pulled k8s.gcr.io/coredns/coredns:v1.8.4
```

Set up master node
```
sudo kubeadm init \
  --pod-network-cidr=<your_VPC_CIDR>

# e.g. sudo kubeadm init \
>   --pod-network-cidr=10.0.10.0/24

# You should get a message with the join token
# e.g. kubeadm join 10.0.10.84:6443 --token tna5wy.kwuwvje2h213adasda \
        --discovery-token-ca-cert-hash sha256:a34aa9fb813a86379dasfdaswfafdcd1fd516b207f87b36076e337921f07c6a0
```

```
# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
```
# check cluster status and if kubernetes master is running
kubectl cluster-info
```
**Step 6: Install network plugin on Master**
```
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
```
```
watch kubectl get pods --all-namespaces
kubectl get nodes -o wide
```

### Setting up to connect Worker to Master
SSH into the worker node and enter the join token.
```
kubeadm join 10.0.10.84:6443 --token tna5wy.kwuwvje2h213adasda \
        --discovery-token-ca-cert-hash sha256:a34aa9fb813a86379dasfdaswfafdcd1fd516b207f87b36076e337921f07c6a0
```

On the master node, enter `kubectl get nodes` to see if the worker node is connected.

### Setting Ready state
SSH into master node and run the commands:
```
$ export kubever=$(kubectl version | base64 | tr -d '\n')
$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
```
Run `kubectl get nodes` to check the ready state
