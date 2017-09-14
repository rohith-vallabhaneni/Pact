#!/bin/bash

sed -i 's/$DRP_CF_HTTP_PORT/${DRP_CF_HTTP_PORT}/g' /etc/nginx/sites-enabled/webapp.conf
