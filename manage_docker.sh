#!/bin/bash

APP_HOME=/opt/docker-redis-sentinel-replication-cluster

function consulAgentPID()
{
    ps auwwx | grep "consul agent -server" | grep -v grep | awk '{print $2}'
}

function dockerDaemonPID()
{
    ps auwwx | grep "docker daemon" | grep -v grep | awk '{print $2}'
}

function swarmManagerPID()
{
    ps auwwx | grep "swarm manage" | grep -v grep | awk '{print $2}'
}

function swarmClientPID()
{
    ps auwwx | grep "swarm join" | grep -v grep | awk '{print $2}'
}

PIDS=(
    $(consulAgentPID)
    $(dockerDaemonPID)
    $(swarmManagerPID)
    $(swarmClientPID)
);

function statuscmd()
{
    local pid=$(consulAgentPID)
    if [ -n "$pid" ] ; then
        echo "Consul agent started";
    else
        echo "Consul agent is not running";
    fi

    pid=$(dockerDaemonPID)
    if [ -n "$pid" ] ; then
        echo "Docker daemon started";
    else
        echo "Docker agent is not running";
    fi

    pid=$(swarmManagerPID)
    if [ -n "$pid" ] ; then
        echo "Swarm manager started";
    else
        echo "Swarm manager is not running";
    fi

    pid=$(swarmClientPID)
    if [ -n "$pid" ] ; then
        echo "Swarm client started";
    else
        echo "Swarm client is not running";
    fi
}

function stopcmd()
{
    if [ ${#PIDS[@]} -ne 0 ]; then
        echo "Stopping docker services"
        for pid in ${PIDS[@]}; do
            kill -9 $pid;
            sleep 1;
        done
        echo "Done";
    fi
}

function startcmd()
{
    cd $APP_HOME/docker-services

    echo "Starting Consul"
    cd consul
    ./restart_consul.sh

    echo "Starting Docker"
    cd ../docker
    ./start_docker_daemon.sh

    echo "Starting Swarm Manager"
    cd ../swarm
    ./restart_single_swarm_manager.sh

    echo "Joining cluster"
    ./swarm_join_local_consul.sh
}

case "$1" in
    "start")
        startcmd
    ;;
    "stop")
        stopcmd
    ;;
    "restart")
        stopcmd
        sleep 5
        startcmd
    ;;
    "status")
        statuscmd
    ;;
    *)
        echo "Usage: $0 <start|stop|restart|status>"
    ;;
esac

