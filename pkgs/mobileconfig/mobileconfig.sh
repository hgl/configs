# shellcheck shell=bash
set -euo pipefail

client=$1
client_uuid=$(tr '[:lower:]' '[:upper:]' <"$2")
ipsec_key=$3
ipsec_crt=$4
ipsec_ca_crt=$5
clients_config=$6

# shellcheck disable=SC2016
IFS=, read -r display_name client_group < <(yq --raw-output --arg c "$client" '
	first(to_entries[] | select(.value | has($c))) | "\(.value.[$c].vpnName),\(.key)"
' "$clients_config")

ca_common_name=$(cert json '.subject.common_name' "$ipsec_ca_crt")
client_common_name=$(cert json '.subject.common_name' "$ipsec_crt")
ipsec_crt_uuid=$(uuidgen | tr '[:lower:]' '[:upper:]')
ipsec_ca_crt_uuid=$(uuidgen | tr '[:lower:]' '[:upper:]')
ipsec_ca_crt_data=$(
	base64 --wrap 52 "$ipsec_ca_crt" | sed 's/^/			/'
)
client_p12_data=$(
	openssl pkcs12 -export \
		-inkey "$ipsec_key" \
		-in "$ipsec_crt" \
		-passout pass:0 \
		-legacy |
		base64 --wrap 52 |
		sed 's/^/			/'
)
server_addrs=$(nixverse eval 'lib.concatLines (lib.mapAttrsToList (_: node: node.config.networking.fqdn) nodes.routers.nodes)')
if [[ $client_group = admins ]]; then
	display_name=VPN
else
	server_addrs=$(head -n1 <<<"$server_addrs")
fi
cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadVersion</key>
	<integer>1</integer>
	<key>PayloadDisplayName</key>
	<string>$display_name</string>
	<key>PayloadIdentifier</key>
	<string>com.apple.vpn.profile.$client_uuid</string>
	<key>PayloadType</key>
	<string>Configuration</string>
	<key>PayloadUUID</key>
	<string>$client_uuid</string>
	<key>PayloadContent</key>
	<array>
EOF
while IFS=, read -r server_addr; do
	vpn_uuid=$(uuidgen | tr '[:lower:]' '[:upper:]')
	if [[ $client_group = admins ]]; then
		vpn_name="IPsec $server_addr"
	else
		vpn_name=$display_name
	fi
	cat <<EOF
		<dict>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>PayloadType</key>
			<string>com.apple.vpn.managed</string>
			<key>UserDefinedName</key>
			<string>$vpn_name</string>
			<key>PayloadDescription</key>
			<string>Configures VPN settings</string>
			<key>PayloadDisplayName</key>
			<string>$vpn_name</string>
			<key>PayloadIdentifier</key>
			<string>com.apple.vpn.managed.$vpn_uuid</string>
			<key>PayloadUUID</key>
			<string>$vpn_uuid</string>
			<key>VPNType</key>
			<string>IKEv2</string>
			<key>IKEv2</key>
			<dict>
				<key>RemoteAddress</key>
				<string>$server_addr</string>
				<key>AuthenticationMethod</key>
				<string>Certificate</string>
				<key>CertificateType</key>
				<string>ECDSA256</string>
				<key>ServerCertificateIssuerCommonName</key>
				<string>$ca_common_name</string>
				<key>RemoteIdentifier</key>
				<string>$server_addr</string>
				<key>LocalIdentifier</key>
				<string>$client_common_name</string>
				<key>PayloadCertificateUUID</key>
				<string>$ipsec_crt_uuid</string>
				<key>DeadPeerDetectionRate</key>
				<string>Low</string>
				<key>EnablePFS</key>
				<true/>
				<key>UseConfigurationAttributeInternalIPSubnet</key>
				<true/>
				<key>IKESecurityAssociationParameters</key>
				<dict>
					<key>DiffieHellmanGroup</key>
					<integer>31</integer>
					<key>EncryptionAlgorithm</key>
					<string>AES-128-GCM</string>
					<key>IntegrityAlgorithm</key>
					<string>SHA2-256</string>
					<key>LifeTimeInMinutes</key>
					<integer>60</integer>
				</dict>
				<key>ChildSecurityAssociationParameters</key>
				<dict>
					<key>DiffieHellmanGroup</key>
					<integer>31</integer>
					<key>EncryptionAlgorithm</key>
					<string>AES-128-GCM</string>
					<key>LifeTimeInMinutes</key>
					<integer>30</integer>
				</dict>
				<key>OnDemandEnabled</key>
				<false/>
				<key>OnDemandRules</key>
				<array>
					<dict>
						<key>InterfaceTypeMatch</key>
						<string>Ethernet</string>
						<key>Action</key>
						<string>Connect</string>
					</dict>
					<dict>
						<key>InterfaceTypeMatch</key>
						<string>WiFi</string>
						<key>Action</key>
						<string>Connect</string>
					</dict>
					<dict>
						<key>InterfaceTypeMatch</key>
						<string>Cellular</string>
						<key>Action</key>
						<string>Connect</string>
					</dict>
				</array>
			</dict>
		</dict>
EOF
done <<<"$server_addrs"
cat <<EOF
		<dict>
			<key>PayloadContent</key>
			<data>
$ipsec_ca_crt_data
			</data>
			<key>PayloadDescription</key>
			<string>Adds the CA certificate</string>
			<key>PayloadDisplayName</key>
			<string>CA certificate</string>
			<key>PayloadIdentifier</key>
			<string>com.apple.security.root.$ipsec_ca_crt_uuid</string>
			<key>PayloadType</key>
			<string>com.apple.security.root</string>
			<key>PayloadUUID</key>
			<string>$ipsec_ca_crt_uuid</string>
			<key>PayloadVersion</key>
			<integer>1</integer>
		</dict>
		<dict>
			<key>PayloadVersion</key>
			<integer>1</integer>
			<key>PayloadType</key>
			<string>com.apple.security.pkcs12</string>
			<key>PayloadDisplayName</key>
			<string>Client certificate</string>
			<key>PayloadDescription</key>
			<string>Adds the client certificate</string>
			<key>Password</key>
			<string>0</string>
			<key>PayloadContent</key>
			<data>
$client_p12_data
			</data>
			<key>PayloadIdentifier</key>
			<string>com.apple.security.pkcs12.$ipsec_crt_uuid</string>
			<key>PayloadUUID</key>
			<string>$ipsec_crt_uuid</string>
		</dict>
	</array>
</dict>
</plist>
EOF
