#!/bin/bash

source ./common.sh
app_name=catalogue

check_root
nodejs_setup
app_setup

npm install &>>$LOG_FILE
VALIDATE $? "npm install"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "systemd daemon reload"

systemctl enable catalogue  &>>$LOG_FILE
VALIDATE $? "catalogue service enable"

systemctl start catalogue   &>>$LOG_FILE
VALIDATE $? "catalogue service start"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo 
dnf install mongodb-mongosh -y  &>>$LOG_FILE    
VALIDATE $? "mongodb installation"

STATUS=$(mongosh --host mongodb.devops84.shop --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.devops84.shop </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into MongoDB"
else
    echo -e "Data is already loaded ... $Y SKIPPING $N"
fi

mongosh --host mongodb.devops84.shop
VALIDATE $? "MongoDB connection"

print_time