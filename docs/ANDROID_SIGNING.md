# Android Signing Certificates

This document contains the SHA-1 and SHA-256 fingerprints required for Google Auth, Firebase, and other Google Cloud services in this project.

## Debug Certificates

These are used for local development and testing.

### How to regenerate them
If you need to regenerate the debug keystore or view these values again, use the following commands:

#### 1. Generate the debug keystore (if it doesn't exist)
```bash
keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
```

#### 2. View the fingerprints
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## Troubleshooting (Nix-specific)

In this environment (NixOS), running `./gradlew signingReport` might fail with:
`The SDK directory is not writable (/nix/store/...)`

This happens because Gradle tries to install missing components (like the NDK) into the read-only Nix store. Using `keytool` as shown above is the recommended workaround to obtain the fingerprints without needing a full Gradle build.

## Release Certificates

When you are ready for production:
1. Create a release keystore: `flutter build apk --release` (follow the official [Flutter documentation](https://docs.flutter.dev/deployment/android#signing-the-app)).
2. Use `keytool` on your generated `.jks` file to get the Release SHA-1.
3. Add the Release SHA-1 to your Google Cloud / Firebase console.
