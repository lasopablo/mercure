#!/bin/bash

#################################################################
# Create mercure from scratch in Docker environment
#################################################################
#
# Make sure to change the configuration below, as they are most
# likely different for your environment
#
# Once you are happy, simply run this script to build mercure
# See docker/docker-compose.yml for a sample script
#
#################################################################

#################################################################
# CONFIG SECTION
#################################################################
# Change prefix to your own Docker prefix if you want to make 
# your own custom build
PREFIX="mercureimaging"

# Read the version of the mercure source, which will be used for
# tagging the Docker images, unless a tag has been provided 
# through the environment variable MERCURE_TAG
if [ ! -f "VERSION" ]; then
    echo "Error: VERSION file missing. Unable to proceed."
    exit 1
fi
VERSION=`cat VERSION`
TAG=${MERCURE_TAG:-$VERSION}

# Define where mercure is going to store things
# You can redefine types of volumes in docker/docker-compose.yml
MERCUREBASE=/opt/mercure
DATADIR=$MERCUREBASE/data
CONFIGDIR=$MERCUREBASE/config
DBDIR=$MERCUREBASE/db
MERCURESRC=./

#################################################################
# BUILD SECTION
#################################################################
echo "Building Docker containers for mercure $VERSION"
echo "Using image tag $TAG"
echo ""
read -p "Proceed (y/n)? " ANS
if [ "$ANS" = "y" ]; then
echo ""
else
echo "Aborted."
exit 0
fi

docker build -t $PREFIX/mercure-base:$TAG -f docker/base/Dockerfile .
docker build docker/ui -t $PREFIX/mercure-ui:$TAG
docker build docker/bookkeeper -t $PREFIX/mercure-bookkeeper:$TAG
docker build docker/cleaner -t $PREFIX/mercure-cleaner:$TAG
docker build docker/dispatcher -t $PREFIX/mercure-dispatcher:$TAG
docker build docker/processor -t $PREFIX/mercure-processor:$TAG
docker build docker/receiver -t $PREFIX/mercure-receiver:$TAG
docker build docker/router -t $PREFIX/mercure-router:$TAG
docker build nomad/sshd -t $PREFIX/alpine-sshd:latest
docker build nomad/processing -t $PREFIX/processing-step:$TAG
docker build nomad/dummy-processor -t $PREFIX/mercure-dummy-processor:$TAG

echo ""
echo "Done."
echo ""
