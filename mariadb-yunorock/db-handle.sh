#!/usr/bin/env sh

if [ $# -lt 4 ] ; then
	echo "usage:" 1>&2
	echo "		$0 command arguments" 1>&2
	echo "		$0 exist rootdbpass user dbname" 1>&2
	echo "		$0 create rootdbpass user userpass dbname" 1>&2
	echo "		$0 delete rootdbpass user dbname" 1>&2
	echo "		$0 check-or-create rootdbpass user userpass dbname" 1>&2
	exit 1
fi

ACTION="$1"
PASSWD="$2"
USER="$3"

case "$ACTION" in

	"exist" ) 
		[ $# -ne 4 ] && echo "Argument count mismatch" 1>&2 && exit 1
		DBNAME="$4"
		mysql -p"$PASSWD" << END | grep $USER >/dev/null 2>/dev/null
use mysql;
select User from user where User='$USER' ;
END
		[ $? -ne 0 ] && exit 1
		mysql -p"$PASSWD" << END | grep $DBNAME >/dev/null 2>/dev/null
show databases;
END
		[ $? -ne 0 ] && exit 1
		exit 0
		;;

	"create" )
		[ $# -ne 5 ] && echo "Argument count mismatch" 1>&2 && exit 1
		USERPASS="$4"
		DBNAME="$5"
		mysql -p"$PASSWD" << END
create database if not exists $DBNAME;
create user $USER@localhost;
set password for $USER@localhost = password('$USERPASS');
grant all on $DBNAME.* to $USER@localhost;
END
		;;

	"delete" ) 
		[ $# -ne 4 ] && echo "Argument count mismatch" 1>&2 && exit 1
		DBNAME="$4"
		mysql -p"$PASSWD" << END
drop database if exists $DBNAME;
END
		mysql -p"$PASSWD" << END
DROP USER $USER@localhost;
END
		;;

	"check-or-create" )
		[ $# -ne 5 ] && echo "Argument count mismatch" 1>&2 && exit 1
		USERPASS="$4"
		DBNAME="$5"
		sh $0 exist $PASSWD $USER $DBNAME || sh $0 create $PASSWD $USER $USERPASS $DBNAME
		;;

	"*")
		echo "Wrong command $ACTION"
		exit 1
		;;
esac
