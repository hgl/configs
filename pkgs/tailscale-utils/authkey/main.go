package main

import (
	"cmp"
	"context"
	"flag"
	"io"
	"log"
	"net/url"
	"os"
	"strconv"
	"strings"

	"golang.org/x/oauth2/clientcredentials"
	"tailscale.com/client/tailscale/v2"
)

func main() {
	reusable := flag.Bool("reusable", false, "allocate a reusable authkey")
	ephemeral := flag.Bool("ephemeral", false, "allocate an ephemeral authkey")
	preauth := flag.Bool("preauth", true, "set the authkey as pre-authorized")
	tags := flag.String("tags", "", "comma-separated list of tags to apply to the authkey")
	flag.Parse()

	clientID := os.Getenv("TS_API_CLIENT_ID")
	clientSecret := os.Getenv("TS_API_CLIENT_SECRET")
	if clientID == "" || clientSecret == "" {
		log.Fatal("TS_API_CLIENT_ID and TS_API_CLIENT_SECRET must be set")
	}

	if *tags == "" {
		log.Fatal("at least one tag must be specified")
	}

	baseURL, err := url.Parse(cmp.Or(os.Getenv("TS_BASE_URL"), "https://api.tailscale.com"))
	if err != nil {
		log.Fatalf("invalid base URL: %v", err)
	}

	if len(flag.Args()) == 0 {
		log.Fatal("authkey path is required")
	}
	authKeyPath := flag.Arg(0)
	authKeyFile, err := os.OpenFile(authKeyPath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		log.Fatalf("failed to create authkey file: %v", err)
	}
	defer authKeyFile.Close()

	authKeyExpiryFile, err := os.OpenFile(authKeyPath+".expiry", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0600)
	if err != nil {
		log.Fatalf("failed to create authkey expiry file: %v", err)
	}
	defer authKeyExpiryFile.Close()

	credentials := clientcredentials.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		TokenURL:     baseURL.JoinPath("/api/v2/oauth/token").String(),
	}

	ctx := context.Background()
	client := &tailscale.Client{
		BaseURL:   baseURL,
		UserAgent: "tailscale-get-authkey",
		Tailnet:   "-",
		HTTP:      credentials.Client(ctx),
	}
	kr := client.Keys()

	caps := tailscale.KeyCapabilities{}
	caps.Devices.Create.Reusable = *reusable
	caps.Devices.Create.Ephemeral = *ephemeral
	caps.Devices.Create.Preauthorized = *preauth
	caps.Devices.Create.Tags = strings.Split(*tags, ",")

	key, err := kr.CreateAuthKey(ctx, tailscale.CreateKeyRequest{
		Capabilities: caps,
	})
	if err != nil {
		log.Fatal(err.Error())
	}

	io.WriteString(authKeyFile, key.Key)
	io.WriteString(authKeyExpiryFile, strconv.FormatInt(key.Expires.Unix(), 10))
}
