class ClaimDeviceRequestResource {
  final String claimToken;
  final String spaceId;

  const ClaimDeviceRequestResource({
    required this.claimToken,
    required this.spaceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'claimToken': claimToken,
      'spaceId': spaceId,
    };
  }
}
