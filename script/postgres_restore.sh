#!/bin/bash

if [ "$1" == "" ]; then
  echo "Usage: `basename $0` <dump_file>"
  exit
fi

if [ -z "$PG_HOST" ]; then
  PG_HOST=localhost
else
  echo "Using $PG_HOST"
fi

if which pg_restore >/dev/null; then
  pg_restore --verbose --clean --no-acl --jobs=8 --no-owner -h $PG_HOST -U alice -d alice_development $1
else
  echo "pg_restore not found. exiting."
  exit
fi

