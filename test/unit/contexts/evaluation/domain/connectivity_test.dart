import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/evaluation/domain/model/valueobjects/connectivity.valueobject.dart';

void main() {
  group('Connectivity', () {
    test('should hold status, network, and signalStrength when all properties are provided', () {
      // Arrange
      const status = 'ONLINE';
      const network = 'WIFI-5G';
      const signalStrength = -65;

      // Act
      const connectivity = Connectivity(
        status: status,
        network: network,
        signalStrength: signalStrength,
      );

      // Assert
      expect(connectivity.status, equals(status));
      expect(connectivity.network, equals(network));
      expect(connectivity.signalStrength, equals(signalStrength));
    });

    test('should support null network and null signalStrength when values are not available', () {
      // Arrange
      const status = 'OFFLINE';

      // Act
      const connectivity = Connectivity(
        status: status,
        network: null,
        signalStrength: null,
      );

      // Assert
      expect(connectivity.status, equals(status));
      expect(connectivity.network, isNull);
      expect(connectivity.signalStrength, isNull);
    });
  });
}
