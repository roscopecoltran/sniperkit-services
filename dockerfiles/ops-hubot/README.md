# About
 **ops-bot** helps teams to implement Chat Ops on Spark & Hubot.
 It would assist me in doing ops work

## Minimal requirements
* Ensure you are connected to the Internet (required to download open source libraries etc.)
* Ensure you have a valid [Cisco Spark Account](https://web.ciscospark.com/)


## Prerequisites
The developer environment relies on the components shown below.
This project is tested with the following versions see below.

Local Laptop
---

| S.No | Software            | Version | 
|------|---------------------|---------|
|  1   | [Node]              | v6.10.3 | 
|  2   | [NPM]               | v4.2.0  | 
|  3   | [Git Client]        | v2.13.0 | 
|  3   | [ngrok]             | v2.2.3  | 


## Phase-1 : Preparation
0. Setup Workspace
	```
	mkdir -p ~/Workspace;cd Workspace;git clone https://github.com/rajasoun/ops-bot;cd ops-bot;npm install;cp app.env.sample app.env
	```
1. Add Bot in Cisco [Spark](https://developer.ciscospark.com/add-bot.html)
2. Start [Ngrok] in Port 8080 with predefined public url. 
  ```
    ngrok http 8080 --subdomain spark-ops-bot
  ```
3. Edit app.env with [Bot's Details](https://developer.ciscospark.com/apps.html#)  Access token,Bot ID, Webhook URL, 
    #### Customize Following Values 
    - BOT_NAME   
    - SPARK_ROOM_NAME
    - SPARK_WEBHOOK_NAME
   #### Fill in Following Values
    - BOT_ID
    - SPARK_ACCESS_TOKEN 
    - HUBOT_SPARK_ACCESS_TOKEN
    - WEBHOOK_URL   - NGROK URL
4. Run the Setup Script to Create a Room, Add teh Bot to the Room & Create WebHook
  ```
    ./ops-bot.sh setup
  ```
5. Run the Setup Script to check Room, Webhook are created
  ```
    ./ops-bot.sh log
  ```  
6. Open Spark - You should see the Room with the Bot   
  
## Phase-2 : Start Hubot
  ```
    ./ops-bot.sh start
  ```

## Phase-3 : Teardown
  ```
    ./ops-bot.sh teardown
  ```
  
[Node]: https://nodejs.org/en/
[NPM]: https://www.npmjs.com/
[Git Client]: https://git-scm.com/downloads
[ngrok]: https://ngrok.com/download


