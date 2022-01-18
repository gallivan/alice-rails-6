#!/usr/bin/env bash

export DEVISE_TOKEN_AUTH_SECRET_KEY=`cat ~/.devise_token_auth_secret_key`

export sendgridusername='apikey'
export sendgridpassword=`cat ~/.sendgrid_pwd`

export QUANDL_API_KEY=`cat ~/.quandl_api_key`

export SFTP_CME_USR=`cat ~/.sftp_cme_usr`
export SFTP_CME_PWD=`cat ~/.sftp_cme_pwd`

export SFTP_CFTC_USR=`cat ~/.sftp_cftc_usr`
export SFTP_CFTC_PWD=`cat ~/.sftp_cftc_pwd`

export TXT_DIR=$HOME/var/txt
export PDF_DIR=$HOME/var/pdf
export DNL_DIR=$HOME/var/dnl
export LRG_DIR=$HOME/var/lrg
export STL_DIR=$HOME/var/stl

# todo why do i need to define this here?

if [ `hostname` == 'emm3' ] || [ `hostname` == 'emm4' ]; then
  export RAILS_ENV='production'
elif [ `hostname` == 'stg' ]; then
  export RAILS_ENV='staging'
elif [ `hostname` == 'int' ]; then
  export RAILS_ENV='integration'
else
  export RAILS_ENV='development'
fi

if [ ${RAILS_ENV} == 'production' ]; then
  export VAR_HOST_1='emm4.jackijack.com'
  export VAR_HOST_2='emm3.jackijack.com'
else
  echo "Nothing to set for VAR_HOST_1/2"
fi

# ruby-2.7.2@rails-6.1.4.4

if [ ${RAILS_ENV} == 'development' ]; then
  export APP_DIR=$HOME/ruby-projects/alice-rails-6
  export PATH="$HOME/.rvm/gems/ruby-2.7.2@rails-6.1.4.4/bin:$HOME/.rvm/gems/ruby-2.7.2@global/bin:$HOME/.rvm/rubies/ruby-2.7.2/bin:$PATH"
  export GEM_HOME='$HOME/.rvm/gems/ruby-2.7.2@rails-6.1.4.4'
  export GEM_PATH='$HOME/.rvm/gems/ruby-2.7.2@rails-6.1.4.4:$HOME/.rvm/gems/ruby-2.7.2@global'
  export MY_RUBY_HOME='$HOME/.rvm/rubies/ruby-2.7.2'
  export IRBRC='$HOME/.rvm/rubies/ruby-2.7.2/.irbrc'
  export RUBY_VERSION='ruby-2.7.2'
  export SECRET_KEY_BASE=`cat ~/ruby-projects/alice-rails-6/config/master.key`
else
  export APP_DIR=$HOME/www/alice-rails-6
  export PATH="/home/alice/.rvm/gems/ruby-2.7.2@rails-6.1.4.4/bin:/home/alice/.rvm/gems/ruby-2.7.2@global/bin:/home/alice/.rvm/rubies/ruby-2.7.2/bin:$PATH"
  export GEM_HOME='/home/alice/.rvm/gems/ruby-2.7.2@rails-6.1.4.4'
  export GEM_PATH='/home/alice/.rvm/gems/ruby-2.7.2@rails-6.1.4.4:/home/alice/.rvm/gems/ruby-2.7.2@global'
  export MY_RUBY_HOME='/home/alice/.rvm/rubies/ruby-2.7.2'
  export IRBRC='/home/alice/.rvm/rubies/ruby-2.7.2/.irbrc'
  export RUBY_VERSION='ruby-2.7.2'
  export SECRET_KEY_BASE=`cat ~/www/alice-rails-6/shared/config/master.key`
fi

cd $APP_DIR