#!/usr/bin/env bash

option=$1
DESC="OpsBot"

create_spark_room(){
  SPARK_ROOM_ID=$(curl --silent -X POST \
                  https://api.ciscospark.com/v1/rooms \
                  -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"'  \
                  -H 'cache-control: no-cache' \
                  -H 'content-type: application/json' \
                  -H 'postman-token: 1c57b1f2-ebc8-465c-409d-8fcb30ae71cd' \
                  -d '{
                    "title": "'"$SPARK_ROOM_NAME"'"
                }' | jq '.id' | tr -d '"')
  sed -i -e "/SPARK_ROOM_ID=/ s/=.*/=$SPARK_ROOM_ID/" app.env
  sed -i -e "/HUBOT_SPARK_ROOMS=/ s/=.*/=$SPARK_ROOM_ID/" app.env
  echo "$SPARK_ROOM_NAME Spark Room Created with ID  $SPARK_ROOM_ID"
}

add_bot_to_room(){
  result=$(curl --silent -X POST \
      https://api.ciscospark.com/v1/memberships \
      -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"' \
      -H 'cache-control: no-cache' \
      -H 'content-type: application/json' \
      -H 'postman-token: 0ce60194-65cd-98e0-cad8-3f701ca61557' \
      -d "{
      \"roomId\" : \"$SPARK_ROOM_ID\",
      \"personEmail\": \"$BOT_ID\",
      \"isModerator\": \"false\"
    }" | jq '.personDisplayName + " Added to Room " + .roomId' | tr -d '"')
    echo $result
}

create_web_hook(){
	WEBHOOK_ID=$(curl --silent -X POST \
	  https://api.ciscospark.com/v1/webhooks/ \
	  -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"' \
	  -H 'cache-control: no-cache' \
	  -H 'content-type: application/json' \
	  -H 'postman-token: 51de4f01-71a9-8c09-acd4-00b514b21a54' \
	  -d '{
	      "name": "'"$SPARK_WEBHOOK_NAME"'",
	      "resource": "messages",
	      "event": "created",
	      "targetUrl": "'"$WEBHOOK_URL"'",
	      "filter": "'"roomId=$SPARK_ROOM_ID"'"
	    }' | jq '.id' | tr -d '"')

	#echo "SPARK_ACCESS_TOKEN : $SPARK_ACCESS_TOKEN"
  #echo "SPARK_WEBHOOK_NAME : $SPARK_WEBHOOK_NAME"
  #echo "WEBHOOK_URL : $WEBHOOK_URL"
  #echo "SPARK_ROOM_ID : $SPARK_ROOM_ID"

	echo "$SPARK_WEBHOOK_NAME Created with ID : $WEBHOOK_ID"
	sed -i -e "/WEBHOOK_ID=/ s/=.*/=$WEBHOOK_ID/" app.env
}

delete_spark_room(){
  echo "Deleting Spark Room : $SPARK_ROOM_NAME with ID : $SPARK_ROOM_ID"
  curl --silent -X DELETE https://api.ciscospark.com/v1/rooms/$SPARK_ROOM_ID \
        -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"'  \
        -H 'cache-control: no-cache'  \
        -H 'content-type: application/json'  \
        -H 'postman-token: 9650c4ad-503a-69d7-4c99-0cf124e1b75d'
}

delete_web_hook(){
  echo "Deleting Spark Webhook: $$SPARK_WEBHOOK_NAME with ID  : $WEBHOOK_ID"
  curl -X DELETE \
    https://api.ciscospark.com/v1/webhooks/$WEBHOOK_ID \
        -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"' \
        -H 'cache-control: no-cache' \
        -H 'content-type: application/json' \
        -H 'postman-token: a7ba472d-c9b8-b0ce-5446-4416dafca1a7'
}

reset_env_vars(){
  sed -i -e "/SPARK_ROOM_ID=/ s/=.*/=/" app.env
  sed -i -e "/HUBOT_SPARK_ROOMS=/ s/=.*/=/" app.env
  sed -i -e "/WEBHOOK_ID=/ s/=.*/=/" app.env
  rm -fr app.env-e
  source app.env
}


cleanup(){
  delete_spark_room
  delete_web_hook
  reset_env_vars
}

list_room_createdByTest(){
  list=$(curl --silent -X GET  'https://api.ciscospark.com/v1/rooms?max=10' \
       -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"' \
       -H 'cache-control: no-cache' \
       -H 'postman-token: 025056f4-ccaf-cc04-57d8-3417e3cb92a5' )
  echo $list  | jq '.items[] | "Room Name : "+.title + ", Room ID :" + .id' | grep $SPARK_ROOM_NAME  | tr -d '"'
}

list_webhook_createdByTest(){
  list=$(curl --silent -X GET  'https://api.ciscospark.com/v1/webhooks/' \
       -H 'authorization: Bearer "'"$SPARK_ACCESS_TOKEN"'"' \
       -H 'cache-control: no-cache' \
       -H 'content-type: application/json' \
       -H 'postman-token: 025056f4-ccaf-cc04-57d8-3417e3cb92a5' )
  echo $list  | jq '.items[] | "Webhook Name : "+.name + ", Hook ID :" + .id' | grep $SPARK_WEBHOOK_NAME  | tr -d '"'
}

log_test_data(){
    list_room_createdByTest
    list_webhook_createdByTest
}

set -e

case "$option" in
    setup)
       echo -n "Setup $DESC "
       source app.env
       create_spark_room
       add_bot_to_room
       create_web_hook
    ;;

    start)
        echo -n "Starting $DESC: "
        source app.env
        bin/hubot -a spark

    ;;

    stop)
        echo -n "Stopping $DESC: "
        echo "Yet To Implement"
    ;;

    teardown)
        echo -n "TearDown $DESC: "
        source app.env
        cleanup

    ;;

    log)
       echo -n "Log Test Data Status For $DESC "
       source app.env
       log_test_data
    ;;
    *)
        echo "Usage: ./ops-bot.sh.sh {setup|start|stop|teardown|log}" >&2
        exit 1
    ;;
esac
exit 0
