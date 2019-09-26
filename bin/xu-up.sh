#! /bin/bash

PROJECT_PATH=`pwd`
PROJECT=`echo ${PROJECT_PATH} | awk -F "/" '{ print $NF }'`
DOCKER_BIN=`which docker`
DOCKER_IMAGE="xu-docker"
DOCKER_CONTAINER="xu-docker"

DOCKERFILE="${PROJECT_PATH}/node_modules/xu-docker/Dockerfile"

# 选择最佳仓库
chooseRecommendRepo() {
	echo "docker.mirrors.ustc.edu.cn"
}

# 检测仓库是否有效
checkRepoStatus() {
    local repo=$1

    STATUS=`curl -o /dev/null -s -w %{http_code} ${repo}`
    if [ ${STATUS} -eq 200 ]; then
        return 1;
    fi

    return 0;
}


while getopts d:w: name
do
    case ${name} in
        d)
            DOCKER_CMD=$OPTARG
            ;;
    esac
done

if [ -z "${DOCKER_BIN}" ]; then
    echo '请先安装docker';
    exit 1;
fi

if [[ ${DOCKER_CMD} == "" ]]; then
    DOCKER_CMD="-p 8080:8080"
fi

# 删除旧的本地镜像和容器
IS_CONTAINER_EXIST=`${DOCKER_BIN} ps -a | grep ${DOCKER_CONTAINER}`
if [ -n "${IS_CONTAINER_EXIST}" ]; then
    echo "rm -f ${DOCKER_CONTAINER}";
    ${DOCKER_BIN} rm -f ${DOCKER_CONTAINER}
fi;

IS_IMAGE_EXIST=`${DOCKER_BIN} images | grep ${DOCKER_IMAGE}`
if [ -n "${IS_IMAGE_EXIST}" ]; then
    echo "rmi -f ${DOCKER_IMAGE}";
    ${DOCKER_BIN} rmi -f ${DOCKER_IMAGE}
fi;

# 创建镜像、运行容器
${DOCKER_BIN} build -f ${DOCKERFILE} --rm -t ${DOCKER_IMAGE} ${PROJECT_PATH}
${DOCKER_BIN} run ${DOCKER_CMD} -v ${PROJECT_PATH}:/app -it -d --name ${DOCKER_CONTAINER} ${DOCKER_IMAGE}

# rm -rf ./Dockerfile*

echo "正在进入虚拟机，请稍等..."
# 将输入输出流附加到本地容器
${DOCKER_BIN} attach ${DOCKER_CONTAINER}
