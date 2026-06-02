class LockState {
  final int electricQuantity;
  final bool isOnline;
  final int passageMode;

  LockState({
    required this.electricQuantity,
    required this.isOnline,
    required this.passageMode,
  });

  factory LockState.fromJson(Map<String, dynamic> json) {
    return LockState(
      electricQuantity: json['electricQuantity'] ?? 0,
      isOnline: json['isOnline'] == 1,
      passageMode: json['passageMode'] ?? 0,
    );
  }
}
