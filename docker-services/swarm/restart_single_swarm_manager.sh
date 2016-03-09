#!/bin/bash

log="/tmp/local-swarm.log"
if [ -f $log ] ; then
    truncate --size=0 $log
fi

hostfqdn="localhost"
swarmdiscoveryport=4000
consuldiscoveryport=8500
uniqueswarmprefix="developmentswarm"

echo "Starting Single Swarm Manager Listening on: $hostfqdn:$swarmdiscoveryport " >> $log
nohup /usr/local/bin/swarm manage -H tcp://$hostfqdn:$swarmdiscoveryport --advertise $hostfqdn:$swarmdiscoveryport consul://$hostfqdn:$consuldiscoveryport/$uniqueswarmprefix &>> $log &
# Lets not jump the gun
until tail -3 $log | grep -q 'Listening for HTTP'; do
    echo -n '.';
    sleep 0.1;
done
echo
echo "Done Starting Swarm Manager" >> $log

exit 0

