# TODO: this only applies to routers group
vpn_clients := $(shell yq --raw-output ' \
    .admins + .users + .guests | to_entries[] | \
    select(.value.disabled | not) | .key \
  ' private/vpn/clients.yaml \
)
vpn_disabled_clients := $(shell yq --raw-output ' \
    .admins + .users + .guests | to_entries[] | \
    select(.value.disabled) | .key \
  ' private/vpn/clients.yaml \
)

.PHONY: ipsec
define VPNClient
  # $(1): client name

  build/vpn/clients/$(1)/vpn.mobileconfig: private/vpn/clients/$(1)/ipsec/uuid build/vpn/clients/$(1)/ipsec/ipsec.key private/vpn/clients/$(1)/ipsec/ipsec.crt private/vpn/ipsec/ca.crt private/vpn/clients.yaml | build/vpn/clients/$(1)
	umask a=,u=rw
	mobileconfig $(1) $$(wordlist 1,5,$$^) >$$@
  build/vpn/clients/$(1)/ipsec/ipsec.key: private/vpn/clients/$(1)/ipsec/ipsec.key | build/vpn/clients/$(1)/ipsec
	nixverse secrets decrypt --out $$@ $$<
  private/vpn/clients/$(1)/ipsec/ipsec.key: | private/vpn/clients/$(1)/ipsec
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $$@
	nixverse secrets encrypt --in-place $$@
  private/vpn/clients/$(1)/ipsec/ipsec.crt: build/vpn/clients/$(1)/ipsec/ipsec.key build/vpn/ipsec/ca.key private/vpn/ipsec/ca.crt
	if [[ -e $$@ ]]; then
		if key-cert-match $$< $$@; then
			touch $$@
			exit
		elif [[ $$$$? != 1 ]]; then
			exit 1
		fi
	fi
	client_group=$$$$(yq --raw-output --arg c $(1) \
		'first(to_entries[] | select(.value | has($$$$c))) | .key' \
		private/vpn/clients.yaml
	)
	if [[ $$$$client_group = guests ]]; then
		client_group=guest-ipsec
	else
		client_group=ipsec
	fi
	openssl req \
		-key $$< \
		-CAkey $$(word 2,$$^) \
		-CA $$(word 3,$$^) \
		-config '' \
		-subj "/CN=$(1).$$$$client_group" \
		-addext "subjectAltName=DNS:$(1).$$$$client_group" \
		-addext 'extendedKeyUsage=clientAuth' \
		-days 3650 \
		-batch \
		-out $$@
  private/vpn/clients/$(1)/ipsec/uuid: | private/vpn/clients/$(1)/ipsec
	uuidgen >$$@

  private/vpn/clients/$(1)/ipsec \
  build/vpn/clients/$(1) \
  build/vpn/clients/$(1)/ipsec:
	mkdir -p $$@
endef
$(foreach name,$(vpn_clients) $(vpn_disabled_clients),$(eval $(call VPNClient,$(name))))

ipsec: $(vpn_clients:%=build/vpn/clients/%/vpn.mobileconfig)

build/vpn/ipsec/ca.key: private/vpn/ipsec/ca.key | build/vpn/ipsec
	nixverse secrets decrypt --out $@ $<
private/vpn/ipsec/ca.key: | private/vpn/ipsec
	openssl ecparam -genkey \
		-name prime256v1 \
		-noout \
		-out $@
	nixverse secrets encrypt --in-place $@
private/vpn/ipsec/ca.crt: build/vpn/ipsec/ca.key | private/vpn/ipsec
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
  ipsec: private/vpn/ipsec/clients.crl
  private/vpn/ipsec/clients.crl: build/vpn/ipsec/ca.key private/vpn/ipsec/ca.crt $(vpn_disabled_clients:%=private/vpn/clients/%/ipsec/ipsec.crt)
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

private/vpn/ipsec build/vpn/ipsec:
	mkdir -p $@
