class DeviceCredentials {
  final String deviceId;
  final String authPin;

  DeviceCredentials({required this.deviceId, required this.authPin});

  static DeviceCredentials? tryParseQrKey(String qrKey) {
    final parts = qrKey.split('|');
    if (parts.length == 2) {
      return DeviceCredentials(deviceId: parts[0], authPin: parts[1]);
    } else if (parts.length == 6) {
      // Format: PREFIX|MAC_ADDRESS|SECURITY_STRING|DEVICE_NAME|AUTH_KEY|HMAC
      // parts[0] is PREFIX (BTPTHI), parts[2] is SECURITY_STRING (cdaqP)
      return DeviceCredentials(deviceId: parts[0], authPin: parts[2]);
    }
    return null;
  }
}
