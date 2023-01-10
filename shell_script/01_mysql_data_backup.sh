#!/bin/bas

## 需求：MySQL数据库备份 

## 
DATE=$(date +%F_%H_%M_%S)

HOST=127.0.0.1
DB=DB_NAME
USER=username
PASS=password
MAIL='pfxu163@163.com'
BACKUP_DIR=/opt/data
SQL_FILE=${DB}_full_$DATE.sql
BAK_FILE=${DB}_full_$DATE.zip

cd $BACKUP_DIR
if mysqldump -h$HOST -u$USER -p$PASS --single-transaction --routines --triggers -B $DB > $SQL_FILE; then
    zip $BAK_FILE $SQL_FILE && rm -f $SQL_FILE
    if [ ! -s $BAK_FILE ]; then
            echo "$DATE 内容" | mail -s "主题" $MAIL
    fi
else
    echo "$DATE 内容" | mail -s "主题" $MAIL
fi
find $BACKUP_DIR -name '*.zip' -ctime +14 -exec rm {} \;
