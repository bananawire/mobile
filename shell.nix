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
  ANDROID_HOME = "/home/giks/Android/Sdk";

  buildInputs = with pkgs; [
    flutter
    jdk17
  ];

  shellHook = ''
    export PATH="$HOME/.pub-cache/bin:$PATH"
    if ! command -v patrol >/dev/null 2>&1; then
      flutter pub global activate patrol_cli 2>/dev/null || true
    fi
    echo "Run with: flutter run"
    echo "Build APK: flutter build apk"
    echo "Test: flutter test"
    echo "Patrol test: patrol test --target integration_test/<name>.dart"
    echo "Check env: flutter doctor"
  '';
}
