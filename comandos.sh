# https://jcustenborder.github.io/kafka-connect-documentation/projects/kafka-connect-transform-common/transformations/HeaderToField.html
# https://www.confluent.io/blog/kafka-connect-deep-dive-error-handling-dead-letter-queues/

##### KAFKA BROKER #####
# entrar no container
docker exec -it broker bash
cd /bin
./kafka-topics --create --topic quickstart-events --bootstrap-server localhost:9092
./kafka-topics --create --topic quickstart-events-dlq --bootstrap-server localhost:9092

./kafka-topics --delete --topic quickstart-events --bootstrap-server localhost:9092
./kafka-topics --delete --topic quickstart-events-dlq --bootstrap-server localhost:9092

./kafka-console-consumer --topic quickstart-events --bootstrap-server localhost:9092

##### KAFKA CONNECT #####
# entrar no container
docker exec -it kafka-connect bash


curl -s http://localhost:8083/connectors/file_sink_01/status

curl -X DELETE http://localhost:8083/connectors/file_sink_01

curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
        "name": "file_sink_01",
        "config": {
                "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
                "topics":"quickstart-events",
                "key.converter": "io.confluent.connect.avro.AvroConverter",
                "key.converter.schema.registry.url": "http://schema-registry:8081",
                "key.converter.enhanced.avro.schema.support": "true",
                "value.converter": "io.confluent.connect.avro.AvroConverter",
                "value.converter.schema.registry.url": "http://schema-registry:8081",
                "value.converter.enhanced.avro.schema.support": "true",
                "file": "/home/appuser/data/file_sink_01.txt",
                "errors.tolerance": "none"
                }
        }'


### FUNCIONOU ###
curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
        "name": "file_sink_01",
        "config": {
                "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
                "topics":"quickstart-events",
                "key.converter": "io.confluent.connect.avro.AvroConverter",
                "key.converter.schema.registry.url": "http://schema-registry:8081",
                "key.converter.enhanced.avro.schema.support": "true",
                "value.converter": "io.confluent.connect.avro.AvroConverter",
                "value.converter.schema.registry.url": "http://schema-registry:8081",
                "value.converter.enhanced.avro.schema.support": "true",
                "file": "/home/appuser/data/file_sink_01.txt",
                "transforms" : "headerToField",
                "transforms.headerToField.type" : "com.github.jcustenborder.kafka.connect.transform.common.HeaderToField$Value",
                "transforms.headerToField.header.mappings" : "applicationId:STRING",
                "errors.tolerance": "none"
                }
        }'

curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
        "name": "file_sink_01",
        "config": {
                "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
                "topics":"quickstart-events",
                "key.converter": "io.confluent.connect.avro.AvroConverter",
                "key.converter.schema.registry.url": "http://localhost:8081",
                "key.converter.enhanced.avro.schema.support": "true",
                "value.converter": "io.confluent.connect.avro.AvroConverter",
                "value.converter.schema.registry.url": "http://localhost:8081",
                "value.converter.enhanced.avro.schema.support": "true",
                "file": "/home/appuser/data/file_sink_01.txt",
                "transforms" : "headerToField",
                "transforms.headerToField.type" : "com.github.jcustenborder.kafka.connect.transform.common.HeaderToField$Value",
                "transforms.headerToField.header.mappings" : "applicationId:STRING",
                "errors.tolerance": "none"
                }
        }'

curl -X POST http://localhost:8083/connectors -H "Content-Type: application/json" -d '{
        "name": "file_sink_01",
        "config": {
                "connector.class": "org.apache.kafka.connect.file.FileStreamSinkConnector",
                "topics":"quickstart-events",
                "value.converter":"org.apache.kafka.connect.json.JsonConverter",
                "value.converter.schemas.enable": false,
                "key.converter":"org.apache.kafka.connect.json.JsonConverter",
                "key.converter.schemas.enable": false,
                "file": "/home/appuser/data/file_sink_01.txt",
                "errors.tolerance": "all"
                }
        }'
		

##### KAFKACAT #####
docker exec -it kafkacat bash

echo '{"nome": "xyz"}'| kafkacat -b broker:29092 -t quickstart-events -P -H "applicationId=Bruno"
echo '{"col_foo":1}'|kafkacat -b broker:29092 -t quickstart-events -P -H applicationId=bar


kafkacat -b broker:29092 -t quickstart-events-dlq -C -o-1 -c1 \
  -f '\nKey (%K bytes): %k
  Value (%S bytes): %s
  Timestamp: %T
  Partition: %p
  Offset: %o
  Headers: %h\n'
  


##### SCHEMA REGISTRY #####
docker exec -it schema-registry bash

echo '{"namespace": "io.confluent.examples.clients.basicavro",
 "type": "record",
 "name": "Payment",
 "fields": [
     {"name": "id", "type": "string"},
     {"name": "nome", "type": "string"}
 ]}' > ~/Payment.avsc

cd /bin
kafka-avro-console-producer --topic quickstart-events --bootstrap-server broker:29092 --property value.schema="$(< ~/Payment.avsc)"
{"id": "1", "nome": "bruno"}
{"id": "1", "nome": "bruno2"}

curl -X GET http://localhost:8081/subjects