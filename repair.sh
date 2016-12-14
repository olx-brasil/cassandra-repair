#!/bin/bash

keep_running=1

function handle_interruption(){
    echo "Signal caught, waiting for the last repair run to finish"
    keep_running=0
}

function print_help(){
    echo 'Usage: '
    echo '  script-repair <keyspace> <node-host> <nodetool-path> <statsd-host> <statsd-port> <datacenter>'
}

if [[ $# < 6 ]]; then
    print_help
    exit
fi

KEYSPACE=$1
NODE_HOST=$2
NODETOOL_PATH=$3
STATSD_HOST=$4
STATSD_PORT=$5
DC=$6

PATH=$PATH:$NODETOOL_PATH
export PATH

IFS=$'\n'

lines=$(nodetool describering $KEYSPACE | grep "endpoints:\[$NODE_HOST" | cut -b 25-77 | sed -e 's/end_token://g' | sed -E 's/(\-?[0-9]+),[[:space:]](\-?[0-9]+).*/nodetool repair -st \1 -et \2 -dc '$DC'/g')

HOSTNAME=$(hostname)
increment=0
lines_array=($lines)

for line in $lines
do
    if [[ $keep_running -eq 1 ]]; then
        trap handle_interruption SIGINT SIGTERM SIGKILL
	((increment+=1))
	echo "Running $increment token range repair of ${#lines_array[@]} total"
	exe_start=$(date +%s%3N)
        eval $line | logger -p local0.info -t repair
	exe_end=$(date +%s%3N)
	exe_total_time=$(($exe_end - $exe_start))
	echo "repair.${HOSTNAME//\./\_}.execution:$exe_total_time|ms" | nc -w 1 -u $STATSD_HOST $STATSD_PORT
    else
        echo "Exiting..."
        exit
    fi
done
