#!/bin/bash

VOLUME_HOME="/var/lib/mysql"
CONF_FILE="/etc/mysql/conf.d/my.cnf"
LOG="/var/log/mysql/error.log"

chmod 644 ${CONF_FILE}
chmod 644 /etc/mysql/conf.d/mysqld_charset.cnf

StartMySQL ()
{ 
    echo "Stage :StartMySQL() NoPwd start"
    # /usr/bin/mysqld_safe --skip-grant-tables > /dev/null 2>&1 &
    /usr/bin/mysqld_safe  > /dev/null 2>&1 &

    # Time out in 1 minute
    LOOP_LIMIT=5
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Time out. Error log is shown as below:"
            tail -n 100 ${LOG}
            exit 1
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
	mysql -uroot -e "status"
        mysql -uroot -e "status" > /dev/null 2>&1 && break
    done
   echo "Stage :StartMySQL() NoPwd end..."
}

StartMySQLWithPwd()
{
	echo "Stage :StartMySQLWithPwd() start"
    # /usr/bin/mysqld_safe --skip-grant-tables > /dev/null 2>&1 &
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    # Time out in 1 minute
    LOOP_LIMIT=5
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Time out. Error log is shown as below:"
            tail -n 100 ${LOG}
            exit 1
        fi
        echo "#### Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -proot -e "status"
        mysql -uroot -proot -e "status" > /dev/null 2>&1 && break
    done
    echo "Stage :StartMySQLWithPwd() end... "
}


CreateMySQLUser()
{
        echo "Stage :CreateMySQLUser() start"
	StartMySQL
	PASS="test123"
	mysql -uroot -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '$PASS'"
#        echo c1
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION"
#	echo c2

	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION;" 
#	echo c3
	mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;" 
#	echo c4 
#	mysql -uroot -proot -e "ALTER USER 'root'@'%' IDENTIFIED BY 'root'; " 
#	echo c5
#	mysql -uroot -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'root' "  
#	echo c6
	mysql -uroot -proot -e "FLUSH PRIVILEGES;" 
#	echo c7
	mysqladmin -uroot -proot shutdown 
#	 echo c8
#       mysql -uroot -proot -e "status" 
#	echo c9
	echo "Stage :CreateMySQLUser() end"
}

ImportSql()
{
       echo "Stage :ImportSql() start"
       StartMySQLWithPwd
       if [ -d "/var/lib/mysql/petclinic" ]; then 
          echo '>>>> petclinic already present, skipping creation'
       else 
        echo '>>>> petclinic DB creation'
       	mysql -uroot -proot < "/schema.sql"
       	mysql -uroot -proot < "/data.sql"
       fi 
 	  echo ">>>> Granting permission"
	   mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;FLUSH PRIVILEGES;"
	   mysqladmin -uroot -proot shutdown
	echo "Stage :ImportSql() end..."
}


if [[ ! -d $VOLUME_HOME/mysql ]]; then
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
        cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
    fi 
    mysql_install_db > /dev/null 2>&1
    echo "=> Creating admin user ..."
   CreateMySQLUser
 else
    echo "volume exist"
fi
ImportSql

# exec mysqld_safe --skip-grant-tables
exec mysqld_safe
