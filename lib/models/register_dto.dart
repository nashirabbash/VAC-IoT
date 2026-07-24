class RegisterDto {
  final String username;
  final String password;
  final String hospitalName;
  final String? qrKey;

  RegisterDto({
    required this.username,
    required this.password,
    required this.hospitalName,
    this.qrKey,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      'username': username,
      'name': username, // Backend validation requires a 'name' field
      'password': password,
      'hospitalName': hospitalName,
    };
    if (qrKey != null) {
      payload['qrKey'] = qrKey!;
    }
    return payload;
  }
}
