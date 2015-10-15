web: bundle exec puma -p $PORT
redis: redis-server --port $REDIS_PORT
bg: bundle exec rake resque:scheduler
bg: bundle exec rake resque:work
bg: bundle exec mailcatcher
mongo: bundle exec mongod --dbpath=$MONGO_PATH --rest
