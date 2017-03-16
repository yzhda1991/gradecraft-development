## Basic Installation Notes (last update: 08/17/16) for running without Vagrant

    git clone https://github.com/UM-USElab/gradecraft-development.git
    brew install mongodb
    brew install redis
    
    cp config/database.yml.sample config/database.yml
    cp config/mongoid.yml.sample config/mongoid.yml

    # you will need to get additions credentials and/or delete production keys:
    cp .env.sample .env
     
    bundle install
    bundle exec rake db:create
    bundle exec rake db:sample

    gem install lunchy #for running mongodb
    lunchy start mongo
    redis-server /usr/local/etc/redis.conf

foreman start -f Procfile
or
redis-server --port 7372

## Running Sample data

    rake db:sample


## Notes:

If you have issues with Gemfile.lock corruption notices, try using Bundler -v 1.10.6
It is possible there is a corrupt lock file that is only detected in newer versions of Bundler.
