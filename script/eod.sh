#!/usr/bin/env bash

echo '##########################################################################'
echo running $0
echo '##########################################################################'

if [ "$(whoami)" == "alice" ]; then
  source "${HOME}"/www/alice-rails-6/current/script/environment.sh
else
  source ~/ruby-projects/alice/script/environment.sh
fi

echo '##########################################################################'
echo 'env dump'
echo '##########################################################################'

env

echo '##########################################################################'
echo 'set timezone'
echo '##########################################################################'

export TZ='America/Chicago'

echo '##########################################################################'
echo 'set date'
echo '##########################################################################'

if [[ -n $1 ]]; then
  DATE=$1
else
  DATE=$(date +%Y%m%d)
fi

echo "Running with date $DATE"

echo '##########################################################################'
echo 'set runtime directory and dump db'
echo '##########################################################################'

if [ "$(whoami)" == "alice" ]; then
  cd "${APP_DIR}"/current
else
  cd ~/ruby-projects/alice/
fi

echo '##########################################################################'
echo 'rails env check'
echo '##########################################################################'

if [[ -z "${RAILS_ENV}" ]]; then
  echo "Variable RAILS_ENV does not exist. Exiting."
  exit 1
fi

echo '##########################################################################'
echo 'dump db eod pre'
echo '##########################################################################'

if [ "${RAILS_ENV}" == "production" ]; then
  bundle exec rake db:dump[alice_"${RAILS_ENV}",pre]
  mv alice*pgr ~/dumps
  bundle exec rake eod:sync_dumps
else
  echo "Skipping DB dump - not production."
fi

echo '##########################################################################'
echo 'clear log and run eod'
echo '##########################################################################'

bundle exec rake log:clear
bundle exec rake --trace eod:run["${DATE}"]
#bundle exec rake eod:run[20210111] #--silent

if (($? != 0)); then
  echo 'abnormal return. exiting'
  exit 1
fi

echo '##########################################################################'
echo 'sync var'
echo '##########################################################################'

if [ "${RAILS_ENV}" == "production" ]; then
  bundle exec rake eod:sync_var
else
  echo "Skipping eod:sync_var - not production."
fi

echo '##########################################################################'
echo 'update Claim and ClaimSet instances using Quandl names'
echo '##########################################################################'

bundle exec rake quandl:claim_name_reset_fixme

echo '##########################################################################'
echo 'dump db eod post'
echo '##########################################################################'

if [ "${RAILS_ENV}" == "production" ]; then
  bundle exec rake db:dump[alice_"${RAILS_ENV}",post]
  mv alice*pgr ~/dumps
  bundle exec rake eod:sync_dumps
else
  echo "Skipping DB dump - not production."
fi

echo '##########################################################################'
echo 'trim dump file set'
echo '##########################################################################'

if [ "${RAILS_ENV}" == "production" ]; then
  find ~/dumps -type f -name '*.pgr' -mtime +7 -exec rm {} \;
else
  echo "Skipping DB dump trim - not production."
fi

echo '##########################################################################'
echo 'done'
echo '##########################################################################'

unset TZ
