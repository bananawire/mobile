import 'package:mobile/alerts/domain/model/valueobjects/alert.valueobject.dart';

class AlertPage {
  final List<Alert> content;

  final int totalElements;
  final int totalPages;
  final int size;
  final int number;

  const AlertPage({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });
}
