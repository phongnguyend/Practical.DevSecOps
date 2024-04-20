
## Masters
![alt text](imgs/master.png)

## Nodes
![alt text](imgs/node.png)

## Pods
![alt text](imgs/pod.png)

## Services

## Deployments

## Installation:
- [Install and Set Up kubectl on Windows](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/)
- [Install and Set Up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## Package Managers
- Helm
  + [helm | The Kubernetes Package Manager](https://github.com/helm/helm)
  + [charts | Curated applications for Kubernetes](https://github.com/helm/charts)
  + [chartmuseum | Host your own Helm Chart Repository](https://github.com/helm/chartmuseum)

## Tools
- [Visual Studio Code Kubernetes Extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
- [kompose | Go from Docker Compose to Kubernetes](https://github.com/kubernetes/kompose)
- [Lens - The Kubernetes IDE](https://github.com/lensapp/lens)

## Connect from WSL2 to Docker Desktop Kubernetes via kubectl
- [Install and Set Up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- Copy ```config``` file from ```C:\Users\<User>\.kube``` to ```root/.kube``` or ```/home/<user>/.kube```

## Install NGINX Ingress Controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch
kubectl get services ingress-nginx-controller --namespace=ingress-nginx
```
