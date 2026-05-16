{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  makeWrapper,
  makeRustPlatform,
  nodejs_24,
  pnpm_8,
  pnpmConfigHook,
  rust-bin,
}:

let
  pnpm = pnpm_8.override { nodejs = nodejs_24; };
  rustToolchain = rust-bin.stable.latest.default.override {
    targets = [ "wasm32-wasip2" ];
  };
  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };
  src = fetchFromGitHub {
    owner = "vercel";
    repo = "vercel";
    rev = "b29ecc937b6a7f869004a76da5ab0bb0c52fd69e";
    hash = "sha256-yLFX2DGcfHuIqHSL3H1j+twVwS8rwJJTdAPWxmGth2Q=";
  };
  pnpmDeps = fetchPnpmDeps {
    pname = "vercel";
    version = "53.2.0";
    inherit src pnpm;
    fetcherVersion = 3;
    hash = "sha256-QuFmBA7VHrH4/CU/Q0cEVuWv+sOtXbZ/6in/w56b9/4=";
  };
  pythonAnalysisWasm = stdenv.mkDerivation {
    pname = "vercel-python-analysis-wasm";
    version = "0.11.1";

    inherit src pnpmDeps;

    cargoRoot = "packages/python-analysis";
    cargoDeps = rustPlatform.fetchCargoVendor {
      pname = "vercel-python-analysis";
      version = "0.11.1";
      inherit src;
      cargoRoot = "packages/python-analysis";
      hash = "sha256-ZHdPWcXe6r3HnYYQJpwW/vd1TvKeKpUOf/TcJ/2v378=";
    };

    nativeBuildInputs = [
      nodejs_24
      pnpm
      pnpmConfigHook
      rustPlatform.cargoSetupHook
      rustToolchain
    ];

    env = {
      CARGO_NET_OFFLINE = "true";
    };

    postPatch = ''
      substituteInPlace packages/python-analysis/scripts/build-wasm.mjs \
        --replace-fail "checkToolchain();" ""
    '';

    buildPhase = ''
      runHook preBuild

      node packages/python-analysis/scripts/build-wasm.mjs

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -R packages/python-analysis/dist/wasm "$out/wasm"

      runHook postInstall
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "vercel";
  version = "53.2.0";

  inherit src pnpmDeps;

  postPatch = ''
    substituteInPlace packages/python-analysis/package.json \
      --replace-fail '"build": "pnpm generate:schemas && pnpm build:wasm && node scripts/build.mjs"' \
                     '"build": "pnpm generate:schemas && node scripts/build.mjs"'
  '';

  nativeBuildInputs = [
    makeWrapper
    nodejs_24
    pnpm
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p packages/python-analysis/dist
    cp -R ${pythonAnalysisWasm}/wasm packages/python-analysis/dist/wasm
    chmod -R u+w packages/python-analysis/dist/wasm

    pnpm --reporter append-only --filter vercel... build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/node_modules"
    cp -R . "$out/lib/node_modules/vercel"
    chmod -R u+w "$out/lib/node_modules/vercel"

    makeWrapper ${nodejs_24}/bin/node "$out/bin/vercel" \
      --add-flags "$out/lib/node_modules/vercel/packages/cli/dist/vc.js"
    ln -s vercel "$out/bin/vc"

    runHook postInstall
  '';

  meta = {
    description = "Command-line interface for Vercel";
    homepage = "https://github.com/vercel/vercel/tree/main/packages/cli";
    license = lib.licenses.asl20;
    mainProgram = "vercel";
    platforms = nodejs_24.meta.platforms;
  };
})
