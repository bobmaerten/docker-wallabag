# docker-wallabag

Dockerfile used to build a wallabag docker image.

Wallabag is an opensource project created by @nicosomb

## Instructions

### Building images
```
sudo docker build -t wallabag .
```

### Lauching images
```
sudo docker run -p 8080:80 --name wallabag -d wallabag:latest
```
Head your browser to http://localhost:8080

### stopping images
```
sudo docker stop wallabag
sudo docker rmi wallabag
```
