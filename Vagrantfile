# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.box = 'ubuntu/trusty64'
    config.vm.provider 'virtualbox' do |v|
        v.memory = 1024
    end

    config.vm.network 'forwarded_port', guest: 5000, host: 5000

    config.vm.provision 'shell', inline: <<-SHELL
        set -xe

        # Set timezone
        echo "America/Detroit" > /etc/timezone
        dpkg-reconfigure -f noninteractive tzdata

        # Add repository for dependancies
        # Per https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
        echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.0 multiverse" >> /etc/apt/sources.list.d/mongodb-org-3.0.list

        # Update repositories and upgrade OS
        apt-get update -y
        apt-get dist-upgrade -y

        # Install dependancies
        apt-get --no-install-recommends install --yes \
            postgresql postgresql-contrib-9.3 \
            mongodb-org redis-server \
            sqlite3 libsqlite3-dev \
            nodejs git \
            build-essential libreadline-dev \
            libpq-dev libkrb5-dev \
            libxslt-dev libxml2-dev \
            ruby-dev ruby-railties-4.0

        cd /usr/src
        curl -s -O https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.2.tar.bz2
        tar xjf ruby-2.2.2.tar.bz2
        cd ruby-2.2.2/
        ./configure
        make
        make install

        cd /vagrant

        gem install bundler debugger-ruby_core_source

        mkdir -p /data/db
        chown -R vagrant:vagrant /data/db

        service mongod stop # foreman will start mongo as needed

        sed -i 's/start on runlevel \[2345\]/#start on runlevel \[2345\]/g' /etc/init/mongod.conf

        if [ ! -f config/mongoid.yml ]; then
            cp config/mongoid.yml.sample config/mongoid.yml
        fi

        if [ ! -f /vagrant/.env ]; then
            cat <<EOM > /vagrant/.env
NEW_RELIC_APP_NAME=GradeCraft
NEW_RELIC_LICENSE_KEY=123
RACK_ENV=development
RAILS_ENV=development
RAILS_TOKEN=gradecraft
RAILS_SECRET=changeme
REDIS_URL=redis://localhost:6379
REDIS_PORT=6379
TERM_CHILD=1
S3_BUCKET_NAME=<s3 bucket - used in production and staging>
AWS_ACCESS_KEY_ID=abc
AWS_SECRET_ACCESS_KEY=abc
EOM
        fi

        if [ ! -f /vagrant/config/database.yml ]; then
            cat <<EOM > /vagrant/config/database.yml
development:
  adapter: postgresql
  database: gradecraft_development
  min_messages: warning
  pool: 16
  # host: localhost
  username: vagrant
  # password:

test:
  adapter: postgresql
  database: gradecraft_test
  encoding: unicode
  min_messages: warning
  pool: 16
  # host: localhost
  username: vagrant
  # password:
EOM
        fi

        cat <<EOM >> ~vagrant/.bashrc
export REDIS_PORT=6379
export MONGO_PATH=/data/db
EOM

        # create a postgres user
        su postgres -c "createuser vagrant --superuser"

        su vagrant -c "bundle install"

        su vagrant -c "bundle exec rake db:create"
        su vagrant -c "bundle exec rake db:sample"

    SHELL
end
