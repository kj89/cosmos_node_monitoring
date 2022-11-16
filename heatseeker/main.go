package main

import (
	"context"
	"flag"
	"fmt"
	log "github.com/sirupsen/logrus"
	"google.golang.org/grpc"
	"io"
	"net/http"
	"strings"
	"time"

	banktypes "github.com/cosmos/cosmos-sdk/x/bank/types"
)

var FAUCET_ADDRESSES = []string{"sei1dhwul4rz8jfwvenqpyhdctax2tuljk2ag0v864"}

func runVortexFECheck(client *http.Client, vortexEndpoint string) {
	resp, err := client.Get(vortexEndpoint)
	if err != nil {
		log.WithFields(log.Fields{
			"vortex": vortexEndpoint,
			"error":  err}).Warning("Unable to query endpoint")
	}
	defer resp.Body.Close()
	if !(resp.StatusCode == 200) {
		log.WithFields(log.Fields{
			"status code": resp.StatusCode}).Warning("Didn't receive 200 status code")
		ReportVortexFEMetrics(resp.StatusCode)
		return
	}
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.WithFields(log.Fields{
			"body":  body,
			"error": err}).Warning("Unable to parse body")
	}
	ReportVortexFEMetrics(resp.StatusCode)

}

func runFaucetCheck(grpcConn *grpc.ClientConn, faucetAddrs []string) {
	bankClient := banktypes.NewQueryClient(grpcConn)
	for _, addr := range faucetAddrs {
		bankRes, err := bankClient.AllBalances(
			context.Background(),
			&banktypes.QueryAllBalancesRequest{Address: addr},
		)
		if err != nil {
			log.Error(fmt.Sprintf("Could not get balance for faucet %s", addr), err)
			continue
		}
		for _, balance := range bankRes.Balances {
			ReportFaucetMetrics(addr, float32(balance.Amount.Int64()), balance.Denom)
		}
	}
}

func main() {
	log.SetLevel(log.InfoLevel)
	var vortexEndpoint string
	var nodeAddress string
	var faucetAddrs string
	flag.StringVar(&vortexEndpoint, "vortex", "", "vortex endpoint to check")
	flag.StringVar(&nodeAddress, "node-address", "", "node address to check")
	flag.StringVar(&faucetAddrs, "faucet-addrs", "", "comma separated list of faucet addrs to check")
	flag.Parse()

	// Start metrics collector in another thread
	metricsServer := MetricsServer{}
	go metricsServer.StartMetricsClient()

	client := &http.Client{}
	grpcConn, err := grpc.Dial(
		nodeAddress,
		grpc.WithInsecure(),
	)
	if err != nil {
		log.Fatal("Could not connect to gRPC node")
	}

	for {
		log.Info("Running")
		time.Sleep(60 * time.Second)
		// Add and run checks you'd like here
		runVortexFECheck(client, vortexEndpoint)
		runFaucetCheck(grpcConn, strings.Split(faucetAddrs, ","))
	}
}
