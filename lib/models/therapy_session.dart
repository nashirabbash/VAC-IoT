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

  factory TherapySession.fromJson(Map<String, dynamic> json) =>
      TherapySession(
        id: json['id'] as int?,
        sessionDate: json['sessionDate'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        mode: json['mode'] as String,
        duration: json['duration'] as String,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_date': sessionDate,
      'title': title,
      'date': date,
      'mode': mode,
      'duration': duration,
    };
  }

  factory TherapySession.fromMap(Map<String, dynamic> map) {
    return TherapySession(
      id: map['id'] as int?,
      sessionDate: map['session_date'] as String,
      title: map['title'] as String,
      date: map['date'] as String,
      mode: map['mode'] as String,
      duration: map['duration'] as String,
    );
  }
}