#!/usr/bin/env bash
export TZ='America/Chicago'
DATE=`date +%Y%m%d`
pg_dump --verbose -Fc -f alice_production_${DATE}.pgr alice_production
unset TZ

