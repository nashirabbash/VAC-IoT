class RegisterDto {
  final String username;
  final String name;
  final String password;
  final String hospitalName;
  final String? qrKey;

  RegisterDto({
    required this.username,
    required this.name,
    required this.password,
    required this.hospitalName,
    this.qrKey,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> payload = {
      'username': username,
      'name': name,
      'password': password,
      'hospitalName': hospitalName,
    };
    if (qrKey != null) {
      payload['qrKey'] = qrKey!;
    }
    return payload;
  }
}
