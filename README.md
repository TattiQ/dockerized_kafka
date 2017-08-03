## Deploy instructions.

Prerequisites: yum update -y and disabled firewalld

Resulting Kafka will be version 0.11.0.0 , scala 2.11 (considered stable at the time of deploy)

Make deploy_kafka.sh executable by running chmod +x on it, then run the deploy_kafka.sh script.

Check that the Zookeeper and Kafka listen on their ports on the docker host :
```
netstat -tulpen | grep 2181
netstat -tulpen | grep 9092
```

Check running containers:
```
docker ps
```

Since predefined topics are created with compact cleanup policy during test you need to provide key value pair in producer . Otherwise you will get the message "This message has failed its CRC checksum, exceeds the valid size, or is otherwise corrupt"

```
 docker run --rm --interactive kafka_11 kafka-console-producer.sh --topic bundle_queued --broker-list IP:9092 --property parse.key=true --property key.separator="-"
```

where IP is the docker host IP.
key.separator can be changed.  

The consumer run in a separate console will show the values - 

```
 docker run --rm kafka_11 kafka-console-consumer.sh --topic bundle_queued --from-beginning --zookeeper IP:2181
```
IP is the docker host IP.
