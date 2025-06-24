{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.services.kiwivm-ga;
  kiwivm-ga = pkgs.writeScript "kiwivm-ga" ''
    #!${pkgs.bashNonInteractive}/bin/bash
    export PATH=${pkgs.bashNonInteractive}/bin:$PATH

    SERIALSTDIO=/dev/virtio-ports/kiwicomm.port0
    SERIALSTDERR=/dev/virtio-ports/kiwicomm.port1
    SERIALSTDIO_V2_DEDICATED_OUT=/dev/virtio-ports/kiwicomm.port2
    AGENT_V2_UNIQUE_END_OF_HOST_MESSAGE=QEMU-KVM_GA_EOHM_1qyS4IWIW5ybXAQ2omPksb80OWsXU
    PROTO_VERSION=2

    accumulated_cmd=""
    accumulating=""
    while true; do
      input=""

      while IFS= read -r line || [[ -n "$line" ]]; do
        input+=$line

        case $line in
        *$AGENT_V2_UNIQUE_END_OF_HOST_MESSAGE* | __CHUNKED_TRANSFER_START__ | __CHUNKED_TRANSFER_END__)
          break
          ;;
        esac
        input+=$'\n'
      done < "$SERIALSTDIO"
      echo "INPUT: $input"

      # remove AGENT_V2_UNIQUE_END_OF_HOST_MESSAGE from received input
      input=''${input/$AGENT_V2_UNIQUE_END_OF_HOST_MESSAGE/}
      case $line in
      "")
        sleep 1
        continue
        ;;
      *"echo qemu-kvm_ga_get_proto_version"*)
        internal_cmd=''${line//qemu-kvm_ga_get_proto_version/QEMUKVM_GA_PROTO_VERSION:$PROTO_VERSION}
        UNIQUE_EOT=''${line#*SET_UNIQUE_EOT:}
        eval $internal_cmd > $SERIALSTDIO 2>$SERIALSTDERR
        echo "EXIT CODE: $?" >$SERIALSTDERR
        continue
        ;;
      __CHUNKED_TRANSFER_START__)
        accumulating=1
        accumulated_cmd=""
        echo $UNIQUE_EOT > $SERIALSTDIO_V2_DEDICATED_OUT
        continue
        ;;
      __CHUNKED_TRANSFER_END__)
        accumulating=""
        temp_file=$(mktemp /dev/shm/qemu-kvm_ga.XXXXXX)
        echo "$accumulated_cmd" > "$temp_file"
        bash "$temp_file" > $SERIALSTDIO_V2_DEDICATED_OUT 2>$SERIALSTDERR
        TMP_EXIT_CODE=$?
        echo "EXIT CODE: $TMP_EXIT_CODE" >$SERIALSTDERR
        rm -f "$temp_file" 2>/dev/null
        continue
        ;;
      esac

      if [[ -n $accumulating ]]; then
        accumulated_cmd+="$input"
        echo "$UNIQUE_EOT" > $SERIALSTDIO_V2_DEDICATED_OUT
      else
        # Process non-chunked commands as before (if needed)
        temp_file=$(mktemp /dev/shm/qemu-kvm_ga.XXXXXX)
        echo "$input" > "$temp_file"
        bash "$temp_file" > $SERIALSTDIO_V2_DEDICATED_OUT 2>$SERIALSTDERR
        TMP_EXIT_CODE=$?
        echo "EXIT CODE: $TMP_EXIT_CODE" >$SERIALSTDERR
        rm -f "$temp_file" 2>/dev/null
        continue
      fi
    done
  '';
in
{
  options = {
    services.kiwivm-ga = {
      enable = lib.mkEnableOption "KiwiVM Guest Agent";
    };
  };
  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      SUBSYSTEM=="virtio-ports", ATTR{name}=="kiwicomm.port0", TAG+="systemd", ENV{SYSTEMD_WANTS}="kiwivm-ga.service"
      SUBSYSTEM=="virtio-ports", ATTR{name}=="kiwicomm.port1", TAG+="systemd", ENV{SYSTEMD_WANTS}="kiwivm-ga.service"
      SUBSYSTEM=="virtio-ports", ATTR{name}=="kiwicomm.port2", TAG+="systemd", ENV{SYSTEMD_WANTS}="kiwivm-ga.service"
    '';
    systemd.services.kiwivm-ga = {
      description = "KiwiVM Guest Agent";
      serviceConfig = {
        Type = "exec";
        ExecStart = kiwivm-ga;
        Restart = "always";
        RestartSec = 0;
      };
    };
  };
}
