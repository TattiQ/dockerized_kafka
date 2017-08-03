#!/bin/sh
yum install docker mailx git -y
systemctl start docker
systemctl enable docker

docker stop kafka && docker rm kafka
echo "stopped and rm-ed previous kafka"

docker stop zookeeper && docker rm zookeeper
echo "stopped and rm-ed previous zookeeper"

docker run -d -p 2181:2181 --net=host --name zookeeper jplock/zookeeper

cd /tmp && git clone https://github.com/TattiQ/dockerized_kafka.git
cd dockerized_kafka && docker build -t kafka_11 .

ip=`ip a | grep eno | grep inet | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1`

docker run -d -p 9092:9092 --net=host --env KAFKA_ADVERTISED_HOST_NAME=$ip --env ZOOKEEPER_IP=$ip --name kafka kafka_11

docker run --rm kafka_11 kafka-topics.sh --create --topic bundle_event --replication-factor 1 --partitions 10 --zookeeper $ip:2181 --config cleanup.policy=compact
docker run --rm kafka_11 kafka-topics.sh --create --topic sf_case_event --replication-factor 1 --partitions 10 --zookeeper $ip:2181 --config cleanup.policy=compact

docker run --rm kafka_11 kafka-topics.sh --create --topic pirate_report --replication-factor 1 --partitions 10 --zookeeper $ip:2181 --config cleanup.policy=compact

docker run --rm kafka_11 kafka-topics.sh --create --topic bundle_queued --replication-factor 1 --partitions 10 --zookeeper $ip:2181 --config cleanup.policy=compact

echo $ip | mail -s "Kafka and zookeeper containers deployed" tatyana.koroleva@fakedomain.com
