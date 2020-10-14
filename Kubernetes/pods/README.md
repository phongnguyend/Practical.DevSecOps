```
kubectl run nginx --image=nginx:alpine
kubectl get pods
kubectl get all
kubectl port-forward nginx 8080:80
kubectl delete pod nginx
```

```
kubectl apply –f nginx.pod.yml
kubectl get pods
kubectl get all
kubectl port-forward pod/nginx 8080:80
Kubectl delete –f nginx.pod.yml
```
