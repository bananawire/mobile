enum DeviceCommandType {
  standby,
  wake,
  restart;

  String get apiValue {
    switch (this) {
      case DeviceCommandType.standby:
        return 'STANDBY';
      case DeviceCommandType.wake:
        return 'WAKE';
      case DeviceCommandType.restart:
        return 'RESTART';
    }
  }
}
