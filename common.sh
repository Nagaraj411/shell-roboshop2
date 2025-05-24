#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]
    then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop    &>>$LOG_FILE
        VALIDATE $? "Creating roboshop system user"
    else
        echo -e "System user roboshop already created ... $Y SKIPPING $N"
    fi

    mkdir -p /app
    VALIDATE $? "app folder creation"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name"

    rm -rf /app/* #remove all the files in app folder
    cd /app       #go to app folder
    unzip /tmp/$app_name.zip    &>>$LOG_FILE
    VALIDATE $? "$app_name zip file extraction"
}

nodejs_setup(){
    dnf module disable nodejs -y    &>>$LOG_FILE
    VALIDATE $? "NodeJS module disable"

    dnf module enable nodejs:20 -y  &>>$LOG_FILE
    VALIDATE $? "NodeJS module enable"

    dnf install nodejs -y   &>>$LOG_FILE
    VALIDATE $? "NodeJS installation"

    npm install &>>$LOG_FILE
    VALIDATE $? "npm install"
}

maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Maven installation"

    mvn clean package  &>>$LOG_FILE
    VALIDATE $? "Packaging the shipping application"

    mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
    VALIDATE $? "Moving and renaming Jar file"
}
python_setup()
    dnf install python3 gcc python3-devel -y   &>>$LOG_FILE
    VALIDATE $? "Python3 installation"

    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing python dependencies"
    
    cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
    VALIDATE $? "Copying payment.service file"
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Copying $app_name service"

    systemctl daemon-reload &>>$LOG_FILE
    VALIDATE $? "systemd daemon reload"

    systemctl enable $app_name  &>>$LOG_FILE
    VALIDATE $? "$app_name service enable"

    systemctl start $app_name   &>>$LOG_FILE
    VALIDATE $? "$app_name service start"
}

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
        exit 1 #give other than 0 upto 127
    else
        echo "You are running with root access" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
    echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE  

}
