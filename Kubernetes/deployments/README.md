```
kubectl apply –f nginx.deployment.yml
kubectl get deployments
kubectl get all
kubectl scale –f nginx.deployment.yml --replicas=5
kubectl port-forward deployment/my-nginx 8080:80
Kubectl delete –f nginx.deployment.yml
```
