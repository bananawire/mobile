class EvaluationDeviceId {
  final String value;

  factory EvaluationDeviceId(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      throw ArgumentError('Device id is required');
    }
    return EvaluationDeviceId._(v);
  }

  const EvaluationDeviceId._(this.value);
}
