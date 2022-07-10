#/usr/bin/bash

# take the first argument as the environment to use
env=${1:-dev}
dir=./argo/overlays/$env

if [ ! -d $dir ];
then
	echo "Couldn't find the directory $dir"
	exit 1
fi


# make sure we have argocd installed
if ! command -v argocd &> /dev/null
then
	printf '\e[1;33m'
	echo "┌────────────────────────────────────────────┐"
	echo "│ ArgoCD command line not found in your PATH │"
	echo "└────────────────────────────────────────────┘"
	printf '\e[0m'
	echo
	while true; do
		printf '\e[1;35m'
		read -p "Do you wish to install this program? [y/n] " yn
		printf '\e[0m'
		case $yn in
			[Nn]* ) exit;;
			[Yy]* ) brew install argocd; break;;
			* )
				printf '\e[1;31m'
				echo
				echo "Please answer yes or no."
				echo
				printf '\e[0m'
			;;
		esac
	done
fi

# create the argocd namespace
kubectl get namespace argocd >/dev/null || kubectl create namespace argocd

# install argo
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# patch argo to enable helm inside kustomize
kubectl patch configmap/argocd-cm -n argocd --type merge -p '{"data":{"kustomize.buildOptions":"--enable-helm"}}'

# install the specific environment components
kubectl apply -k $dir
