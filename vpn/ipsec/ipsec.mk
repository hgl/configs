# TODO: this only applies to routers group
vpn_clients := $(shell yq --raw-output ' \
    .admins + .users + .guests | to_entries[] | \
    select(if .value | has("disabled") then .value.disabled else false end | not) | .key \
  ' private/vpn/clients.yaml \
)
vpn_disabled_clients := $(shell yq --raw-output ' \
    .admins + .users + .guests | to_entries[] | \
    select(if .value | has("disabled") then .value.disabled else false end) | .key \
  ' private/vpn/clients.yaml \
)

.PHONY: ipsec
ipsec: $(foreach name,$(vpn_clients), \
  build/vpn/clients/$(name)/vpn.mobileconfig \
  private/vpn/ipsec/clients/$(name)/ipsec.crt \
  private/vpn/ipsec/clients/$(name)/ipsec.key \
  private/vpn/ipsec/clients/$(name)/uuid \
)
build/vpn/clients/%/vpn.mobileconfig: private/vpn/ipsec/clients/%/uuid build/vpn/ipsec/clients/%/ipsec.key private/vpn/ipsec/clients/%/ipsec.crt vpn/ipsec/ca.crt private/vpn/clients.yaml | build/vpn/clients/%
	umask a=,u=rw
	mobileconfig $* $(wordlist 1,5,$^) >$@
build/vpn/ipsec/clients/%/ipsec.key: private/vpn/ipsec/clients/%/ipsec.key | build/vpn/ipsec/clients/%
	nixverse secrets decrypt $< $@
private/vpn/ipsec/clients/%/ipsec.key: | private/vpn/ipsec/clients/%
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $@
	nixverse secrets encrypt --in-place $@
private/vpn/ipsec/clients/%/ipsec.crt: build/vpn/ipsec/clients/%/ipsec.key build/vpn/ipsec/ca.key vpn/ipsec/ca.crt
	if [[ -e $@ ]]; then
		if key-cert-match $< $@; then
			touch $@
			exit
		elif [[ $$? != 1 ]]; then
			exit 1
		fi
	fi
	client_group=$$(nixverse config | jq --raw-output --arg c $* \
		'first(.vpn | to_entries[] | select(.value | has($$c))) | .key'
	)
	if [[ $$client_group = guests ]]; then
		client_group=guest
	else
		client_group=user
	fi
	openssl req \
		-key $< \
		-CAkey $(word 2,$^) \
		-CA $(word 3,$^) \
		-config '' \
		-subj "/CN=$*.$$client_group" \
		-addext "subjectAltName=DNS:$*.$$client_group" \
		-addext 'extendedKeyUsage=clientAuth' \
		-days 3650 \
		-batch \
		-out $@
private/vpn/ipsec/clients/%/uuid: | private/vpn/ipsec/clients/%
	uuidgen >$@

build/vpn/ipsec/ca.key: private/vpn/ipsec/ca.key | build/vpn/ipsec
	nixverse secrets decrypt $< $@
private/vpn/ipsec/ca.key: | private/vpn/ipsec
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $@
	nixverse secrets encrypt --in-place $@
vpn/ipsec/ca.crt: build/vpn/ipsec/ca.key
	if [[ -e $@ ]]; then
		if key-cert-match $< $@; then
			touch $@
			exit
		elif [[ $$? != 1 ]]; then
			exit 1
		fi
	fi
	openssl req -x509 \
		-key $< \
		-subj '/CN=HGL IPsec CA' \
		-config '' \
		-addext 'basicConstraints=critical,CA:TRUE' \
		-addext 'keyUsage=critical,keyCertSign,cRLSign' \
		-days 3650 \
		-out $@

ifneq ($(vpn_disabled_clients),)
  ipsec: private/vpn/ipsec/clients.crl \
    $(foreach name,$(vpn_disabled_clients), \
      private/vpn/ipsec/clients/$(name)/ipsec.crt \
      private/vpn/ipsec/clients/$(name)/ipsec.key \
    )
  private/vpn/ipsec/clients.crl: build/vpn/ipsec/ca.key vpn/ipsec/ca.crt $(vpn_disabled_clients:%=private/vpn/ipsec/clients/%/ipsec.crt)
	exec >$@
	echo '-----BEGIN X509 CRL-----'
	(
		for f in $(wordlist 3,999,$^); do
			cert json .serial_number "$$f"
		done
	) |
	cfssl gencrl - $(word 2,$^) $(word 1,$^) $$((24*3600*3650)) |
	fold -w 64
	echo '-----END X509 CRL-----'
endif

private/vpn/ipsec private/vpn/ipsec/clients \
$(foreach name,$(vpn_clients) $(vpn_disabled_clients), \
  private/vpn/ipsec/clients/$(name) \
  build/vpn/clients/$(name) \
  build/vpn/ipsec/clients/$(name) \
):
	mkdir -p $@
