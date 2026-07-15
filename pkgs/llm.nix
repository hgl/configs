{
  writeShellApplication,
  llama-cpp,
}:
writeShellApplication {
  name = "llm";
  runtimeInputs = [ llama-cpp ];
  text = ''
    case "''${1-}" in
    gemma4)
      shift
      exec llama-server \
        -hf unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL \
        --temp 1.0 \
        --top-p 0.95 \
        --top-k 64 \
        --reasoning on \
        "$@"
      ;;
    qwen)
      shift
      exec llama-server \
        -hf unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL \
        --temp 0.6 \
        --top-p 0.95 \
        --top-k 20 \
        --min-p 0.00 \
        --chat-template-kwargs '{"preserve_thinking":true}'
        "$@"
      ;;
    *)
      echo "usage: llm {gemma4|qwen} [llama-server args...]" >&2
      exit 64
      ;;
    esac
  '';
}
