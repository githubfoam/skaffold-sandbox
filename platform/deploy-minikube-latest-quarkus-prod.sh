#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================virtualization check============================================================="
if [[ $(egrep -c '(vmx|svm)' /proc/cpuinfo) == 0 ]]; then #check if virtualization is supported on Linux, xenial fails w 0, bionic works w 2
             echo "virtualization is not supported"
    else
          echo "===================================="
          echo eval "$(egrep -c '(vmx|svm)' /proc/cpuinfo)" 2>/dev/null
          echo "===================================="
          echo "virtualization is supported"
fi

echo "=============================minikube latest============================================================="
apt-get update -qq && apt-get -qq -y install conntrack #http://conntrack-tools.netfilter.org/
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && mv minikube /usr/local/bin/ # Download minikube
minikube version

echo "=============================kubectl latest============================================================="
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x kubectl && mv kubectl /usr/local/bin/ # Download kubectl
kubectl version --client

echo "=============================helm-3 latest============================================================="
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && bash get_helm.sh
helm version
mkdir -p $HOME/.kube $HOME/.minikube

# minikube start --profile=minikube --vm-driver=none --kubernetes-version=v$KUBERNETES_VERSION #the none driver, the kubectl config and credentials generated are owned by root in the root user’s home directory
minikube start --profile=minikube --vm-driver=none #the none driver, the kubectl config and credentials generated are owned by root in the root user’s home directory
minikube status #* There is no local cluster named "minikube"
minikube update-context --profile=minikube
`chown -R travis: /home/travis/.minikube/`
eval "$(minikube docker-env --profile=minikube)" && export DOCKER_CLI='docker'

echo "=========================================================================================="
minikube status
kubectl cluster-info

echo "=========================================================================================="
# echo "Waiting for Kubernetes to be ready ..."
# for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
#       if kubectl get pods --namespace=kube-system -lk8s-app=kube-dns|grep Running ; then
#         break
#       fi
#       sleep 2
# done
echo "Waiting for kubernetes to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
      if kubectl get pods --namespace=kube-system  | grep Pending  ; then
        sleep 2
      else
        break
      fi
done
for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
      if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
        sleep 2
      else
        break
      fi
done

echo "============================status check=============================================================="
minikube status
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl get pods -n default

echo "============================deploy nexus=============================================================="

# Setup Nexus(Optional)
# use nexus for caching maven artifacts so that builds are faster
kubectl apply -f app/nexus.yaml

echo "Waiting for nexus to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
      if kubectl get pods --namespace=default  | grep ContainerCreating ; then
        sleep 4
      else
        break
      fi
done

echo "============================status check=============================================================="
minikube status
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl get pods -n default
# https://skaffold.dev/docs/install/
echo "=============================deploy skaffold============================================================="

curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
install skaffold /usr/local/bin/
skaffold version
echo "============================deploy quarkus app=============================================================="
git clone https://github.com/kameshsampath/skaffold-quarkus-helloworld.git
cd skaffold-quarkus-helloworld

# deploy Quarkus JVM image then run the following command before running skaffold
cp src/main/docker/Dockerfile.jvm Dockerfile


# Quarkus Development mode
# skaffold dev -f skaffold-dev.yaml --port-forward #unknown flag: --file
# stops after 120secs, stdout seen
skaffold dev -f skaffold-dev.yaml --port-forward & sleep 120s; kill $!

# curl http://locahost:8080/hello
# curl -I "http://locahost:8080/hello" 2>&1 | grep -w "200\|301" # see if a given website is up or down
wget --spider -S "http://locahost:8080/hello" 2>&1 | awk '/HTTP\// {print $2}' #see only the HTTP status code
apt-get install -yyq lynx
lynx -head -dump http://locahost:8080/hello #Check Whether a Website is up or down
lynx -head -dump http://locahost:8080/hello 2>&1 | awk '/HTTP\// {print $2}' # see only the HTTP status code

# delete the application
skaffold delete