#!/bin/bash

source ./common.sh
check_root

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Nginx module disable"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Nginx module enable"

dnf install nginx -y    &>>$LOG_FILE
VALIDATE $? "Nginx installation"

systemctl enable nginx  &>>$LOG_FILE
VALIDATE $? "Nginx service enable"

systemctl start nginx  &>>$LOG_FILE
VALIDATE $? "Nginx service start"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Nginx default content removal"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip   &>>$LOG_FILE
VALIDATE $? "Downloading Frontend"

cd /usr/share/nginx/html 
VALIDATE $? "Nginx default content folder"

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping Frontend"

rm -rf /etc/nginx/nginx.conf/*   &>>$LOG_FILE
VALIDATE $? "Removing default nginx.conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Nginx service restart"

print_time