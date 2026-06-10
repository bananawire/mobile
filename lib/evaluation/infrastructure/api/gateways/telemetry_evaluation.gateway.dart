abstract class TelemetryEvaluationGateway {
  Future<Map<String, dynamic>> getLatestByDeviceRaw(String deviceId);
}
