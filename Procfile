# make sure processes run in the foreground
web: bundle exec rails server thin -p $PORT -e $RACK_ENV
redis_dev:    redis-server ./config/redis/development.conf
#resque: env TERM_CHILD=1 RESQUE_TERM_TIMEOUT=10 QUEUE=* bundle exec rake resque:work
