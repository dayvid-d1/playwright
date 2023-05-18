#!/usr/bin/bash

function usage {
  echo "Usage: ./container.sh [ -i | --image ] [ -l | --location ] [ -o | --local ] [ -p | --port ] [ -e | --env-file ] [ -v | --volname ] [ -h | --help ]"
  echo " -i  | --image                        Image f.e. '-i centos7-java11-tomcat8'"
  echo " -p  | --port                         Port f.e. '-p 80'"=
  echo " -e  | --env-file                     Env file f.e. '-e ./default.env'"=
  echo " -c  | --contname                     Container name f.e. '-c app'"=
  echo " -v  | --volname                      Volume name f.e. '-v volume'"=
  echo " -h  | --help                         Show this menu"
}

timestamp() {
	date +"%Y-%m-%d %T"
}

while(($#)) ; do
    case $1 in
        -i | --image )                  shift
                                        IMAGE="$1"
                                        shift
                                        ;;
        -l | --location )               shift
                                        LOCATION="$1"
                                        shift
                                        ;;
        -o | --local )                  shift
                                        LOCAL_LOC="$1"
                                        shift
                                        ;;
        -v | --volname )                shift
                                        VOLUME_NAME="$1"
                                        shift
                                        ;;
        -c | --contname )               shift
                                        CONTAINER_NAME="$1"
                                        shift
                                        ;;
        -p | --port )                   shift
                                        PORT="$1"
                                        shift
                                        ;;
        -e | --env-file )               shift
                                        ENV_FILE="$1"
                                        shift
                                        ;;
        -h | --help )                   shift
                                        usage
                                        exit
                                        ;;
        * )                             echo "unknown option $1"
                                        usage
                                        exit
                                        ;;
    esac
done

INITIAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOCATION="/ms-playwright"
IMAGE="playwright:test"
CONTAINER_NAME="playwright-try"
VOLUME_NAME="playwright-vol"
PORT="8000"

if [[ ! -n "$LOCAL_LOC" ]]; then
  LOCAL_LOC="$(dirname "${INITIAL_DIR}")"
  LOCAL_LOC="/${PWD}/tests/"
fi

echo "y" | docker system prune -a --volumes
echo "$(timestamp) Container $CONTAINER_NAME to be set"
if [ ! -z $(docker ps -q -f name=${CONTAINER_NAME}) ]; then
  docker stop ${CONTAINER_NAME}
fi

echo "$(timestamp) Removing old container"
CONTAINER_STATUS=$(docker container inspect -f '{{.State.Status}}' ${CONTAINER_NAME})
if [ "${CONTAINER_STATUS}" == "exited" ]; then  
  docker rm ${CONTAINER_NAME}
elif [ "${CONTAINER_STATUS}" == "created" ]; then  
  docker container rm ${CONTAINER_NAME}
fi

if [ "$(docker volume inspect -f '{{.Scope}}' ${VOLUME_NAME})" == "local" ]; then
  echo "$(timestamp) Removing old volume"
  #docker volume rm $VOLUME_NAME
fi
echo "$(timestamp) Creating new app volume"
#docker volume create $VOLUME_NAME

echo "$(timestamp) Initiating container run"
#docker run -d --name=centos-cont-almalinux --cap-add=all --privileged=true --tmpfs //run -v //sys/fs/cgroup://sys/fs/cgroup:ro --user app davidclement/app-almalinux8:latest
docker build --platform linux/amd64 -t $IMAGE .

docker run -dit --name=$CONTAINER_NAME \
  -v=$VOLUME_NAME \
  -v "${LOCAL_LOC}":"${LOCATION}/tests" \
  -p 9323:9323 \
  $IMAGE bash
#sleep 20s
docker exec -it $CONTAINER_NAME bash -c "npx playwright test"