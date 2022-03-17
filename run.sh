#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=${PWD}/libShell
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi



SUPPORTED_CMD="get,clean,build,release"
SUPPORTED_TARGETS="baseImg,Img"

EXEC_CMD=""
EXEC_ITEMS_LIST=""


DOCKER_RELEASE_REG=rayruan
DOCKER_IMAGE=bookstack

#DOCKER_IMAGE_BASE_VERSION=21.12.5
DOCKER_IMAGE_BASE_VERSION=22.02.3
DOCKER_INTERNAL_TAG=${DOCKER_IMAGE_BASE_VERSION}
DOCKER_RELEASE_TAG="chs_${DOCKER_IMAGE_BASE_VERSION}"

get_baseImg()
{
    echoY "Getting baseImg..."
	docker pull linuxserver/bookstack:${DOCKER_IMAGE_BASE_VERSION}
}

clean_Img()
{
    set +e
    echoY "Cleaning Img ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}..."
	docker rmi ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}
    
    echoY "Cleaning Img ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}..."
	docker rmi ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}
    set -e
}

build_Img()
{
    clean_Img
    get_baseImg

    echoY "Building Img ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}..."
	docker image build . \
		--build-arg "BASE_VERSION=${DOCKER_IMAGE_BASE_VERSION}" \
        -t ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}
    
    docker images ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}

}

release_Img()
{
    echoY "Taging ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}..."
	docker tag ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG} ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}

    echoY "Taging ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:latest..."
	docker tag ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG} ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:latest



    echoY "Pushing ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}..."
	docker push ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_INTERNAL_TAG}

    echoY "Pushing ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}..."
	docker push ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:${DOCKER_RELEASE_TAG}

    echoY "Pushing ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:latest..."
	docker push ${DOCKER_RELEASE_REG}/${DOCKER_IMAGE}:latest
}

usage_func()
{

    echoY "Usage:"
    echoY './run_templete.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c get -l \"baseImg\""
    echoY "eg:\n./run.sh -c clean -l \"Img\""
    echoY "eg:\n./run.sh -c build -l \"Img\""
    echoY "eg:\n./run.sh -c release -l \"Img\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
}

no_args="true"
while getopts "c:l:" opts
do
    case $opts in
        c)
              # cmd
              EXEC_CMD=$OPTARG
              ;;
        l)
              # items list
              EXEC_ITEMS_LIST=$OPTARG
              ;;
        :)
            echo "The option -$OPTARG requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            usage_func
            exit 2
            ;;
        *)    #unknown error?
              echoR "unkonw error."
              usage_func
              exit 1
              ;;
    esac
    no_args="false"
done

[[ "$no_args" == "true" ]] && { usage_func; exit 1; }
#[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1


case ${EXEC_CMD} in
    "get")
        get_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "clean")
        clean_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "build")
        build_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "release")
        release_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac



