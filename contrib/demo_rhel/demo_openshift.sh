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

run sudo gear deploy $base/deploy_openshift.json localhost
run sudo journalctl --unit ctr-openshift-broker-1 -f --since=-3 -q
run sudo switchns --container="openshift-broker-1" --env="BROKER_SOURCE=1" --env="HOME=/opt/ruby" --env="OPENSHIFT_BROKER_DIR=/opt/ruby/src/broker" -- /bin/bash --login -c "/opt/ruby/src/docker/openshift_init"
