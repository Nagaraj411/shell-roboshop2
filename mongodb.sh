#!/bin/bash

source ./common.sh #source ./ common.sh means got to commaon.sh file to include the file in the current script
app_name=mongodb

check_root 

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "MongoDB repo file copy"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "MongoDB installation"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "MongoDB service enable"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "MongoDB service start"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "MongoDB config file update"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "MongoDB service restart"

print_time  