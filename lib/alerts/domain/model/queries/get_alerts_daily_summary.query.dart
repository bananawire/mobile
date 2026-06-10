class GetAlertDailySummaryQuery {
  final int days;

  GetAlertDailySummaryQuery({
    this.days = 30,
  }) {
    if (days < 1 || days > 365) {
      throw ArgumentError('days must be between 1 and 365');
    }
  }
}
