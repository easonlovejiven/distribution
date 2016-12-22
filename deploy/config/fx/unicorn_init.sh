#!/bin/sh
APP_ROOT=/var/www/fx/current
PID=$APP_ROOT/tmp/pids/unicorn.pid
ENV=production
CMD="cd $APP_ROOT; bundle exec unicorn -D -c $APP_ROOT/config/unicorn.rb -E production"
OLD_PIN="$PID.oldbin"
AS_USER=hong

sig () {
  test -s "$PID" && kill -$1 `cat $PID`
}

oldsig () {
  test -s $OLD_PIN && kill -$1 `cat $OLD_PIN`
}
run () {
  if [ "$(id -un)" = "$AS_USER" ]; then
    eval $1
  else
    su -c "$1" - $AS_USER
  fi
}


case "$1" in
  start)
  sig 0 && echo >&2 "Already running" && exit 0
  run "$CMD"
  ;;
  stop)
  kill -QUIT `cat $PID`
  ;;
  restart|force-reload)
    kill -USR2 `cat $PID`
  ;;
  *)
   echo "Usage: $SCRIPTNAME {start|stop|restart|force-reload}" >&2
   exit 3
   ;;
esac

:
