#!/usr/bin/env bash
echo "该脚本针对redis-5.0.5.tar.gz源码包构建集群"

#setting
sourceZipVersion="redis-5.0.5.tar.gz"
sourceDir="redis-5.0.5"
#redisConfig="port 700$i
#bind  192.168.220.129
#requirepass  HN6Di0bdsIoTTb1A     #jedis客户端访问集群节点时需要这个密码
#masterauth   HN6Di0bdsIoTTb1A     #备份库访问主库时需要这个密码
#cluster-enabled yes
#cluster-config-file node-700$i.conf
#cluster-node-timeout 5000
#appendonly yes"

#启动
if [ "$1" == "start" ]; then
  if test -e ./${sourceZipVersion}; then
    tar -zxf ${sourceZipVersion}
  else
    echo ${sourceZipVersion}文件不存在
  fi

  if test -e ${sourceDir}; then
    cd ${sourceDir}
    make
    cp src/redis-server ../
    cp src/redis-cli ../
    cd ..
    rm -rf ${sourceDir}
    for i in {0..5}; do
      mkdir redis-800$i
      cd redis-800$i
      echo "port 800$i
                                bind  127.0.0.1
                                requirepass  HN6Di0bdsIoTTb1A
                                masterauth   HN6Di0bdsIoTTb1A
                                cluster-enabled yes
                                cluster-config-file node-800$i.conf
                                cluster-node-timeout 5000
                                appendonly yes" >redis.conf
      echo "启动 800$i 端口  "
      nohup ../redis-server ./redis.conf >redis-8000$i.log 2>&1 &
      cd ..
    done
    echo "redis集群构建完毕"
    #节点添加到集群
    ./redis-cli --cluster create 127.0.0.1:8000 127.0.0.1:8001 127.0.0.1:8002 127.0.0.1:8003 127.0.0.1:8004 127.0.0.1:8005 --cluster-replicas 1
  fi
  exit 0
fi

#停止
if [ "$1" == "stop" ]; then
  ps -ef | grep -v grep | grep redis | awk '{print $2}' | xargs kill -9
  rm -rf redis-800*
  rm -rf redis-cli
  rm -rf redis-server
  echo "redis集群关闭"
  exit 0
fi

#测试
if [ "$1" == "test" ]; then
  ./redis-cli -c -p 8000 -h 127.0.0.1 -a HN6Di0bdsIoTTb1A
  echo "命令连接redis集群
    ./redis-cli --help 查看启动命令
    -c  集群模式
    -p 端口
    -h 主机ip
    -a 节点密码"
  exit 0
fi
