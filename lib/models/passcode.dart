class Passcode {
  final int keyboardPwdId;
  final int lockId;
  final String keyboardPwd;
  final String keyboardPwdName;
  final int keyboardPwdType;
  final int startDate;
  final int endDate;
  final int sendDate;
  final int isCustom;
  final String senderUsername;

  Passcode({
    required this.keyboardPwdId,
    required this.lockId,
    required this.keyboardPwd,
    required this.keyboardPwdName,
    required this.keyboardPwdType,
    required this.startDate,
    required this.endDate,
    required this.sendDate,
    required this.isCustom,
    required this.senderUsername,
  });

  factory Passcode.fromJson(Map<String, dynamic> json) {
    return Passcode(
      keyboardPwdId: json['keyboardPwdId'],
      lockId: json['lockId'],
      keyboardPwd: json['keyboardPwd'],
      keyboardPwdName: json['keyboardPwdName'],
      keyboardPwdType: json['keyboardPwdType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      sendDate: json['sendDate'],
      isCustom: json['isCustom'] ?? 0,
      senderUsername: json['senderUsername'] ?? '',
    );
  }
}
