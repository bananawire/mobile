abstract class TelemetryEvaluationGateway {
  Future<Map<String, dynamic>> getLatestByDeviceRaw(String deviceId);
  Future<Map<String, dynamic>> getLatestTelemetryEvaluationByDevice(String deviceId);
}

