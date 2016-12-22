#!/bin/bash
#
# Init file for searchd
#
# chkconfig: 2345 55 25
#
# description: searchd 
#
# USE "chkconfig --add searchd" to configure Sphinx searchd service
#
# by Steve Kamerman April 14, 2010
# http://www.tera-wurfl.com
# public domain

SUDO_USER=sphinx

BASE_PATH=/usr/local/sphinx
PID_FILE=$BASE_PATH/var/log/searchd.pid
CONFIG_FILE=$BASE_PATH/etc/sphinx.conf

EXEC_PATH=$BASE_PATH/bin
LOG_PATH=$BASE_PATH/var/log
DATA_PATH=$BASE_PATH/var/data

RETVAL=0
prog="searchd"

do_config() {
	chown -R $SUDO_USER $EXEC_PATH
	chown -R $SUDO_USER $CONFIG_FILE
	chown -R $SUDO_USER $DATA_PATH
	chown -R $SUDO_USER $LOG_PATH

	chmod 600 $CONFIG_FILE
	chmod u+rwx $EXEC_PATH/*
	chmod -R u+rw,go-rwx $DATA_PATH
	chmod -R u+rw,go-rwx $LOG_PATH
}

do_start() {
	echo "Starting $prog"
	sudo -u $SUDO_USER $EXEC_PATH/$prog --config $CONFIG_FILE
	RETVAL=$?
	echo
	return $RETVAL
}

do_stop() {
	echo "Stopping $prog"
	if [ -e $PID_FILE ] ; then
		sudo -u $SUDO_USER $EXEC_PATH/$prog --stop
		sleep 2
		if [ -e $PID_FILE ] ; then
			echo "WARNING: searchd may still be alive: $PID_FILE"
		fi
	fi
	RETVAL=$?
	echo
	return $RETVAL
}

do_status() {
	RETVAL=$?
	if [ -e $PID_FILE ] ; then
 		sudo -u $SUDO_USER $EXEC_PATH/$prog --status
		echo "---"
		echo "$prog is running (`cat $PID_FILE`)"
	else
		echo "$prog is not running"
	fi
	return $RETVAL
}

do_reindex() {
	echo "Reindexing all $prog indices"
	if [ -e $PID_FILE ] ; then
		sudo -u $SUDO_USER $EXEC_PATH/indexer --all --rotate
	else
		sudo -u $SUDO_USER $EXEC_PATH/indexer --all
	fi
	echo "done."
	echo
	RETVAL=$?
	return $RETVAL
}

case $* in

config)
	do_config
	;;

start)
	do_start
	;;

stop)
	do_stop
	;;

status)
	do_status
	;;

reindex)
	do_reindex
	;;

*)
	echo "usage: $0 {start|stop|config|status|reindex}" >&2

	exit 1
	;;
esac

exit $RETVAL