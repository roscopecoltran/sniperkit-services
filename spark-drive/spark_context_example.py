from pyspark import SparkConf, SparkContext
from operator import add
import sys
import pyspark
from pyspark.streaming import StreamingContext
from pyspark.streaming.kafka import KafkaUtils
import json
import redis
from kafka import KafkaProducer

kafkaProducer = KafkaProducer(bootstrap_servers='kafka:9092', value_serializer=lambda v: json.dumps(v).encode('utf-8'))
redisClient = redis.StrictRedis(host='redis', port=6379)

totalOrdersKey = 'abs_totals:orders'
totalRevenueKey = 'abs_totals:revenue'

def initializeAbsoluteTotals():
	if not redisClient.get(totalOrdersKey):
		redisClient.set(totalOrdersKey, 0)

	if not redisClient.get(totalRevenueKey):
		redisClient.set(totalRevenueKey, 0.0)

initializeAbsoluteTotals()

def processCall(callJson):
	for record in callJson:
		previousCall = redisClient.get(record['id'])

		if previousCall:
			handleCallUpdate(previousCall, record)
		else:
			handleCallCreate(record)

def handleCallUpdate(previousCall, newCall):
	json.dumps(previousCall)
	for element in previousCall:
		if element['revenue_counted']:
			decrementAbsoluteTotals(element['revenue'])

	if newCall['revenue_counted']:
		incrementAbsoluteTotals(newCall['revenue'])

	writeInRedis(newCall['id'], newCall)

def handleCallCreate(newCall):
	if newCall['revenue_counted']:
		incrementAbsoluteTotals(newCall['revenue'])

	writeInRedis(newCall['id'], newCall)

def incrementAbsoluteTotals(revenue):
	redisClient.incr(totalOrdersKey, 1)
	redisClient.incr(totalOrdersKey, revenue)

def decrementAbsoluteTotals(revenue):
	redisClient.decr(totalOrdersKey, 1)
	redisClient.decr(totalOrdersKey, revenue)

def notifyTotalUpdate():
	totalOrders = redisClient.get(totalOrdersKey)
	totalRevenue = redisClient.get(totalRevenueKey)

	kafkaProducer.send('aggregated_data', { 'total_revenue': totalRevenue, 'total_orders': totalOrders})

def writeInRedis(id, callJson):
	redisClient.set(id, str(callJson))
	print(redisClient.get(id))

def main():
	#create spark context
	sc = SparkContext(appName="SparkStreamingWithKafka")
	# create spark streaming context from spark context(sc) , second parameter is for batch duration
	ssc = StreamingContext(sc,1)
	# create kafka direct stream
	kvs = KafkaUtils.createDirectStream(ssc, ['raw_data'], {"metadata.broker.list":"kafka:9092"})
	# loop over RDDs and process each of them
	kvs.map(lambda v: json.loads(v[1])) \
	.foreachRDD(lambda rddRecord: processCall(rddRecord.collect()))
	# start streaming context
	ssc.start()
	# await for termination of the streaming context
	ssc.awaitTermination()

main()