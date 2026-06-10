class DevicePairingReadModel {
  final String deviceId;
  final String? claimToken;

  const DevicePairingReadModel({
    required this.deviceId,
    required this.claimToken,
  });
}
