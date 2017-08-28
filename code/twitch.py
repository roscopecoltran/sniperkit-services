import sys 
from py2neo import Graph, Node, Relationship
import requests
import json
import pprint
import os

import userqueue

pp = pprint.PrettyPrinter(indent=4)

q = userqueue.UserQueue("localhost", "6379")

raise SystemExit


neo = Graph(user="twitch", password="twitch")

try:
	client_id = os.environ["CLIENT_ID"]
	user_to_parse = os.environ["CHANNEL"] # naming duh
except KeyError:
	print("Usage: CLIENT_ID=<twitch client id> CHANNEL=<channel name> python twitch.py")
	raise SystemExit


headers = {
	"Accept": "application/vnd.twitchtv.v5+json",
	"Client-ID": client_id
}


def findOrCreateChannel(channel):
	existing = neo.find_one(label="Channel", property_key="twitch_id", property_value=channel["twitch_id"])
	if existing is None:
		c = Node('Channel', name=channel["name"], followers=channel["follower_count"], twitch_id=channel["twitch_id"])
		neo.create(c)
		return c
	else:
		return existing

def findOrCreateUser(user):
	existing = neo.find_one(label="User", property_key="twitch_id", property_value=user["_id"])
	if existing is None:
		u = Node('User', name=user["name"], twitch_id=user["_id"])
		neo.create(u)
		return u
	else:
		return existing

def findOrCreateRelation(user, channel):
	existing = neo.match_one(start_node=user, rel_type="FOLLOWS", end_node=channel)
	if existing is None:
		r = Relationship(user, "FOLLOWS", channel)
		neo.create(r)
		return r
	else:
		return existing


def getChannelInfo(id):
	url = "https://api.twitch.tv/kraken/channels/" + str(id)
	r = requests.get(url, headers=headers)
	response = json.loads(r.text)
	return {
		"twitch_id": response["_id"],
		"name": response["name"],
		"follower_count": response["followers"]
	}

def getFollowers(channel):
	users = []

	chunk = 30
	current = 0
	cursor = None
	while current < channel["followers"]:
		remaining = channel["followers"] - current
		if remaining < 0:
			remaining = 0

		print("\n====\nRemaining: " + str(remaining) + "\n====")

		url = "https://api.twitch.tv/kraken/channels/" + channel["twitch_id"] + "/follows?limit=" + str(chunk)
		if cursor is not None:
			url += "&cursor=" + str(cursor)
		r = requests.get(url, headers=headers)
		response = json.loads(r.text)
		try:
			for record in response["follows"]:
				user = findOrCreateUser(record["user"])
				findOrCreateRelation(user, channel)
				print(user["name"] + " FOLLOW " + channel["name"])
		except KeyError:
			pp.pprint(r.status_code)
			pp.pprint(r.text)
			raise SystemExit
		cursor = response["_cursor"]
		current += chunk

r = requests.get("https://api.twitch.tv/kraken/users?login=" + user_to_parse, headers=headers)
response = json.loads(r.text)
user_id = response["users"][0]["_id"]

initial_channel_info = getChannelInfo(user_id)
channel = findOrCreateChannel(initial_channel_info)
followers = getFollowers(channel)
