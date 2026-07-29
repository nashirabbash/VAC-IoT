class TherapySession {
  final int? id;
  final String sessionDate;
  final String title;
  final String date;
  final String mode;
  final String duration;

  const TherapySession({
    this.id,
    required this.sessionDate,
    required this.title,
    required this.date,
    required this.mode,
    required this.duration,
  });

  /// Extracted pressure value (e.g., "125 mmHg") from title or duration.
  String get pressure {
    final match = RegExp(r'(\d+\s*mmHg)').firstMatch(title) ??
        RegExp(r'(\d+\s*mmHg)').firstMatch(duration);
    return match?.group(1) ?? '';
  }

  /// Returns parsed [DateTime] for sorting and comparison.
  DateTime get parsedDateTime {
    // 1. Try parsing ISO-8601 format directly
    try {
      final parsed = DateTime.parse(sessionDate);
      if (sessionDate.contains('T') || sessionDate.contains(':')) {
        return parsed;
      }
    } catch (_) {}

    // 2. Fallback parsing from sessionDate & display date string
    try {
      final year = sessionDate.length >= 4
          ? (int.tryParse(sessionDate.substring(0, 4)) ?? DateTime.now().year)
          : DateTime.now().year;
      final parts = date.split(',');
      final dateParts = parts[0].trim().split(RegExp(r'\s+'));
      if (dateParts.length < 2) return DateTime(year);

      final day = int.tryParse(dateParts[0]) ?? 1;
      final monthStr = dateParts[1];
      final month = _parseMonth(monthStr);

      int hour = 0;
      int minute = 0;
      if (parts.length > 1) {
        final timeParts = parts[1].trim().split(':');
        if (timeParts.length >= 2) {
          hour = int.tryParse(timeParts[0]) ?? 0;
          minute = int.tryParse(timeParts[1]) ?? 0;
        }
      }

      return DateTime(year, month, day, hour, minute);
    } catch (_) {
      return DateTime.tryParse(sessionDate) ?? DateTime(2000);
    }
  }

  static int _parseMonth(String name) {
    final m = name.toLowerCase();
    if (m.startsWith('jan')) return 1;
    if (m.startsWith('feb')) return 2;
    if (m.startsWith('mar')) return 3;
    if (m.startsWith('apr')) return 4;
    if (m.startsWith('mei') || m.startsWith('may')) return 5;
    if (m.startsWith('jun')) return 6;
    if (m.startsWith('jul')) return 7;
    if (m.startsWith('agu') || m.startsWith('aug')) return 8;
    if (m.startsWith('sep')) return 9;
    if (m.startsWith('okt') || m.startsWith('oct')) return 10;
    if (m.startsWith('nov')) return 11;
    if (m.startsWith('des') || m.startsWith('dec')) return 12;
    return 1;
  }

  factory TherapySession.fromJson(Map<String, dynamic> json) => TherapySession(
    id: json['id'] as int?,
    sessionDate: json['sessionDate'] as String,
    title: json['title'] as String,
    date: json['date'] as String,
    mode: json['mode'] as String,
    duration: json['duration'] as String,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TherapySession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sessionDate == other.sessionDate &&
          title == other.title &&
          date == other.date &&
          mode == other.mode &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(
        id,
        sessionDate,
        title,
        date,
        mode,
        duration,
      );
}
