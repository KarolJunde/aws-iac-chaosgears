# Change here or use environment variables, e.g. export AWS_PROFILE=<aws profile name>.

# Default SHELL for make for consistency on different platforms
SHELL := /bin/bash

NODE_NUM ?= 2
MASTER_NUM ?= 3
KOPS_NAME ?= k8s.nubeschaser.com
KOPS_STATE_STORE ?= s3://kopsawsdemo


.ONESHELL:
SHELL := /bin/bash
.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

create: ## Create k8s cluster on AWS.
	@tput sgr0; echo -n "Creating k8s cluster - " ; tput sgr0; tput setaf 1; tput bold; echo -n "$(KOPS_NAME)"
	@kops create cluster \
	--name $(KOPS_NAME) \
	--state $(KOPS_STATE_STORE) \
	--zones=eu-west-1a,eu-west-1b,eu-west-1c \
	--master-zones=eu-west-1a,eu-west-1b,eu-west-1c \
	--node-count=$(NODE_NUM) \
	--master-count=$(MASTER_NUM) \
	--dns=private \
	--master-size=m3.medium \
	--node-size=t2.medium \
	--cloud=aws \
	--topology=private \
	--network-cidr=10.50.0.0/16 \
	--dns-zone=$(KOPS_NAME) \
	--associate-public-ip=false \
	--bastion \
	--yes

edit: ## Edit k8s cluster.
	@tput sgr0; echo -n "Editing k8s cluster - " ; tput sgr0; tput setaf 1; tput bold; echo -n "$(KOPS_NAME)"
	@kops edit cluster \
	--name $(KOPS_NAME) \
	--state $(KOPS_STATE_STORE) \
	--yes

run: ## Run k8s cluster.
	@tput sgr0; echo -n "Running k8s cluster - " ; tput sgr0; tput setaf 1; tput bold; echo -n "$(KOPS_NAME)"
	@kops update cluster \
	--name $KOPS_NAME \
	--state $KOPS_STATE_STORE \
	--yes

delete: ## Delete k8s cluster.
	@tput sgr0; echo -n "Deleting k8s cluster - " ; tput sgr0; tput setaf 1; tput bold; echo -n "$(KOPS_NAME)"
	@kops delete cluster \
	--name $(KOPS_NAME) \
	--state $(KOPS_STATE_STORE) \
	--yes

gui: ## Create GUI.
	@tput sgr0; echo -n "Creating GUI k8s cluster - " ; tput sgr0; tput setaf 1; tput bold; echo -n "$(KOPS_NAME)"
	@kubectl create \
	-f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml \
	--state $(KOPS_STATE_STORE) \
