#!/bin/bash

function start_cluster () {

    KOPS_NAME=$ACTION2
    KOPS_STATE_STORE=$ACTION3
    MASTER_NUM="2"

kops delete cluster --name $KOPS_NAME --yes

kops create cluster \
   --name $KOPS_NAME \
   --state $KOPS_STATE_STORE \
   --zones=eu-west-1a,eu-west-1b,eu-west-1c \
   --master-zones=eu-west-1a,eu-west-1b,eu-west-1c \
   --node-count=2 \
  # --kubernetes-version=1.6.2 \
   --master-count $MASTER_NUM \
   --dns=private \
   --master-size=m3.medium \
   --node-size=t2.medium \
  # --cloud-labels="" \
   --cloud=aws \
   --topology=private \
   --network-cidr=10.50.0.0/16 \
   --dns-zone $KOPS_NAME \
   --associate-public-ip=false \
   --bastion \
   --yes

return 0
}

function edit_cluster () {
   KOPS_NAME=$ACTION2
   KOPS_STATE_STORE=$ACTION3

   kops edit cluster \
   --name $KOPS_NAME \
   --state $KOPS_STATE_STORE \
   --yes

return 1
}

function update_cluster () {
   KOPS_NAME=$ACTION2
   KOPS_STATE_STORE=$ACTION3

   kops update cluster \
   --name $KOPS_NAME \
   --state $KOPS_STATE_STORE \
   --yes

return 1
}

function delete_cluster () {
    KOPS_NAME=$ACTION2
    KOPS_STATE_STORE=$ACTION3

    kops delete cluster \
   --name $KOPS_NAME \
   --state $KOPS_STATE_STORE \
   --yes

return 1
}

function setup_gui () {
    KOPS_STATE_STORE=$ACTION3

    kubectl create \
    -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml \
    --state $KOPS_STATE_STORE \

return 1
}
# exit 1

ACTION1_DEFAULT="CREATE"
read -p "DEFAULT: [$ACTION1_DEFAULT] -> CHOOSE: [CREATE]|[RUN]||[EDIT]|[DELETE]|[GUI] - K8S CLUSTER ON AWS: " ACTION1
ACTION1="${ACTION1:-$ACTION1_DEFAULT}"

ACTION2_DEFAULT=""
read -p "DEFAULT: [$ACTION2_DEFAULT] -> WHICH KOPS NAME: " ACTION2
ACTION2="${ACTION2:-$ACTION2_DEFAULT}"

ACTION3_DEFAULT=""
read -p "DEFAULT: [$ACTION3_DEFAULT] -> WHICH KOPS_STATE_s3: " ACTION3
ACTION3="${ACTION3:-$ACTION3_DEFAULT}"


 if [ "$ACTION1" = "CREATE" ]
  then
start_cluster ${ACTION1}
echo "${ACTION1} K8S CLUSTER NAME: ${ACTION2}"
exit 0
 elif [ "$ACTION1" = "RUN" ]
  then
update_cluster ${ACTION1}
echo "${ACTION1} K8S CLUSTER NAME: ${ACTION2}"
exit 0
elif [ "$ACTION1" = "EDIT" ]
  then
update_cluster ${ACTION1}
echo "${ACTION1} K8S CLUSTER NAME: ${ACTION2}"
exit 0
elif [ "$ACTION1" = "GUI" ]
  then
update_cluster ${ACTION1}
echo "GUI HAS BEEN RUN"
exit 0
 elif [ "$ACTION1" = "DELETE" ]
  then
delete_cluster ${ACTION1}
echo "${ACTION1} K8S CLUSTER NAME: ${ACTION2}"
 else
echo "WRONG ACTION"
exit 1
fi
