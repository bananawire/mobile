class DailyAlertSummaryResource {
  final String date;
  final num count;

  const DailyAlertSummaryResource({
    required this.date,
    required this.count,
  });

  factory DailyAlertSummaryResource.fromJson(
      Map<String, dynamic> json,
      ) {
    return DailyAlertSummaryResource(
      date: (json['date'] ?? '').toString(),
      count: (json['count'] as num?) ?? num.tryParse(json['count']?.toString() ?? '') ?? 0,
    );
  }
}
