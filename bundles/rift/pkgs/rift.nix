{
  lib,
  rustPlatform,
  fetchFromGitHub,
  apple-sdk_15,
  darwinMinVersionHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rift";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "rift";
    rev = "main";
    hash = "sha256-6XdjbVTfyf+1SVFvaH85xGu3a9sKDcyshUAD1nM47MA=";
  };

  cargoHash = "sha256-qN34EIfS6etz4E5PO17QoUp9YrfiqVcYgz+cs+B1c9w=";

  buildInputs = [
    apple-sdk_15
    (darwinMinVersionHook "11.0")
  ];

  # Enable unstable Rust features (let_chains, stmt_expr_attributes)
  RUSTC_BOOTSTRAP = 1;

  # Disable tests - may require GUI/accessibility
  doCheck = false;

  meta = {
    description = "Tiling window manager for macOS";
    homepage = "https://github.com/acsandmann/rift";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "rift";
  };
})
