class LockCapabilities {
  final String featureValue;
  final int remoteEnable;
  final int keyboardPwdVersion;

  LockCapabilities({
    required this.featureValue,
    required this.remoteEnable,
    required this.keyboardPwdVersion,
  });

  factory LockCapabilities.fromJson(Map<String, dynamic> json) {
    return LockCapabilities(
      featureValue: json['featureValue'] ?? '',
      remoteEnable: json['remoteEnable'] ?? 0,
      keyboardPwdVersion: json['keyboardPwdVersion'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'featureValue': featureValue,
      'remoteEnable': remoteEnable,
      'keyboardPwdVersion': keyboardPwdVersion,
    };
  }
}
