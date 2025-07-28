{
  writeShellApplication,
  openssl,
}:
writeShellApplication {
  name = "key-cert-match";
  runtimeInputs = [ openssl ];
  text = ''
    key=$1
    crt=$2
    if ! crt_pub=$(openssl x509 -noout -pubkey -in "$crt" 2>/dev/null); then
      exit 2
    fi
    if ! key_pub=$(openssl pkey -pubout -in "$key"); then
      exit 2
    fi
    [[ $key_pub = "$crt_pub" ]]
  '';
}
