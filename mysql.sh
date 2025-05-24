#!/bin/bash

source ./common.sh
app_name=mysql
check_root

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD # RoboShop@1 password

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld  &>>$LOG_FILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld   &>>$LOG_FILE
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass $MYSQL_ROOT_PASSWORD &>>$LOG_FILE
VALIDATE $? "Setting MySQL root password"

print_time


#systemctl
   # if [ $? -eq 0 ]
    #then
       # echo "MySQL is Successfully running"
   # else
      #  echo "MySQL Failed to start"
       # tail -f /var/log/mysqld.log # Check the MySQL log for errors
       # echo "Please check the log file for more details"
       # exit 1
   # fi