#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

# setting spark defaults
echo spark.yarn.jar hdfs:///spark/spark-assembly-1.6.1-hadoop2.6.0.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

#PJT: For convenience
#export PATH="$PATH:${HADOOP_PREFIX}/bin/:${HADOOP_PREFIX}/sbin/"

service ssh start

if [[ ${CLUSTER_ROLE} == "master" ]]; then
    # Format the namenode iff not already formatted.
    if [[ ! -d /data/dfs/name/current ]]; then
        echo 'Y' | ${HADOOP_PREFIX}/bin/hdfs namenode -format
    fi

    /usr/local/hadoop/sbin/start-dfs.sh
    /usr/local/hadoop/sbin/start-yarn.sh
fi

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi