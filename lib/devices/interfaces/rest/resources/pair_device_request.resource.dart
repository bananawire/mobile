class PairDeviceRequestResource {
  final String hardwareId;

  const PairDeviceRequestResource({required this.hardwareId});

  Map<String, dynamic> toJson() {
    return {
      'hardwareId': hardwareId,
    };
  }
}
