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
}