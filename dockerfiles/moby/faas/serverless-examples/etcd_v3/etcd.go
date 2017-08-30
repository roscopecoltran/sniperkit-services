package main

import (
	"fmt"
	"io/ioutil"
	"time"

	"golang.org/x/net/context"

	"os"
	"strings"

	"github.com/Sirupsen/logrus"
	"github.com/coreos/etcd/clientv3"
	"github.com/coreos/etcd/etcdserver/api/v3rpc/rpctypes"
	"github.com/tidwall/gjson"
)

func main() {
	var Endpoints []string
	etcdServer := os.Getenv("ETCD_SERVER")
	if etcdServer == "" {
		logrus.Info("etcd server address can not be empty.please set env ETCD_SERVER")
		return
	}
	if strings.Contains(etcdServer, ",") {
		Endpoints = strings.Split(etcdServer, ",")
	} else {
		Endpoints = append(Endpoints, etcdServer)
	}
	in, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		logrus.Error("read data from stdin error.", err.Error())
		return
	}
	method := gjson.Get(string(in), "method").String()
	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   Endpoints,
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		handleError(err)
	}

	timeout := time.Second * 20
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	switch strings.ToUpper(method) {
	case "GET":
		key := gjson.Get(string(in), "key").String()
		resp, err := cli.Get(ctx, key)
		cancel()
		if err != nil {
			handleError(err)
		}
		for _, ev := range resp.Kvs {
			fmt.Printf("%s : %s\n", ev.Key, ev.Value)
		}
	case "PUT":
		key := gjson.Get(string(in), "key").String()
		value := gjson.Get(string(in), "value").String()
		_, err := cli.Put(ctx, key, value)
		cancel()
		if err != nil {
			handleError(err)
		} else {
			fmt.Printf("Put %s success.", key)
		}
	}
	defer cli.Close()

}

func handleError(err error) {
	switch err {
	case context.Canceled:
		logrus.Errorf("ctx is canceled by another routine: %v", err)
	case context.DeadlineExceeded:
		logrus.Errorf("ctx is attached with a deadline is exceeded: %v", err)
	case rpctypes.ErrEmptyKey:
		logrus.Errorf("client-side error: %v", err)
	default:
		logrus.Errorf("bad cluster endpoints, which are not etcd servers: %v", err)
	}
}
