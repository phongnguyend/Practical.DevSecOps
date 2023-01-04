
### Install Docker
- [Install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/)
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

### VSCode Extensions:
- [Working with Docker on Visual Studio Code](https://code.visualstudio.com/docs/azure/docker)
- [Docker for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [Install and Configure Vistual Studio Code Extension](https://code.visualstudio.com/docs/remote/ssh-tutorial)

### Monitoring Tools:
- [https://github.com/nicolargo/glances](https://github.com/nicolargo/glances)
- [https://www.portainer.io](https://www.portainer.io)

### Commands:
```
docker -v
```
```
docker version
```
```
docker info
```
```
docker --help
```

### Images:
```
docker image ls
docker image rm <id>

```

### Containers:
```
docker container ls
docker container stop <id>
docker container rm <id>
docker logs <id>
```

### Clean Up:
```
docker image prune
docker volume prune
docker system prune
```
### Volumes:
```
docker volume ls
```

### Networks:
```
docker network ls
```

### docker-compose
```
docker-compose --version
docker-compose --help
docker-compose up
docker-compose up servicename
docker-compose down
docker-compose start
docker-compose start servicename
docker-compose stop 
docker-compose stop servicename
docker-compose build
docker-compose build servicename
```
