class GetDashboardMetricsQuery {
  final String deviceId;
  final String? period;
  final String? startDate;
  final String? endDate;

  const GetDashboardMetricsQuery({
    required this.deviceId,
    this.period,
    this.startDate,
    this.endDate,
  });
}
