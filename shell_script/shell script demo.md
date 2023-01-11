### 01. 定时清空文件内容，定时记录文件大小
```shell
#!/bin/bash
################################################################
#每小时执行一次脚本（任务计划），当时间为0点或12点时，将目标目录下的所有文件内
#容清空，但不删除文件，其他时间则只统计各个文件的大小，一个文件一行，输出到以时#间和日期命名的文件中，需要考虑目标目录下二级、三级等子目录的文件
################################################################
logfile=/tmp/`date +%H-%F`.log
n=`date +%H`
if [ $n -eq 00 ] || [ $n -eq 12 ]
then
#通过for循环，以find命令作为遍历条件，将目标目录下的所有文件进行遍历并做相应操作
for i in `find /data/log/ -type f`
do
true > $i
done
else
for i in `find /data/log/ -type f`
do
du -sh $i >> $logfile
done
fi
```
### 02. 检测网卡流量，并按规定格式记录在日志中
```shell
#!/bin/bash
#######################################################
#检测网卡流量，并按规定格式记录在日志中
#规定一分钟记录一次
#日志格式如下所示:
#2019-08-12 20:40
#ens33 input: 1234bps
#ens33 output: 1235bps
######################################################3
while :
do
#设置语言为英文，保障输出结果是英文，否则会出现bug
LANG=en
logfile=/tmp/`date +%d`.log
#将下面执行的命令结果输出重定向到logfile日志中
exec >> $logfile
date +"%F %H:%M"
#sar命令统计的流量单位为kb/s，日志格式为bps，因此要*1000*8
sar -n DEV 1 59|grep Average|grep ens33|awk '{print $2,"\t","input:","\t",$5*1000*8,"bps","\n",$2,"\t","output:","\t",$6*1000*8,"bps"}'
echo "####################"
#因为执行sar命令需要59秒，因此不需要sleep
done

```
### 03. 计算文档每行出现的数字个数，并计算整个文档的数字总数
```shell
#!/bin/bash
#########################################################
#计算文档每行出现的数字个数，并计算整个文档的数字总数
########################################################
#使用awk只输出文档行数（截取第一段）
n=`wc -l a.txt|awk '{print $1}'`
sum=0
#文档中每一行可能存在空格，因此不能直接用文档内容进行遍历
for i in `seq 1 $n`
do
#输出的行用变量表示时，需要用双引号
line=`sed -n "$i"p a.txt`
#wc -L选项，统计最长行的长度
n_n=`echo $line|sed s'/[^0-9]//'g|wc -L`
echo $n_n
sum=$[$sum+$n_n]
done
echo "sum:$sum"

```
### 04. 连续输入5个100以内的数字，统计和、最小和最大
```shell
#!/bin/bash
COUNT=1
SUM=0
MIN=0
MAX=100
while [ $COUNT -le 5 ]; do
    read -p "请输入1-10个整数：" INT
    if [[ ! $INT =~ ^[0-9]+$ ]]; then
        echo "输入必须是整数！"
        exit 1
    elif [[ $INT -gt 100 ]]; then
        echo "输入必须是100以内！"
        exit 1
    fi
    SUM=$(($SUM+$INT))
    [ $MIN -lt $INT ] && MIN=$INT
    [ $MAX -gt $INT ] && MAX=$INT
    let COUNT++
done
echo "SUM: $SUM"
echo "MIN: $MIN"
echo "MAX: $MAX"
```
### 05. 用户猜数字
```shell
#!/bin/bash  
# 脚本生成一个 100 以内的随机数,提示用户猜数字,根据用户的输入,提示用户猜对了
# 猜小了或猜大了,直至用户猜对脚本结束。# RANDOM 为系统自带的系统变量,值为 0‐32767的随机数
# 使用取余算法将随机数变为 1‐100 的随机数num=$[RANDOM%100+1]echo "$num"
 # 使用 read 提示用户猜数字
 # 使用 if 判断用户猜数字的大小关系:‐eq(等于),‐ne(不等于),‐gt(大于),‐ge(大于等于),
 # ‐lt(小于),‐le(小于等于)
while :do     
read -p "计算机生成了一个 1‐100 的随机数,你猜: " cai    
if [ $cai -eq $num ]    
then        
echo "恭喜,猜对了"           
exit        
elif [ $cai -gt $num ]        
then            
echo "Oops,猜大了"         
else            
echo "Oops,猜小了"     
fi
done

```
### 06. 批量修改文件名
```shell
# touch article_{1..3}.html
# ls
article_1.html  article_2.html  article_3.html
目的：把article改为bbs

方法1：

for file in $(ls *html); do
    mv $file bbs_${file#*_}
    # mv $file $(echo $file |sed -r 's/.*(_.*)/bbs\1/')
    # mv $file $(echo $file |echo bbs_$(cut -d_ -f2)
done
方法2：

for file in $(find . -maxdepth 1 -name "*html"); do
     mv $file bbs_${file#*_}
done
方法3：

# rename article bbs *.html
```
### 07. 统计当前目录中以.html结尾的文件总大
```shell
方法1：

# find . -name "*.html" -exec du -k {} \; |awk '{sum+=$1}END{print sum}'

方法2：

for size in $(ls -l *.html |awk '{print $5}'); do
    sum=$(($sum+$size))
done
echo $sum


```
### 08. 扫描主机端口状态
```shell
#!/bin/bash
HOST=$1
PORT="22 25 80 8080"
for PORT in $PORT; do
    if echo &>/dev/null > /dev/tcp/$HOST/$PORT; then
        echo "$PORT open"
    else
        echo "$PORT close"
    fi
done

```
### 09. 输入数字运行相应命令
```shell
#!/bin/bash
##############################################################
#输入数字运行相应命令
##############################################################
echo "*cmd menu* 1-date 2-ls 3-who 4-pwd 0-exit "
while :
do
#捕获用户键入值
 read -p "please input number :" n
 n1=`echo $n|sed s'/[0-9]//'g`
#空输入检测 
 if [ -z "$n" ]
 then
 continue
 fi
#非数字输入检测 
 if [ -n "$n1" ]
 then
 exit 0
 fi
 break
done
case $n in
 1)
 date
 ;;
 2)
 ls
 ;;
 3)
 who
 ;;
 4)
 pwd
 ;;
 0)
 break
 ;;
    #输入数字非1-4的提示
 *)
 echo "please input number is [1-4]"
esac

```
### 10. 创建10个用户，并分别设置密码，密码要求10位且包含大小写字母以及数字，最后需要把每个用户的密码存在指定文件中
```shell
#!/bin/bash
##############################################################
#创建10个用户，并分别设置密码，密码要求10位且包含大小写字母以及数字
#最后需要把每个用户的密码存在指定文件中
#前提条件：安装mkpasswd命令
##############################################################
#生成10个用户的序列（00-09）
for u in `seq -w 0 09`
do
 #创建用户
 useradd user_$u
 #生成密码
 p=`mkpasswd -s 0 -l 10`
 #从标准输入中读取密码进行修改（不安全）
 echo $p|passwd --stdin user_$u
 #常规修改密码
 echo -e "$p\n$p"|passwd user_$u
 #将创建的用户及对应的密码记录到日志文件中
 echo "user_$u $p" >> /tmp/userpassword
done
```
### 11. 有一普通用户想在每周日凌晨零点零分定期备份/user/backup到/tmp目录下，该用户应如何做？
```shell
（1）第一种方法：

用户应使用crontab –e 命令创建crontab文件。格式如下：
0 0 * * sun cp –r /user/backup /tmp

（2）第二种方法：
用户先在自己目录下新建文件file，文件内容如下：

0 * * sun cp –r /user/backup /tmp
然后执行 crontab file 使生效。
```
### 12. **批量主机磁盘利用率监控 (格式)**
```shell
前提监控端和被监控端SSH免交互登录或者密钥登录。

写一个配置文件保存被监控主机SSH连接信息，文件内容格式：IP User Port

class="">#!/bin/bashHOST_INFO=host.infoforIPin$(awk'/^[^#]/{print $1}'$HOST_INFO);doUSER=$(awk -v ip=$IP'ip==$1{print $2}'$HOST_INFO)    PORT=$(awk -v ip=$IP'ip==$1{print $3}'$HOST_INFO)    TMP_FILE=/tmp/disk.tmp    ssh -p$PORT$USER@$IP'df -h'>$TMP_FILEUSE_RATE_LIST=$(awk'BEGIN{OFS="="}/^\/dev/{print $1,int($5)}'$TMP_FILE)forUSE_RATEin$USE_RATE_LIST;doPART_NAME=${USE_RATE%=*}USE_RATE=${USE_RATE#*=}if[$USE_RATE-ge 80 ];thenecho"Warning: $PART_NAME Partition usage $USE_RATE%!"fidonedone


```
### 13. **检查MySQL主从同步状态**
```shell
class="">#!/bin/bash  USER=bakPASSWD=123456IO_SQL_STATUS=$(mysql -u$USER-p$PASSWD-e'show slave status\G'|awk -F:'/Slave_.*_Running/{gsub(": ",":");print $0}')#gsub去除冒号后面的空格foriin$IO_SQL_STATUS;doTHREAD_STATUS_NAME=${i%:*}THREAD_STATUS=${i#*:}if["$THREAD_STATUS"!="Yes"];thenecho"Error: MySQL Master-Slave $THREAD_STATUS_NAME status is $THREAD_STATUS!"fidone

```
### 14. **删除当前目录下大小为0的文件**
```shell
#/bin/bash
for filename in `ls`
do
    if test -d $filename
    then b=0
    else    
       a=$(ls -l $filename | awk '{ print $5 }')
            if test $a -eq 0
             then rm $filename
             fi
        fi      
done


```
### 15. for循环的使用
```shell
#/bin/bash
clear
for num in 1 2 3 4 5 6 7 8 9 10
do
    echo "$num"
done
```
### 16. **从0.sh中读取内容并打印**
```shell
#/bin/bash
while read line
do
    echo $line
done < 0.sh
```
### 17. **普通无参数函数**
```shell
#/bin/bash
p ()
{
    echo "hello"
}
p
```
### 18. **给函数传递参数**
```shell
#/bin/bash
p_num ()
{
    num=$1
    echo $num
}
for n in $@
do
    p_num $n
done
```
### 19. 创建文件夹(***)
```shell
#/bin/bash
while :
do
    echo "please input file's name:"
    read a
    if test -e /root/$a
    then
         echo "the file is existing Please input new file name:"
    else
        mkdir $a
        echo "you aye sussesful!"
        break
    fi
done
```
### 20. 查找最大文件
```shell
#/bin/bash
a=0
for  name in *.*
do
     b=$(ls -l $name | awk '{print $5}')
    if test $b -ge $a
    then a=$b
         namemax=$name
     fi
done
echo "the max file is $namemax"
```
### 21. 有一普通用户想在每周日凌晨零点零分定期备份/user/backup到/tmp目录下，该用户应如何做？
```shell
（1）第一种方法：

用户应使用crontab –e 命令创建crontab文件。格式如下：
0 0 * * sun cp –r /user/backup /tmp

（2）第二种方法：
用户先在自己目录下新建文件file，文件内容如下：

0 * * sun cp –r /user/backup /tmp
然后执行 crontab file 使生效。
```



> [1-10](https://www.jb51.net/article/213879.htm)
> [11-13](https://www.jianshu.com/p/9eadd8d80d03)
> [14-20](https://www.jb51.net/article/54488.htm)

