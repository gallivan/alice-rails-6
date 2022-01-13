if [ "$(whoami)" == "alice" ]; then
        echo "you are user alice"
else
        echo "you are NOT user alice"
fi

if [[ -n $1 ]]; then
  DATE=$1
else
  DATE=$(date +%Y%m%d)
fi
echo "${DATE}"

bundle exec rake eod:run["${DATE}"] --silent