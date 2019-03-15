#!/usr/bin/env bash
ACTION=$1
BASE_DIR=`pwd`
DOCKER_STACK_NAME="moodle"
#DOCKER_DEPLOY_CMD="docker stack deploy -c Docker-compose.yml $DOCKER_STACK_NAME"
#DOCKER_UNDEPLOY_CMD="docker stack rm $DOCKER_STACK_NAME"
DRY_RUN=0

start_env()
{
    cd $BASE_DIR
    CWD=`pwd`
    echo "Starting local dev environment in $CWD"

    DOCKER_DEPLOY_CMD="docker stack deploy -c Docker-compose.yml $DOCKER_STACK_NAME"
    echo $DOCKER_DEPLOY_CMD
    if [ "$DRY_RUN" == "0" ]; then
        $DOCKER_DEPLOY_CMD
    else
        echo "Dry run only"
    fi
    #
}

stop_env()
{

    cd $BASE_DIR
    CWD=`pwd`
    echo "Stopping local dev environment in $CWD"
    DOCKER_UNDEPLOY_CMD="docker stack rm $DOCKER_STACK_NAME"
    echo $DOCKER_UNDEPLOY_CMD

    #$DOCKER_UNDEPLOY_CMD
     if [ "$DRY_RUN" == "0" ]; then
        $DOCKER_UNDEPLOY_CMD
    else
        echo "Dry run only"
    fi

}

# Update Moodle Code base from git
# We expect to be passed the location of the git checkout via -d|--dir
update() {
    cd $BASE_DIR
    echo "Updating Moodle Code base from Git"
    echo "Fetching from upstream"
    if [ "$DRY_RUN" == "0" ]; then
        git fetch upstream
    else
        echo "Dry Run"
    fi
    for BRANCH in MOODLE_{19..36}_STABLE master; do  # This line needs maintenance every time there is a new moodle stable version.
        echo "Updating $BRANCH"
        if [ "$DRY_RUN" == "0" ]; then
            git push origin refs/remotes/upstream/$BRANCH:refs/heads/$BRANCH
        else
            echo "Dry run only"
        fi
    done
}
usage(){
    echo "  -d | --dir"
    echo "  -s | --stack"
    echo "  -h | --help           This information"
}
options()
{
    if [ "$ACTION" == "start" ]; then
        start_env
    elif [ "$ACTION" == "stop" ]; then
        stop_env
    elif [ "$ACTION" == "updatecore" ]; then
        update
    else
        echo "Unknown action '$ACTION' in $BASE_DIR"
    fi
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --dir )    shift
                        BASE_DIR=$1

                        ;;
        -s | --stack)   shift
                        DOCKER_STACK_NAME=$1
                        ;;
        -h | --help)    usage
                        exit
                        ;;
        * )             ACTION=$1
                        options
                        exit 1
    esac
    shift
done

