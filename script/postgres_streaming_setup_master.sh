#!/usr/bin/env bash

#
# on the REPLICATION MASTER
#

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

if [ $# -eq 2 ]; then
  MASTER_IPA=$1
  SLAVE_IPA=$2
else
  echo "Usage: $0 <MASTER IPA> <SLAVE IPA>"
  exit 1
fi

REPLICATOR_DOT='/home/alice/.replicator_pwd'

if [ -f $REPLICATOR_DOT ]; then
  REPLICATOR_PWD=`cat $REPLICATOR_DOT`
else
  echo "$REPLICATOR_DOT not found. Exiting."
  exit 1
fi

echo "Begun"

echo "Preparing postgres streaming MASTER `hostname`."
echo "Continuing in 15 seconds. ^C to exit."

sleep 15

PG_HBA='/etc/postgresql/9.5/main/pg_hba.conf'
PG_CNF='/etc/postgresql/9.5/main/postgresql.conf'

echo "Stopping postgres"
sudo service postgresql stop

echo "Adjusting listen_addresses"
sudo -u postgres sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'\t/" $PG_CNF

echo "Adding to postgresql.conf"
sudo -u postgres bash -c "cat >> /etc/postgresql/9.5/main/postgresql.conf" <<EOF
ssl=on
wal_level=hot_standby
wal_log_hints=on
wal_keep_segments=1000
max_wal_senders=6
max_replication_slots=6
hot_standby=on
hot_standby_feedback=on
full_page_writes=on
EOF

echo "Adding to pg_hba.conf"
sudo -u postgres bash -c "cat >> $PG_HBA" <<EOF
hostssl    replication replicator MASTER_IPA/32 trust
hostssl    replication replicator SLAVE_IPA/32  trust
EOF

echo "Using MASTER_IPA = $MASTER_IPA"
echo "Using SLAVE_IPA = $SLAVE_IPA"

sudo -u postgres sed -i "s/MASTER_IPA/$MASTER_IPA/" $PG_HBA
sudo -u postgres sed -i "s/SLAVE_IPA/$SLAVE_IPA/" $PG_HBA

echo "Adding replicator user"
sudo -u postgres psql -c "DROP USER IF EXISTS replicator;"
sudo -u postgres psql -c "CREATE USER replicator REPLICATION LOGIN ENCRYPTED PASSWORD $REPLICATOR_PWD;"
sudo -u postgres psql -d postgres -c "SELECT * FROM pg_create_physical_replication_slot('standby1');"

echo "Restarting postgres"
sudo service postgresql start

#sudo -u postgres psql -x -c "select * from pg_stat_replication;"

echo "Ended"