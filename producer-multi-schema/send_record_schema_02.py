import json
import random
import string
import uuid
from random import randrange

from confluent_kafka.avro import AvroProducer
from confluent_kafka import avro


def random_json():
    i = randrange(1000)
    nome = ''.join(random.sample(string.ascii_lowercase, 10))
    nome_2 = ''.join(random.sample(string.ascii_lowercase, 10))
    final_str = '{"id": "' + str(i) + '", "nome": "' + nome + '", "nome_2": "' + nome_2 + '"}'
    # final_str = '{"id": "' + str(i) + '", "nome": "' + nome + '"}'
    return final_str


def load_avro_schema_from_file(schema_file):
    key_schema_string = '{"type": "string"}'

    key_schema = avro.loads(key_schema_string)
    value_schema = avro.load(schema_file)

    return key_schema, value_schema


def send_record():
    key_schema, value_schema = load_avro_schema_from_file("create-payment-request-02.avsc")

    producer_config = {
        "bootstrap.servers": "localhost:9092",
        "schema.registry.url": "http://localhost:8081"
    }

    producer = AvroProducer(producer_config, default_key_schema=key_schema, default_value_schema=value_schema)

    key = str(uuid.uuid4())
    value = json.loads(random_json())

    producer.produce(topic="quickstart-events", key=key, value=value)
    producer.flush()

    print('acho que foi :)')


if __name__ == "__main__":
    send_record()
