- Install Helm
  + [Windows](https://get.helm.sh/helm-v3.3.4-windows-amd64.zip)

- Basic Commands
  ```
  helm help
  helm repo add stable https://kubernetes-charts.storage.googleapis.com/
  helm repo list
  helm repo update
  helm install mysql stable/mysql
  kubectl get secrets
  helm upgrade mysql
  helm uninstall mysql
  ```
