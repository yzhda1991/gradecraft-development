web: bundle exec puma -p $PORT
redis: redis-server --port $REDIS_PORT
bg: bundle exec rake resque:work
bg: bundle exec rake resque:scheduler
mongo: bundle exec mongod --dbpath=$MONGO_PATH --rest
