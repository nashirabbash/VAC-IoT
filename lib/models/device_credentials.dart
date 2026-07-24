class DeviceCredentials {
  final String deviceId;
  final String authPin;

  DeviceCredentials({required this.deviceId, required this.authPin});

  static DeviceCredentials? tryParseQrKey(String qrKey) {
    final parts = qrKey.split('|');
    if (parts.length == 2) {
      return DeviceCredentials(deviceId: parts[0], authPin: parts[1]);
    }
    return null;
  }
}
