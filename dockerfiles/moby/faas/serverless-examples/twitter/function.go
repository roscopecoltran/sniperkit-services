package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/dghubble/go-twitter/twitter"
	"github.com/dghubble/oauth1"
)

type payload struct {
	Username string `json:"username"`
}

func main() {
	username := "zengqingguo"
	usernameENV := os.Getenv("USER_NAME")
	if usernameENV != "" {
		username = usernameENV
	}
	payloadD, err := ioutil.ReadAll(os.Stdin)
	if err == nil {
		var pl payload

		err := json.Unmarshal(payloadD, &pl)
		if err != nil {
			log.Println("Payload data dont' unmarshal. use account:" + username)
		}
		if pl.Username != "" {
			username = pl.Username
		}
	}

	fmt.Println("Looking for tweets of the account:", username)
	if os.Getenv("CUSTOMER_KEY") == "XXXXXX" {
		fmt.Println("Please config the twitter app info in env. example:CUSTOMER_KEY CUSTOMER_SECRET ACCESS_TOKEN ACCESS_SECRET")
		return
	}
	// Twitter auth config
	config := oauth1.NewConfig(os.Getenv("CUSTOMER_KEY"), os.Getenv("CUSTOMER_SECRET"))
	token := oauth1.NewToken(os.Getenv("ACCESS_TOKEN"), os.Getenv("ACCESS_SECRET"))

	httpClient := config.Client(oauth1.NoContext, token)

	// Twitter client
	client := twitter.NewClient(httpClient)

	// Load tweets
	tweets, _, err := client.Timelines.UserTimeline(&twitter.UserTimelineParams{ScreenName: username})
	if err != nil {
		fmt.Println("Error loading tweets: ", err)
	}

	// Show tweets
	for _, tweet := range tweets {
		fmt.Println(tweet.User.Name + ": " + tweet.Text)
	}

}
