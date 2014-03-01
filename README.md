# docker-wallabag

Dockerfile used to build a wallabag docker image.

Wallabag is an opensource project created by @nicosomb

## Usage from index
    sudo docker pull bobmaerten/docker-wallabag
    ID=$(sudo docker run -p 8080:80 -d bobmaerten/docker-wallabag)

Then head your browser to http://localhost:8080 and enjoy a fresh Wallabag install. When you're finished, just stop the docker container:

    sudo docker stop $ID

## Instructions for building from Dockerfile

### Build
```
sudo docker build -t docker-wallabag .
```

### Launch and test
```
sudo docker run -p 8080:80 --name wallabag -d wallabag
```
Head your browser to http://localhost:8080

### Stop
```
sudo docker stop wallabag
sudo docker rmi wallabag
```
