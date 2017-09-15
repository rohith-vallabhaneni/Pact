#!/bin/bash

#sed -i 's/$DRP_CF_HTTP_PORT/${DRP_CF_HTTP_PORT}/g' /etc/nginx/sites-enabled/webapp.conf

export PACT_BROKER_DATABASE_USERNAME=$(echo $DRP_EV_POSTGRESQL_URL | cut -d: -f2 | cut -d/ -f3)
export PACT_BROKER_DATABASE_PASSWORD=$(echo $DRP_EV_POSTGRESQL_URL | cut -d@ -f1 | cut -d: -f3)
export PACT_BROKER_DATABASE_HOST=$(echo $DRP_EV_POSTGRESQL_URL | cut -d@ -f2 | cut -d: -f1)
export PACT_BROKER_DATABASE_NAME=$(echo $DRP_EV_POSTGRESQL_URL | cut -d/ -f4)
#echo $PACT_BROKER_DATABASE_USERNAME
#echo $PACT_BROKER_DATABASE_PASSWORD
#echo $PACT_BROKER_DATABASE_HOST
#echo $PACT_BROKER_DATABASE_NAME

