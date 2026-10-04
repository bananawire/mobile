{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = {
      android_sdk.accept_license = true;
      allowUnfree = true;
    };
  }
}:

let
  buildToolsVersion = "34.0.0";
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ buildToolsVersion "28.0.3" ];
    platformVersions = [ "36" "34" "28" ];
    abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
  };
  androidSdk = androidComposition.androidsdk;
in
pkgs.mkShell {
  ANDROID_SDK_ROOT = "/home/giks/Android/Sdk";

  buildInputs = with pkgs; [
    flutter
    dart
    jdk17
  ];

  # Make `patrol` (and other `dart pub global activate` tools) discoverable.
  # `~/.pub-cache/bin` is the standard location Dart uses for globally
  # activated executables. Patrol CLI lives there after activation.
  shellHook = ''
    export PATH="$HOME/.pub-cache/bin:$PATH"

    # Auto-activate patrol_cli on first shell open so the `patrol` command is
    # available. Idempotent — skips if already at the latest stable version.
    # To force re-install: `dart pub global deactivate patrol_cli` first.
    if ! command -v patrol >/dev/null 2>&1; then
      echo "[shell.nix] Activating patrol_cli (latest stable) ..."
      dart pub global activate patrol_cli 2>&1 | tail -5
    fi
  '';
}
