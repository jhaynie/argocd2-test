#/usr/bin/bash

# take the first argument as the environment to use
env=${1:-dev}
dir=./argo/overlays/$env

if [ ! -d $dir ];
then
	echo "Couldn't find the directory $dir"
	exit 1
fi

# create the argocd namespace
kubectl create namespace argocd

# install argo
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# patch argo to enable helm inside kustomize
kubectl patch configmap/argocd-cm -n argocd --type merge -p '{"data":{"kustomize.buildOptions":"--enable-helm"}}'

# install the specific environment components
kubectl apply -k $dir
