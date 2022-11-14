package main

import (
	"flag"
	log "github.com/sirupsen/logrus"
	"io"
	"net/http"
	"time"
)

func main() {
	log.SetLevel(log.InfoLevel)
	var vortexEndpoint string
	flag.StringVar(&vortexEndpoint, "vortex", "", "vortex endpoint to check")
	flag.Parse()

	// Start metrics collector in another thread
	metricsServer := MetricsServer{}
	go metricsServer.StartMetricsClient()

	client := &http.Client{}
	for {
		log.Info("Running")
		time.Sleep(60 * time.Second)
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
			ReportMetrics(resp.StatusCode)
			continue
		}
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			log.WithFields(log.Fields{
				"body":  body,
				"error": err}).Warning("Unable to parse body")
		}
		ReportMetrics(resp.StatusCode)
	}
}
