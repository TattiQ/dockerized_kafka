#!/bin/sh
apt-get install git -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
rm /etc/docker/daemon.json
echo '{"bip": "192.168.111.1/24", "insecure-registries": ["supdockerhub:5000"]}' >> /etc/docker/daemon.json
systemctl start docker
systemctl enable docker

docker stop kafka && docker rm kafka
echo "stopped and rm-ed previous kafka"

docker stop zookeeper && docker rm zookeeper
echo "stopped and rm-ed previous zookeeper"

docker run --net=host --name zookeeper -d jplock/zookeeper

cd /tmp && git clone https://github.com/TattiQ/dockerized_kafka.git
cd dockerized_kafka && docker build -t kafka_11 .
echo "Getting ip"
ip=`hostname -I | cut -d " " -f1`

docker run --net=host --env KAFKA_ADVERTISED_HOST_NAME=$ip --env ZOOKEEPER_IP=$ip --name kafka -d kafka_11

echo "Creating topics"
sleep 30

docker run --rm kafka_11 kafka-topics.sh --create --topic bundle_events --replication-factor 1 --partitions 20 --zookeeper $ip:2181 --config cleanup.policy=compact
docker run --rm kafka_11 kafka-topics.sh --create --topic logs_sf_comments --replication-factor 1 --partitions 1 --zookeeper $ip:2181
docker run --rm kafka_11 kafka-topics.sh --create --topic sf_case_event --replication-factor 1 --partitions 10 --zookeeper $ip:2181
docker run --rm kafka_11 kafka-topics.sh --create --topic report_pirates --replication-factor 1 --partitions 1 --zookeeper $ip:2181

docker run --rm kafka_11 kafka-topics.sh --create --topic bundle_queued --replication-factor 1 --partitions 20 --zookeeper $ip:2181

docker run --rm kafka_11 kafka-topics.sh --create --topic sf_dashboard_query_results --replication-factor 1 --partitions 1 --zookeeper $ip:2181 --config cleanup.policy=compact

docker run --rm kafka_11 kafka-topics.sh --create --topic logs_bug_matching --replication-factor 1 --partitions 1 --zookeeper $ip:2181
docker run --rm kafka_11 kafka-topics.sh --create --topic logs_downloader --replication-factor 1 --partitions 1 --zookeeper $ip:2181

docker run --rm kafka_11 kafka-topics.sh --create --topic sf_account_query_requests --replication-factor 1 --partitions 10 --zookeeper $ip:2181

docker run --rm kafka_11 kafka-topics.sh --create --topic sf_account_query_results --replication-factor 1 --partitions 1 --zookeeper $ip:2181 --config cleanup.policy=compact

docker run --rm kafka_11 kafka-topics.sh --create --topic report_bug_found --replication-factor 1 --partitions 20 --zookeeper $ip:2181

#echo $ip | mail -s "Kafka and zookeeper containers deployed" tatyana.mva@gmail.com
