  class GetAlertsQuery {
    final int page;
    final int size;

    GetAlertsQuery({
      this.page = 0,
      this.size = 20,
    }) {
      if (page < 0) {
        throw ArgumentError('page must be >= 0');
      }

      if (size < 1 || size > 100) {
        throw ArgumentError('size must be between 1 and 100');
      }
    }
  }
