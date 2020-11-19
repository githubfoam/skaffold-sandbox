IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-skaffold-app :
	bash app/deploy-skaffold-app.sh

deploy-skaffold-latest :
	bash app/deploy-skaffold-latest.sh

deploy-k3d-latest:
	bash platform/deploy-k3d-latest.sh

deploy-kind-kubectl-helm-latest:
	bash platform/deploy-kind-kubectl-helm-latest.sh

deploy-kind-kubectl-helm:
	bash platform/deploy-kind-kubectl-helm.sh

deploy-kind:
	bash platform/deploy-kind.sh

deploy-minikube:
	bash platform/deploy-minikube.sh

deploy-minikube-latest-quarkus:
	bash platform/deploy-minikube-latest-quarkus.sh

deploy-minikube-latest:
	bash platform/deploy-minikube-latest.sh

.PHONY: deploy-minikube deploy-istio push-image
