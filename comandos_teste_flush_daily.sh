##### KAFKA BROKER #####
docker exec -it broker bash
cd /bin
./kafka-topics --create --topic quickstart-events --bootstrap-server localhost:9092
./kafka-topics --delete --topic quickstart-events --bootstrap-server localhost:9092
exit

##### SCHEMA REGISTRY #####
curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{"schema": "{  \"namespace\": \"io.confluent.examples.clients.basicavro\",  \"type\": \"record\",  \"name\": \"Payment\",  \"fields\": [    {\"name\": \"id\", \"type\": \"string\"},    {\"name\": \"nome\", \"type\": \"string\"}  ]}"}' \
http://localhost:8081/subjects/quickstart-events-io.confluent.examples.clients.basicavro.Payment/versions


##### KAFKA CONNECT #####
curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d "{
\"name\": \"daily-flush-connector\",
\"config\": {
        \"connector.class\": \"io.confluent.connect.s3.S3SinkConnector\",
        \"s3.region\": \"sa-east-1\",
        \"topics.dir\": \"conector-padrao/bruno\",
        \"avro.codec\": \"snappy\",
        \"flush.size\": \"4\",
        \"timezone\": \"America/Sao_Paulo\",
        \"tasks.max\": \"1\",
        \"transforms\": \"AddMetadata\",
        \"value.converter.value.subject.name.strategy\": \"io.confluent.kafka.serializers.subject.TopicRecordNameStrategy\",
        \"locale\": \"pt\",
        \"transforms.AddMetadata.offset.field\": \"_offset\",
        \"format.class\": \"io.confluent.connect.s3.format.avro.AvroFormat\",
        \"s3.acl.canned\": \"bucket-owner-full-control\",
        \"value.converter\": \"io.confluent.connect.avro.AvroConverter\",
        \"transforms.AddMetadata.type\": \"org.apache.kafka.connect.transforms.InsertField\$Value\",
        \"key.converter\": \"org.apache.kafka.connect.storage.StringConverter\",
        \"s3.bucket.name\": \"meu-bucket-123\",
        \"partition.duration.ms\": \"86400000\",
        \"s3.ssea.name\": \"AES256\",
        \"topics\":\"quickstart-events\",
        \"value.converter.schema.registry.url\": \"http://schema-registry:8081\",
        \"partitioner.class\": \"io.confluent.connect.storage.partitioner.TimeBasedPartitioner\",
        \"name\": \"daily-flush-connector\",
        \"storage.class\": \"io.confluent.connect.s3.storage.S3Storage\",
        \"rotate.schedule.interval.ms\": \"86400000\",
        \"timestamp.extractor\": \"Record\",
        \"transforms.AddMetadata.partition.field\": \"_partition\",
        \"path.format\": \"'anomesdia'=yyyyMMdd\"
}}"

curl -s http://localhost:8083/connectors/daily-flush-connector/status

curl -X DELETE http://localhost:8083/connectors/daily-flush-connector