#!/bin/sh

base=$(dirname $0)

trap "echo" SIGINT

function run() {
  echo
  echo -e -n "\e[36m\$\e[33m $@\e[0m"
  read
  eval $@
}

echo

run gear deploy $base/deploy_mongo_repl_set.json localhost
run sudo journalctl --unit ctr-replset-db-1 -f --since=-3 -q
run "sudo switchns --container=replset-db-1 -- /usr/bin/mongo local --eval 'printjson(rs.initiate({_id: \"replica0\", version: 1, members:[{_id: 0, host:\"192.168.1.1:27017\"},{_id: 1, host:\"192.168.1.2:27017\"},{_id: 2, host:\"192.168.1.3:27017\"}]}))'" #; printjson(rs.add(\"192.168.1.2\")); printjson(rs.add(\"192.168.1.3\"))'"
run "sudo switchns --container=replset-db-1 -- /usr/bin/mongo local --eval 'printjson(rs.status())'"
run "sudo switchns --container=replset-db-1 -- /usr/bin/mongo local --eval 'printjson(rs.status())'"

if [ "$SKIP_CLEANUP" == "" ]; then
  gear stop --with=$base/deploy_mongo_repl_set_instances.json > /dev/null &
fi