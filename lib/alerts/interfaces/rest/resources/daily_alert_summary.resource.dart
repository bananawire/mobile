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
    final rawCount = json['count'];
    return DailyAlertSummaryResource(
      date: (json['date'] ?? '').toString(),
      count: rawCount is num ? rawCount : num.tryParse(rawCount?.toString() ?? '') ?? 0,
    );
  }


  Map<String, dynamic> toJson() => {
    'date': date,
    'count': count,
  };
}

