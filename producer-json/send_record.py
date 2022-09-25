import json
from confluent_kafka import Producer


def send_record():
    producer_config = {
        "bootstrap.servers": "localhost:9092",
        "enable.idempotence": True,
        "acks": "all"
    }

    producer = Producer(producer_config)

    message = json.dumps(
        {
            'field_01': 'value',
            'field_02': 'value 02'
        }
    )

    producer.produce(topic='quickstart-events', value=message, key='key')
    producer.flush()


if __name__ == "__main__":
    send_record()
