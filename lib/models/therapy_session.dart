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
  int get hashCode =>
      id.hashCode ^
      sessionDate.hashCode ^
      title.hashCode ^
      date.hashCode ^
      mode.hashCode ^
      duration.hashCode;
}
