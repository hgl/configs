define DefineRouter
  # $(1): node name

  nodes/$(1): ipsec \
    private/nodes/routers/$(1)/vpn/ipsec/server.key \
    private/nodes/routers/$(1)/vpn/ipsec/server.crt \
    private/nodes/routers/$(1)/vpn/tailscale/authkey

  private/nodes/routers/$(1)/vpn/ipsec/server.key: | private/nodes/routers/$(1)/vpn/ipsec
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $$@
	nixverse secrets encrypt --node $(1) --in-place $$@
  build/nodes/$(1)/vpn/ipsec/server.key: private/nodes/routers/$(1)/vpn/ipsec/server.key | build/nodes/$(1)/vpn/ipsec
	nixverse secrets decrypt --node $(1) --out $$@ $$<
  private/nodes/routers/$(1)/vpn/ipsec/server.crt: build/nodes/$(1)/vpn/ipsec/server.key build/nodes/$(1)/vpn/server.domain build/vpn/ipsec/ca.key private/vpn/ipsec/ca.crt | private/nodes/routers/$(1)/vpn/ipsec
	domain=$$$$(< $$(word 2,$$^))
	if [[ -e $$@ ]]; then
		if key-cert-match $$< $$@; then
			if
				[[ "$$$$(cert json '.subject.common_name' $$@)" = $$$$domain ]] &&
				[[ "$$$$(cert json '.sans[0]' $$@)" = $$$$domain ]]
			then
				touch $$@
				exit
			fi
		elif [[ $$$$? != 1 ]]; then
			exit 1
		fi
	fi
	openssl req \
		-key $$< \
		-CAkey $$(word 3,$$^) \
		-CA $$(word 4,$$^) \
		-config '' \
		-subj "/CN=$$$$domain" \
		-addext "subjectAltName=DNS:$$$$domain" \
		-addext 'extendedKeyUsage=serverAuth' \
		-days 3650 \
		-batch \
		-out $$@
  build/nodes/$(1)/vpn/server.domain: nodes/routers/group.nix | build/nodes/$(1)/vpn
	nixverse eval 'nodes.$(1).config.networking.fqdn' >$$@

  private/nodes/routers/$(1)/vpn/tailscale/authkey: private/nodes/routers/common/vpn/tailscale/authkey | private/nodes/routers/$(1)/vpn/tailscale
	nixverse secrets decrypt $$< | nixverse secrets encrypt --node $(1) --out $$@ -

  private/nodes/routers/$(1)/vpn/ipsec \
  private/nodes/routers/$(1)/vpn/tailscale \
  build/nodes/$(1)/vpn/ipsec \
  build/nodes/$(1)/vpn:
	mkdir -p $$@
endef
$(foreach node_name,$(group_routers_nodes),$(eval $(call DefineRouter,$(node_name))))

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

private/nodes/routers/common/vpn/tailscale:
	mkdir -p $@
