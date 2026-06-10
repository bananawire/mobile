class Connectivity {
  final String status;
  final String? network;
  final int? signalStrength;

  const Connectivity({
    required this.status,
    required this.network,
    required this.signalStrength,
  });
}
