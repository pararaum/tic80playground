#! /bin/bash

REVISION=`date +%Y%m`
REPOSITORY=vintagecomputingcarinthia/tic80build

docker build -t $REPOSITORY:latest .
docker tag $REPOSITORY:latest $REPOSITORY:r$REVISION

for arg in "$@"; do
    case $arg in
	push)
	    docker push $REPOSITORY:r$REVISION
	    docker push $REPOSITORY:latest
	    ;;
	*)
	    printf "Unknown argument '%s'.\\n" $arg
    esac
done
