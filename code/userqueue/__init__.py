import redis
import time
import pprint
pp = pprint.PrettyPrinter(indent=4)

class UserQueue:
	redis = None
	queue = None

	def __init__(self, host = 'localhost', port = 6379):
		self.redis = redis.StrictRedis(host=host, port=port, db=0)
		self.queue = self.RefreshQueue()

	def RefreshQueue(self):
		queue = self.redis.smembers("UserQueue")
		if queue is None:
			queue = []

		self.queue = queue

	def AddEntry(self, id):
		if id is None:
			return False

		key = "User-" + str(id)

		entry = self.redis.hgetall(key)

		if entry is None or len(entry) == 0:
			entry = {
				"id": id,
				"created_at": time.time(),
				"parsed_at": None
			}
			self.redis.hmset(key, entry)
			self.redis.sadd("UserQueue", key)
			self.RefreshQueue()

	def MarkParsed(self, id):
		if id is None:
			return False

		key = "User-" + str(id)

		if not self.redis.sismember("UserQueue", key):
			return False

		entry = self.redis.hget(key, "parsed_at")

		if entry == "None".encode('ascii'):
			self.redis.hset(key, "parsed_at", time.time())

		self.redis.srem("UserQueue", key)


