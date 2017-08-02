
## Deploy instructions.

Prerequisites: docker, pykafka, net-tools (for netstat). 
Resulting Kafka will be version 0.11.0.0 , scala 2.11 (considered stable at the time of deploy)

Start the zookeeper container, give it a name, bind the container port 2181 to the host OS port so that we can access that port from the our host OS if needed:
```
docker run -d -p 2181:2181 --net=host --name zookeeper jplock/zookeeper
```
Git clone the docker-kafka project locally onto the server. 
Build  the Kafka Docker image:
```
docker build -t kafka_11 .
```
Start the Kafka container from the freshly built image: 
```
docker run -d --name kafka --net=host -e KAFKA_ADVERTISED_HOST_NAME=IP -e KAFKA_DELETE_TOPIC_ENABLE=true -e ZOOKEEPER_IP=IP kafka_11  
```

Check the Zookeeper and Kafka lister on their ports on the docker host :
```
netstat -tulpen | grep 2181
netstat -tulpen | grep 9092
```

Check running containers:
```
docker ps
```
Log intot he kafka container 
```
docker exec -ti containerid /bin/bash
```
and echo log.cleaner.enable=true into config/server.properties
```
echo "log.cleaner.enable=true" >> config/server.properties
```

Create a topic in Kafka: 
```
docker run --rm kafka_11 kafka-topics.sh --create --topic test --replication-factor 1 --partitions 1 --zookeeper IP:2181 --config cleanup.policy=compact
```
where IP is your docker host ip.  


Test your kafka installation from ipython (pykafka required): 
```
from pykafka import KafkaClient 
client = KafkaClient(hosts="IP:9092")
client.topics 
```

The test topic should be visible.  
