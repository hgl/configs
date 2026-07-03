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
    rev = "v${finalAttrs.version}";
    hash = "sha256-oOVNq4/hdiRcCbc9kaMxynnq2gXVezviQRTvjrdkfPs=";
  };

  cargoHash = "sha256-eb3Z5NIUusJApQWa6sDMRP//Y0BOToQsEIhQqqR728o=";

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
