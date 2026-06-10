class DevicePairingResource {
  final String deviceId;
  final String? claimToken;

  const DevicePairingResource({
    required this.deviceId,
    required this.claimToken,
  });

  factory DevicePairingResource.fromJson(Map<String, dynamic> json) {
    return DevicePairingResource(
      deviceId: (json['deviceId'] ?? '').toString(),
      claimToken: json['claimToken']?.toString(),
    );
  }
}
