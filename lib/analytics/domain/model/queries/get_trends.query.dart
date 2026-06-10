class GetTrendsQuery {
  final String deviceId;
  final String? period;
  final String? startDate;
  final String? endDate;

  const GetTrendsQuery({
    required this.deviceId,
    this.period,
    this.startDate,
    this.endDate,
  });
}
