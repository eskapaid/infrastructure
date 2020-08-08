# Unofficial Helm Charts for the Prysmatic Labs ETH2 Clients
This repository contains Helm charts for deploying the Prysmatic Labs ETH2 Clients into Kubernetes.

## **Everything here is currently work-in-progress. Contributions are very welcome!**

[What is Helm?](https://helm.sh/)

[What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

## Getting started

### Prerequisites

Make sure you have the following tools installed before beginning:

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [minikube (local development and testing)](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux)
- [helm](https://helm.sh/docs/intro/quickstart/)

### Installing

Clone this repository and navigate to it

```
git clone https://github.com/badinvestment/prysm-helm.git
cd prysm-helm
```

Start minikube and verify it started correctly

```
minikube start
minikube status
```


Verify kubectl can connect

```
kubectl cluster-info
```

#### Deploying beacon node(s)

Navigate to the beacon node chart directory

```
cd beacon
```

In this directory is the `values.yaml` file. This is where the configuration for the chart is stored. The default configuration will get you started, but be sure to [check out the available flags](https://docs.prylabs.network/docs/prysm-usage/parameters/).

Once satisfied with the configuration you can deploy the beacon node(s)
```
helm install beacon . -f values.yaml
```
If successful, you will see an output like this
```
NAME: beacon
LAST DEPLOYED: Wed May 27 17:36:45 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
Once initialized, you can list the deployed pods and check the logs. You should see the client start syncing.
```
kubectl get pods
kubectl logs beacon-client-0 -f
```

Done!

#### Deploying validator(s)

Navigate to the validator chart directory

```
cd validator
```

In this directory is the `values.yaml` file. This is where the configuration for the chart is stored. The default configuration will get you started, but be sure to [check out the available flags](https://docs.prylabs.network/docs/prysm-usage/parameters/).

Once satisfied with the configuration you can deploy the validator(s)
```
helm install validator . -f values.yaml
```
If successful, you will see an output like this
```
NAME: validator
LAST DEPLOYED: Wed May 27 17:39:32 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```
Once initialized, you can list the deployed pods and check the logs. You should see the validator talking to the beacon node.
```
kubectl get pods
kubectl logs validator-0 -f
```

Done!

## TODO
- [ ] Key management (Signing service)
- [ ] Pod anti-affinity
- [ ] Egress
- [ ] ...

