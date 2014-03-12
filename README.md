# docker-wallabag

Dockerfile used to build a wallabag docker image.

## Usage from index

    ID=$(sudo docker run -p 8080:80 -d bobmaerten/docker-wallabag:latest /sbin/my_init)

Then head your browser to http://localhost:8080 and enjoy a fresh Wallabag install. When you're finished, just stop the docker container:

    sudo docker stop $ID

### Persistance of the database

The [wallabag-docker](script/wallabag-docker) enable persistance of the database outside of the container.
Modify the DBPATH variable at will, but keep an absolute path in order to things to work properly.

## Instructions for building from Dockerfile

### Build

    sudo docker build -t docker-wallabag .

## Credits

Wallabag is an opensource project created by @nicosomb

This docker image is build upon the baseimage made by phusion.
