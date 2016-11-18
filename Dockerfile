# VERSION 0.0.1
# 使用默认centos镜像
FROM hub.c.163.com/public/centos:7.2.1511
# 签名
MAINTAINER qhzhang "zh121100@163.com"

# 设置JAVA_HOME环境变量
ENV JAVA_HOME=/usr/local/jdk\
    PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH\
    CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$CLASSPATH

# 添加文件
# ADD ./dependency/* /usr/local/
# 安装jdk、tomcat、设置root ssh远程登录密码为123456
RUN cd /usr/local && \
    wget http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.16-linux-glibc2.5-x86_64.tar.gz && \
    wget http://apache.mirror.rafal.ca/tomcat/tomcat-8/v8.5.6/bin/apache-tomcat-8.5.6.tar.gz && \
    wget https://0geauomtzgwzdnpbofaaukptpcoanhaubpf18khddqczgg55p.ourdvsss.com/d0.baidupcs.com/file/9222e097e624800fdd9bfb568169ccad?bkt=p2-nj-941&xcode=f1bffc97b641830ddef4fc4b460e6f32ba8fb3387b4d9891316128a2cdfcce4d&fid=1678158691-250528-117337971851932&time=1479459267&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-GhBOksVo1x%2FMxej1pxUeA%2BFLLQk%3D&to=sd&fm=Nan,B,T,t&sta_dx=153512879&sta_cs=12224&sta_ft=gz&sta_ct=7&sta_mt=7&fm2=Nanjing,B,T,t&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=14009222e097e624800fdd9bfb568169ccadaae5c7c4000009266baf&sl=71368782&expires=8h&rt=sh&r=720356379&mlogid=7484427967886341503&vuk=-&vbdid=639121183&fin=jdk-7u79-linux-x64.tar.gz&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7484427967886341503&dp-callid=0.1.1&hps=1&csl=158&csign=g1sHHzT%2BFuaskSrDKR1sdy4dklM%3D&wshc_tag=0&wsts_tag=582ec1c4&wsid_tag=af0c8068&wsiphost=ipdbm && \
    wget http://download.redis.io/redis-stable.tar.gz && \
    wget http://mirror.csclub.uwaterloo.ca/apache/zookeeper/zookeeper-3.4.8/zookeeper-3.4.8.tar.gz && \
    tar xvf *.gz && \
    cd && \
    mv /usr/local/jdk1.7.0_79/ /usr/local/jdk && \
    mv /usr/local/apache-tomcat-8.5.6/ /usr/local/tomcat && \
    yum -y install gcc automake autoconf libtool make && \
    echo "root:123456" | chpasswd && \
# 安装redis
    rm /usr/local/redis-stable/redis.conf && \
    mv /usr/local/redis.conf  /usr/local/redis-stable && \
    mv /usr/local/redis /etc/init.d/ && \
    chmod 755 /etc/init.d/redis && \
    chkconfig --add redis && \
    cd /usr/local/redis-stable && \
    make && \
    make install && \
    cp -f src/redis-sentinel /usr/local/bin && \
    mkdir -p /etc/redis && \
    cp -f *.conf /etc/redis && \
    rm -rf /usr/local/redis-stable* && \
#    sed -i 's/^\(bind .*\)$/# \1/' /etc/redis/redis.conf && \
#    sed -i 's/^\(daemonize .*\)$/# \1/' /etc/redis/redis.conf && \
#    sed -i 's/^\(dir .*\)$/# \1\ndir \/data/' /etc/redis/redis.conf && \
#    sed -i 's/^\(logfile .*\)$/# \1/' /etc/redis/redis.conf && \
    mkdir -p /app/Redis/logs && \
    mkdir -p /app/Redis/pid && \
    mkdir -p /app/Redis/working && \
# 安装zookeeper
    mv /usr/local/zookeeper /etc/init.d/ && \
    chmod 755 /etc/init.d/zookeeper && \
    chkconfig --add zookeeper && \
    mv /usr/local/zoo.cfg /usr/local/zookeeper-3.4.8/conf && \
    rm /usr/local/zookeeper-3.4.8/conf/log4j.properties && \
    mv /usr/local/log4j.properties /usr/local/zookeeper-3.4.8/conf && \
    mv /usr/local/zookeeper-3.4.8 /usr/local/zookeeper && \
    mkdir -p /app/zookeeper/data && \
    mkdir -p /app/zookeeper/log && \
# 安装mysql
    yum -y install libaio && \
    mv /usr/local/mysql-5.7.16-linux-glibc2.5-x86_64 /usr/local/mysql && \
    mkdir /usr/local/mysql/data && \
    mkdir /usr/local/mysql/tmp && \
    mkdir /usr/local/mysql/log && \
    chmod 770 /usr/local/mysql/data && \
    chmod 770 /usr/local/mysql/tmp && \
    chmod 770 /usr/local/mysql/log && \
    groupadd mysql && \
    useradd -r -g mysql -s /bin/false mysql && \
    cd /usr/local/mysql && \
    chown -R mysql:mysql ./&& \
    ./bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data && \
    chown -R root ./* && \
    chown -R mysql ./data && \
    chown -R mysql ./tmp && \
    chown -R mysql ./log && \
#    cp support-files/my-default.cnf /etc/my.cnf && \
    touch /etc/my.cnf && \
    echo "[mysqld]" >> /etc/my.cnf && \
    echo "basedir = /usr/local/mysql" >> /etc/my.cnf && \
    echo "datadir = /usr/local/mysql/data" >> /etc/my.cnf && \
    echo "log-bin = /usr/local/mysql/log/mysql_log_bin.log" >> /etc/my.cnf && \
    echo "server-id = 1" >> /etc/my.cnf && \
    echo "long_query_time = 10" >> /etc/my.cnf && \
    echo "slow_query_log" >> /etc/my.cnf && \
    echo "slow_query_log_file = /usr/local/mysql/log/mysql_log_slow_queries.log" >> /etc/my.cnf && \
    echo "log-error = /usr/local/mysql/log/mysql_log_error.log" >> /etc/my.cnf && \
    echo "port = 3306" >> /etc/my.cnf && \
    echo "socket = /usr/local/mysql/tmp/mysql.sock" >> /etc/my.cnf && \ 
    echo "sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES" >> /etc/my.cnf && \
    echo "[client]" >> /etc/my.cnf && \
    echo "socket = /usr/local/mysql/tmp/mysql.sock" >> /etc/my.cnf && \
    echo "port = 3306" >> /etc/my.cnf && \
    cp support-files/mysql.server /etc/init.d/mysql && \
    chmod 755 /etc/init.d/mysql && \
    chkconfig --add mysql && \
    ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql && \
    /etc/init.d/mysql start && \ 
    /usr/local/mysql/bin/mysqladmin -u root password '123456'


# 容器需要开放Tomcat 8080端口
EXPOSE 8080 6379 2181 3306

# 设置环境变量，开启SSH终端服务器作为后台运行
ENTRYPOINT  echo "export JAVA_HOME=/usr/local/jdk" >> /etc/profile && \
            echo "export ZOOKEEPER_HOME=/usr/local/zookeeper" >> /etc/profile && \
            echo "export MYSQL_HOME=/usr/local/mysql" >> /etc/profile && \
            echo "export PATH=$MYSQL_HOME/bin:$ZOOKEEPER_HOME/bin:$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH" >> /etc/profile && \
            echo "export CLASSPATH=$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:CLASSPATH" >> /etc/profile && \
            source /etc/profile && \
            /usr/sbin/sshd -D

#应用启动指令
#/etc/init.d/redis start
#/etc/init.d/zookeeper start
#/etc/init.d/mysql start
 

# 在启动docker容器后，拷贝下面全部命令，粘贴到容器里的终端窗口回车执行(#号需要去掉)
#mysql -u root -p123456
#use mysql;
#update user set host ='%' where user ='root';
#flush privileges;
#exit;
