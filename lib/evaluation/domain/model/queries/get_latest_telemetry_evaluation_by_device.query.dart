import 'package:mobile/evaluation/domain/model/valueobjects/device_id.valueobject.dart';

class GetLatestTelemetryEvaluationByDeviceQuery {
  final EvaluationDeviceId deviceId;

  const GetLatestTelemetryEvaluationByDeviceQuery({required this.deviceId});
}
