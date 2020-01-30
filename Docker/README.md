
### Install Docker
[Install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install/)

### VSCode Extensions:

[Working with Docker on Visual Studio Code](https://code.visualstudio.com/docs/azure/docker)

[Docker for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

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
