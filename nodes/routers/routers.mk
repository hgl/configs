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
build/nodes/routers/%/vpn/ipsec/server.key: private/nodes/routers/%/vpn/ipsec/server.key | build/nodes/routers/%/ipsec
	nixverse secrets decrypt $< $@
nodes/routers/%/vpn/ipsec/server.crt: build/nodes/routers/%/vpn/ipsec/server.key build/nodes/routers/%/vpn/server.domain build/vpn/ipsec/ca.key vpn/ipsec/ca.crt
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
build/nodes/routers/%/vpn/server.domain: nodes/routers/%/group.nix | build/nodes/routers/%/vpn
	nixverse node value $* | jq --raw-output '.nodes.$*.domain' $* $< >$@

private/nodes/routers/%/vpn/tailscale/authkey: private/nodes/routers/common/vpn/tailscale/authkey | private/nodes/routers/%/vpn/tailscale
	nixverse secrets decrypt $< | nixverse secrets encrypt - $@

# FIXME: use FORCE, and get expiry from the API to record it in $@.expire
private/nodes/routers/common/vpn/tailscale/authkey: | private/nodes/routers/common/vpn/tailscale
	now=$$(date +%s)
	if [[ -e $@ && -e $@.expire ]]; then
		expire=$$(< $@.expire)
		if ((expire > now)); then
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
		tailscale-get-authkey -reusable -tags tag:router >$@
	nixverse secrets encrypt --in-place $@
	echo "$$(now + 3600 * 24 * 30)" >$$@.expire

$(foreach node_name,$(routers_node_names), \
  private/nodes/routers/$(node_name)/ipsec \
  build/nodes/routers/$(node_name)/ipsec \
  private/nodes/routers/$(node_name)/vpn/tailscale \
) \
private/nodes/routers/common/vpn/tailscale:
	mkdir -p $@
