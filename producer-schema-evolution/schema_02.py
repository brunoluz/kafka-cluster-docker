from uuid import uuid4

from confluent_kafka import Producer
from confluent_kafka.serialization import StringSerializer, SerializationContext, MessageField
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer


class Message(object):

    def __init__(self, _id, nome, sobrenome):
        self.id = _id
        self.nome = nome
        self.sobrenome = sobrenome


def message_to_dict(obj, ctx):
    return dict(id=obj.id, nome=obj.nome, sobrenome=obj.sobrenome)


topic = 'quickstart-events'
schema_registry_conf = {'url': 'http://localhost:8081'}
schema_registry_client = SchemaRegistryClient(schema_registry_conf)
with open('schema_02.avsc') as f:
    schema_str = f.read()

avro_serializer = AvroSerializer(schema_registry_client,
                                 schema_str,
                                 message_to_dict)

string_serializer = StringSerializer('utf_8')

producer_conf = {'bootstrap.servers': 'localhost:9092'}

producer = Producer(producer_conf)

value = Message('1', 'bruno', 'luz')
producer.produce(topic=topic,
                 key=string_serializer(str(uuid4())),
                 value=avro_serializer(value, SerializationContext(topic, MessageField.VALUE)))
producer.flush()
