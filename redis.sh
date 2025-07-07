
#!/bin/bash

#This will give current timestamp in seconds, by default it calculates since 1970
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

# check the user has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Redis"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

#-i edits the file in place and permanently
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Editing Redis conf file for remote connections"

#or we can give both sed in  one line as : sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
#^: Anchors the match to the start of the line; protected-mode: The exact key to match; [[:space:]]\+: Matches one or more spaces or tabs; yes: The value you're changing; protected-mode no: The replacement string
sed -i 's/^protected-mode[[:space:]]\+yes/protected-mode no/' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "Editing Redis conf file protected mode"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis service"

systemctl start redis
VALIDATE $? "starting Redis service"


END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
