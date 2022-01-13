# alice

[comment]: <> (https://gist.githubusercontent.com/jonschlinkert/ac5d8122bfaaa394f896/raw/bd1106691cf344e972f575c49ba3cf281beeb9b3/markdown-toc_repeated-headings.md)

- [Introduction](#Introduction)
- [Dependencies](#Dependencies)
- [Architecture](#Architecture)
- [Source Host Setup](#SourceHostSetup)
- [Target Host Setup](#TargetHostSetup)


## Introduction

Think in terms of Source and Target hosts where Source is you local (development) box
and Target is one or more deployment hosts.

##############################################################################################
##############################################################################################
##############################################################################################

## Dependencies

* Ubuntu 20.04 LTS
* Github
* Linode VM Setup
* Linode DNS Setup
* Memcached
* PostgreSQL 12
* Node.js
* Yarn
* RVM
* Ruby 2.7.2
* Rails 6.1.4.4
* Shell ENV
* Puma
* Nginx
* Let's Encrypt
* Nginx + Puma
* Firewall

##############################################################################################
##############################################################################################
##############################################################################################

## Architecture

TBD

##############################################################################################
##############################################################################################
##############################################################################################

## SourceHostSetup

Ubuntu 20.04 is the current, target platform.

### Shell environment variables

The runtime environment requires variables set from $RAILS_ROOT/script/environment.sh.

```console
# runtime environment identification

export RAILS_ENV=development
#export RAILS_ENV=test
#export RAILS_ENV=integration
#export RAILS_ENV=staging
#export RAILS_ENV=production

# miscellaneous

export EDITOR=vi
export PATH="$PATH:$HOME/.rvm/bin" 
export sendgridusername=jay.gallivan@gmail.com
export APP_DIR='/home/alice/www/alice-rails-6'

# secrects

export SECRET_KEY_BASE=`cat ~/www/alice-rails-6/shared/config/master.key`
export DEVISE_TOKEN_AUTH_SECRET_KEY=`cat ~/.devise_token_auth_secret_key`
export sendgridpassword=`cat ~/.sendgrid_pwd`
export QUANDL_API_KEY=`cat ~/.quandl_api_key`

# source of passwords for SFTP sessions

export SFTP_CME_USR=`cat ~/.sftp_cme_usr`
export SFTP_CME_PWD=`cat ~/.sftp_cme_pwd`
export SFTP_CFTC_USR=`cat ~/.sftp_cftc_usr`
export SFTP_CFTC_PWD=`cat ~/.sftp_cftc_pwd`

# directories for files, pulled and created

export LRG_DIR=$HOME/var/lrg
export TXT_DIR=$HOME/var/txt
export PDF_DIR=$HOME/var/pdf
export DNL_DIR=$HOME/var/dnl
```

Dot files might be had by making the following calls, substituting NODE for the source host.

```console
scp alice@NODE:~/.sftp* .
scp alice@NODE:~/.quandl_api_key .
scp alice@NODE:/.sendgrid_pwd .
scp alice@NODE:/.DEVISE_TOKEN_AUTH_SECRET_KEY .
```

### Application Server Data Directory Creation

Several directories are used for storing files. Files are of type data download, data
created and database dumps.

```console
mkdir -p ~/var/dnl/cme
mkdir -p ~/var/dnl/spn
mkdir -p ~/var/pdf
mkdir -p ~/var/txt
mkdir -p ~/var/lrg
mkdir -p ~/dumps
```

### PDF Generation and Email

alice creates PDF files written to ~/var. These files are accessible through the UI and
some are distributed as email attachments. The following commands install the necessary PDF
generation and email utilities.

```console
sudo apt install enscript
sudo apt install ghostscript
sudo apt install mailutils
```

### Memcached

Application performance is improved significantly trough the use of a data cache. Without
cache, all data access goes to the database, involving network roundtrips and disk
reads. A cache layer will delegate to the database only when the data requested is not in
cache. The following command installs the memcached.

```console
sudo apt-get install memcached
```

### PostgreSQL

alice expects to use PostgreSQL as the relational database store. The following calls install
PostgreSQL, create the administrative user alice and grant alice rights to the database so
created.

Install PostgreSQL software.

```console
sudo apt install postgresql postgresql-contrib libpq-dev
```

Create the PostgreSQL user 'alice'. Store the password in ~/.alice_db_pwd.

```console
sudo -u postgres createuser --pwprompt --createdb --login --createrole alice
```

Create the database to be used by the application, per the Target role.

```console
sudo -u postgres createdb -O alice alice_development
#sudo -u postgres createdb -O alice alice_integration
#sudo -u postgres createdb -O alice alice_staging
#sudo -u postgres createdb -O alice alice_production
```

Grant privileges to the user 'alice'.

```console
sudo -u postgres psql -c 'grant all privileges on database alice_development to alice;'
#sudo -u postgres psql -c 'grant all privileges on database alice_integration to alice;'
#sudo -u postgres psql -c 'grant all privileges on database alice_staging to alice;'
#sudo -u postgres psql -c 'grant all privileges on database alice_production to alice;'
```

### Node.js and Yarn

Node.js is a Javascript runtime and Yarn a package manager. Install [Node.js](https://nodejs.org/en/) and [Yarn](https://yarnpkg.com).

```console
sudo apt update
sudo apt upgrade

sudo apt install curl
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install yarn
```

### RVM and Ruby

Ruby on Rails requires Ruby. The following instructions for Ruby installation
were lifted from [here](https://gorails.com/setup/ubuntu/20.04#ruby-rvm).

Install [RVM](https://rvm.io/) and [Ruby](https://www.ruby-lang.org/en/).

```console
sudo apt-get update
sudo apt upgrade

sudo apt-get install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 2.7.2
rvm use 2.7.2 --default
gem install bundler
rvm gemset create rails-5.2.4.4
rvm use 2.7.2@rails-5.2.4.4 --default
gem install bundler
```

### RubyMine

The IDE I use is [RubyMine](https://www.jetbrains.com/ruby/) from JetBrains.

With RubyMine installed you should be able to open a new project, pointing to the Github repo.

##############################################################################################
##############################################################################################
##############################################################################################

## TargetHostSetup

This section identifies dependencies for Alice and scripts setup on a 
hosting service, e.g., Linode.

### VM Setup

Setup a new VM on your host provider. These instructions assume Ubuntu 20.04 
with shell access and build upon those given for Source host setup.

### Disable SSH root Access

Follow [these](https://askubuntu.com/questions/27559/how-do-i-disable-remote-ssh-login-as-root-from-a-server) instructions.

### User Setup

On the target host, the user alice must be created.

```console
sudo adduser alice
sudo adduser alice sudo
```

Update ~/.bashrc per Source instructions above. Update the following, per Target role.

```console
#export RAILS_ENV=development
#export RAILS_ENV=test
#export RAILS_ENV=integration
export RAILS_ENV=staging
#export RAILS_ENV=production
```

Update ~/.bash_aliases also.

```console
alias current='cd ~/www/alice-rails-6/current'
alias shared='cd ~/www/alice-rails-6/shared'
```

Source host Setup SSH keys now too, where NODE is the host name for the FQDN.

```console
ssh-keygen -t rsa -b 4096 # if not yet done
ssh-copy-id alice@NODE.jackijack.com
```

Set the hostname also, and reboot for the hostname change to effect.

```console
sudo vi /etc/hostname # set hostname
sudo reboot now
```

### Operating System Update

The default image will likely not be uptodate.

```console
sudo apt update
sudo apt upgrade
sudo reboot now
```
### PostgreSQL

PostgreSQL has a rich set of connection options. AS typically setup, the database runs on the
same host as the application - so connection requests can be trusted. The following fragment of
pg_hba.conf identifies local access as trusted.

```console
cd /etc/postgresql/12/main
sudo cp pg_hba.conf pg_hba.conf.orig
sudo vi pg_hba.conf
```

Edit so "from" makes "to".

```console
-- from --
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5

-- to --
host    all             all             127.0.0.1/32            trust #md5
host    all             all             ::1/128                 trust #md5
```

Once pg_hba.conf has been updated, PostgreSQL must be restarted.

```console
sudo service postgresql restart
```

### Shared Config Files

Using RVM and [Capistrano](https://capistranorb.com/) our deployment utility requires setup
of some share files. On the Target host, execute the following command as user alice.

``` console
mkdir -p /home/alice/www/alice-rails-6/shared/config
```

On your Source, execute the following commands, substituting the appropriate FQDN to identify
the target host. The secrets are not kept in source code. If not available locally, pull them
from a running host to your local.

```console
cd ~/ruby-projects/alice-rails-6
scp config/master.key alice@NODE:~/www/alice-rails-6/shared/config
scp config/database.yml alice@NODE:~/www/alice-rails-6/shared/config
scp config/secrets.yml alice@NODE:~/www/alice-rails-6/shared/config
```

Once the shared configuration directory has been created and configurations copied, the 
application can be deployed. On your Source host, execute the following command. Note the
importance of runtime environment specification. The first deployment will take some time
as much work will be done.

```console
cap integration deploy
#cap staging deploy
#cap production deploy
```

With Ruby, Rails and PostgreSQL installed the database can be restored from ad dump
substituting for the name as needed. This can be tested.

```console
alice@stg:~$ current
alice@stg:~/www/alice-rails-6/current$ bundle exec rails c
Loading staging environment (Rails 5.2.4.4)
2.7.2 :001 > Account.count
 => 0 
2.7.2 :002 > exit
alice@stg:~/www/alice-rails-6/current$ 
```

With the environment setup and Rails running a database dump can be applied. Substitute for
patter YYYYMMDD as needed.

```console
cd ~/dumps
scp alice@emm4.jackijack.com:~/dumps/alice_production_YYYYMMDD_post.pgr .
current
bundle exec rails db:restore[localhost,alice_staging,alice,/home/alice/dumps/alice_production_YYYYMMDD_post.pgr]
#bundle exec rails db:restore[localhost,alice_integration,alice,/home/alice/dumps/alice_production_YYYYMMDD_post.pgr]
```

A concrete example of this follows.

```console
bundle exec rails db:restore[localhost,alice_staging,alice,/home/alice/dumps/alice_production_20210108_post.pgr]
```

### Nginx, Puma and Certificates 

This deployment implementation relies on [Nginx](https://www.nginx.com/) as the HTTP server and
[Puma](https://puma.io/) as the application server. The following were consulted.

```console
https://www.tecmint.com/install-nginx-on-ubuntu-20-04/
https://matthewhoelter.com/2020/11/10/deploying-ruby-on-rails-for-ubuntu-2004.html
https://blog.nousefreak.be/blog/letsencrypt-nginx-reverse-proxy
```

#### Nginx Installation

First, Nginx must be installed.

```console
sudo apt install nginx
```

### letsencrypt

Nginx interactions must be certificate secured. The following sources were consulted.

```console
# https://letsencrypt.org/getting-started/
# https://certbot.eff.org/lets-encrypt/ubuntufocal-nginx
```

#### Certiicate Installation

The installation of certbot should be done using snap. Below is a root domain certificate
request.

```console
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --nginx --email jay.gallivan@gmail.com -d stg.jackijack.com
```

Test certificate renewal as follows.

```console
sudo certbot renew --dry-run
```

Because certificate acquisition can seem opaque, the following shows full i/o.

```console
alice@stg:/etc/nginx$ sudo certbot certonly --nginx --email jay.gallivan@gmail.com -d stg.jackijack.com
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator nginx, Installer nginx
Requesting a certificate for stg.jackijack.com
Performing the following challenges:
http-01 challenge for stg.jackijack.com
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/stg.jackijack.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/stg.jackijack.com/privkey.pem
   Your certificate will expire on 2021-04-24. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

Now the certificate renewal call, as a --dry-run.

```console
alice@stg:/etc/nginx$ sudo certbot renew --dry-run
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/stg.jackijack.com.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cert not due for renewal, but simulating renewal for dry run
Plugins selected: Authenticator nginx, Installer nginx
Account registered.
Simulating renewal of an existing certificate for stg.jackijack.com
Performing the following challenges:
http-01 challenge for stg.jackijack.com
Waiting for verification...
Cleaning up challenges

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
new certificate deployed with reload of nginx server; fullchain is
/etc/letsencrypt/live/stg.jackijack.com/fullchain.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded: 
  /etc/letsencrypt/live/stg.jackijack.com/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

#### Include root Certificate

```console
sudo certbot certonly --nginx --email jay.gallivan@gmail.com -d NODE.jackijack.com -d jackijack.com
```

#### Certificate Revocation

The certbot utility supports certificate revocation.

```console
sudo certbot revoke --cert-path /etc/letsencrypt/archive/FQDN/cert1.pem
```

#### Nginx Setup for Puma/Rails

Nginx behavior is driven by configuration stored in the repository so files do not need to be edited
on each host but links do. Create links as follows.

```console
cd /etc/nginx
sudo mv nginx.conf nginx.conf.orig
sudo ln -s /home/alice/www/alice-rails-6/current/config/nginx.conf nginx.conf
```

Define available sites.
```console
cd /etc/nginx/sites-available
sudo ln -s /home/alice/www/alice-rails-6/current/config/nginx-alice-rails-6.conf alice-rails-6
```

Define sites enabled

```console
cd /etc/nginx/sites-enabled
sudo rm ./default
sudo ln -s ../sites-available/alice-rails-6 alice-rails-6
```

There is one exception to the use of links: snippets/ssl.conf. That file contains the FQDN
of the host. The file must be created on each Nginx host.

Setup SSL configuration.

```console
cd /etc/nginx/snippets
sudo ln -s /home/alice/www/alice-rails-6/current/config/nginx_ssl.conf ssl.conf
```

The certificate PEM files include needs to be set up. Replace FQDN per node.

```console
cd /etc/nginx/snippets
sudo vi pem.conf
ssl_certificate         /etc/letsencrypt/live/FQDN/fullchain.pem;
ssl_certificate_key     /etc/letsencrypt/live/FQDN/privkey.pem;
ssl_trusted_certificate /etc/letsencrypt/live/FQDN/fullchain.pem;
```

Puma needs to be started on Target. So on Source....

```console
cd ~/ruby-projects/alice-rails-6
#cap integration puma:start
cap staging puma:start
#cap production puma:start
```

With Nginx configured, it can be restarted.

```console
sudo service nginx restart
```

### crontab

Update crontab with the following. The Targets run on UTC. Daylight savings time,
CDT vs CST, means the active entry will be determined by local timezone.

```console
# US Standard Time
#30 02 * * 2-6 cd /home/alice/www/alice-rails-6/current && /bin/bash -l -c '/home/alice/www/alice-rails-6/current/script/eod.sh'
# US Daylight Time
#30 01 * * 2-6 cd /home/alice/www/alice-rails-6/current && /bin/bash -l -c '/home/alice/www/alice-rails-6/current/script/eod.sh'
```


### Firewall

```console
https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-16-04
```

```console
#sudo ufw default deny incoming
#sudo ufw default allow outgoing
sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw allow "Nginx Full"
sudo ufw enable
sudo ufw status
sudo reboot now```

