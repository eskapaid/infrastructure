# infrastructure

### Setup kubectl for the first time

Terraform can write kubeconfig to local disk after a successful run. Without access to Terraform, get kubeconfig by running the following command and chaning parameters as needed.

Make sure aws cli credentials are configured locally then,

to get kubeconfig for "develop" cluster by using admin role run:

    export ACCOUNT_ID=993663177296
    aws eks update-kubeconfig --kubeconfig ../kubeconfig --region ap-southeast-1 --name eks-develop --role-arn arn:aws:iam::$ACCOUNT_ID:role/AdminAccess --alias eks-develop
    
    export KUBECONFIG=../kubeconfig

Test access to the cluster:

    kubectl cluster-info

Creating validator secrets manually right now:

    $ k create secret generic lighthouse-keystore-0x90a401 --from-file 0x90a401/keystore.json
    secret/lighthouse-keystore-0x90a401 created

    $ k create secret generic lighthouse-definitions-0x90a401 --from-file validator_definitions.yml
    secret/lighthouse-definitions-0x90a401 created