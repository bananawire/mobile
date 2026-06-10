import 'package:mobile/devices/domain/model/valueobjects/metric_threshold.valueobject.dart';
import 'package:mobile/devices/interfaces/pages/device_detail/device_detail_view_model.dart';

List<DeviceDetailThresholdViewModel> buildDefaultDeviceDetailThresholdResources() {
  return const [
    DeviceDetailThresholdViewModel(
      metric: MetricThreshold.pm25,
      label: 'PM2.5',
      value: 60,
      unit: 'µg/m³',
      enabled: true,
    ),
    DeviceDetailThresholdViewModel(
      metric: MetricThreshold.co2,
      label: 'CO₂',
      value: 1000,
      unit: 'ppm',
      enabled: true,
    ),
    DeviceDetailThresholdViewModel(
      metric: MetricThreshold.temperature,
      label: 'TEMP',
      value: 28.7,
      unit: '°C',
      enabled: true,
    ),
    DeviceDetailThresholdViewModel(
      metric: MetricThreshold.humidity,
      label: 'HUMIDITY',
      value: 80,
      unit: '%',
      enabled: true,
    ),
  ];
}
