$(foreach node_name,$(routers_node_names),$(eval \
  nodes/$(node_name): ipsec \
    private/nodes/routers/$(node_name)/vpn/ipsec/server.key \
    nodes/routers/$(node_name)/vpn/ipsec/server.crt \
    private/nodes/routers/$(node_name)/vpn/tailscale/authkey \
))

private/nodes/routers/%/vpn/ipsec/server.key: | private/nodes/routers/%/vpn/ipsec
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $@
	nixverse secrets encrypt --in-place $@
build/nodes/routers/%/vpn/ipsec/server.key: private/nodes/routers/%/vpn/ipsec/server.key | build/nodes/routers/%/vpn/ipsec
	nixverse secrets decrypt $< $@
nodes/routers/%/vpn/ipsec/server.crt: build/nodes/routers/%/vpn/ipsec/server.key build/nodes/routers/%/vpn/server.domain build/vpn/ipsec/ca.key vpn/ipsec/ca.crt | nodes/routers/%/vpn/ipsec
	domain=$$(< $(word 2,$^))
	if [[ -e $@ ]]; then
		if key-cert-match $< $@; then
			if
				[[ "$$(cert json '.subject.common_name' $@)" = $$domain ]] &&
				[[ "$$(cert json '.sans[0]' $@)" = $$domain ]]
			then
				touch $@
				exit
			fi
		elif [[ $$? != 1 ]]; then
			exit 1
		fi
	fi
	openssl req \
		-key $< \
		-CAkey $(word 3,$^) \
		-CA $(word 4,$^) \
		-config '' \
		-subj "/CN=$$domain" \
		-addext "subjectAltName=DNS:$$domain" \
		-addext 'extendedKeyUsage=serverAuth' \
		-days 3650 \
		-batch \
		-out $@
build/nodes/routers/%/vpn/server.domain: nodes/routers/group.nix | build/nodes/routers/%/vpn
	nixverse node value $* | jq --raw-output '.$*.domain' >$@

private/nodes/routers/%/vpn/tailscale/authkey: private/nodes/routers/common/vpn/tailscale/authkey | private/nodes/routers/%/vpn/tailscale
	nixverse secrets decrypt $< | nixverse secrets encrypt - $@

private/nodes/routers/common/vpn/tailscale/authkey: FORCE | private/nodes/routers/common/vpn/tailscale
	now=$$(date +%s)
	if [[ -e $@ && -e $@.expiry ]]; then
		expiry=$$(< $@.expiry)
		if ((expiry > now)); then
			exit
		fi
	fi
	IFS=, read -r oauth_id oauth_secret < <(
		nixverse secrets decrypt $(@D)/secrets.yaml |
			yq --raw-output '"\(.oauth_id),\(.oauth_secret)"'
	)
	umask a=,u=rw
	TS_API_CLIENT_ID=$$oauth_id \
		TS_API_CLIENT_SECRET=$$oauth_secret \
		tailscale-authkey -reusable -preauth -tags tag:router $@
	nixverse secrets encrypt --in-place $@

$(foreach node_name,$(routers_node_names), \
  nodes/routers/$(node_name)/vpn/ipsec \
  private/nodes/routers/$(node_name)/vpn/ipsec \
  private/nodes/routers/$(node_name)/vpn/tailscale \
  build/nodes/routers/$(node_name)/vpn/ipsec \
  build/nodes/routers/$(node_name)/vpn \
) \
private/nodes/routers/common/vpn/tailscale:
	mkdir -p $@
