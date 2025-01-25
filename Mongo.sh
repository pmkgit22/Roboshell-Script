#!/bin/bash
USERID=$(id -u )
DATE=$(date +%F)
LOGDIR=/tmp
SCRIPT_NAME=$0
LOGFILE=$LOGDIR/$0-$DATE.log
R="\e[31m"
N="\e[0m"
B="\e[34m"
echo "The user Id is : $USERID"

if [ $USERID -ne 0 ];
 then
  echo -e "$R ERROR: this is not super user Run with super user$N"
  exit 1
 #else
#echo -e " $B MESS: this is root user good"
fi
#echo -e "$N Message :stillthis  continuing with out exit ID: $USERID"
Validate(){
 if [ $1 -ne 0 ];
  then
  echo -e "$R $2 installation failed$N"
  exit 1
  else
  echo -e "$B $2 succesfully installed$N"
fi
}
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
Validate $? " copied mongo.repo in to your repos folder"

yum install mongodb-org -y &>>$LOGFILE
Validate $? " installing mongo db"
systemctl enable mongod &>>$LOGFILE
Validate $? " enabling mongoDB"
systemctl start mongod &>>$LOGFILE
Validate $? " starting mongo DB"

#vim /etc/mongod.conf

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>$LOGFILE
Validate $? "Edited mongo conf File"

systemctl restart mongod &>>$LOGFILE
Validate $? "Restart mongo DB"