package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	var endpoint, action string
	flag.StringVar(&endpoint, "h", "default", "enter valid URI here: http://domain.com ")
	flag.StringVar(&action, "a", "default", "enter valid action ")
	flag.Parse()

	switch action {
	case "check":
		http_get(endpoint)
	default:
		fmt.Println("You should specify propper action, current :", action)
	}
}

func http_get(a string) {
	res, err := http.Get(a)
	if err != nil {
		log.Fatal(err)
	}
	robots, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("%s", robots)
}
