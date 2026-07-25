class CyclicConfig {
  final int weekDay;
  final int startTime;
  final int endTime;

  CyclicConfig({
    required this.weekDay,
    required this.startTime,
    required this.endTime,
  });

  factory CyclicConfig.fromJson(Map<String, dynamic> json) {
    return CyclicConfig(
      weekDay: json['weekDay'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekDay': weekDay,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}