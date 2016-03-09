#!/bin/bash

log="/tmp/local-joinswarm.log"
if [ -f $log ] ; then
    truncate --size=0 $log
fi
hostfqdn="localhost"
swarmdiscoveryport=4000
consuldiscoveryport=8500
uniqueswarmprefix="developmentswarm"

echo "Starting Swarm Join on: consul://$hostfqdn:$consuldiscoveryport/$uniqueswarmprefix" >> $log
nohup /usr/local/bin/swarm join --addr=$hostfqdn:2375 consul://$hostfqdn:$consuldiscoveryport/$uniqueswarmprefix &>> $log &

# Lets not jump the gun
until tail -3 $log | grep -q 'Registering'; do
    echo -n '.';
    sleep 0.1;
done
echo
echo "Done Starting Swarm Join" >> $log

