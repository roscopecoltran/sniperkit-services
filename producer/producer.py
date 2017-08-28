import os
import time
import datetime
import json
import random
from kafka import KafkaProducer
from time import gmtime, strftime

kafka_host = os.environ['KAFKA_HOST']
kafka_port = os.environ['KAFKA_PORT']

raw_data_topic = os.environ['RAW_DATA_TOPIC']


def main():
    time.sleep(10)
    print("Producer started")

    producer = KafkaProducer(bootstrap_servers=f"{kafka_host}:{kafka_port}",
                             value_serializer=lambda v: json.dumps(v).encode('utf-8'))
    while True:
        data = {'id': '{}'.format(random.randint(1, 10000)), 'revenue': '{}'.format(random.randint(1, 10000)),
                'revenue_counted': '{}'.format(random.choice([True, False])),
                'timestamp': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
        producer.send(raw_data_topic, data)

        print("Message generated")
        time.sleep(1)


main()
