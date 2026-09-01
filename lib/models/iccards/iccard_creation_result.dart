class IccardCreationResult {
  final int keyboardPwdId;
  final String keyboardPwd;

  IccardCreationResult({required this.keyboardPwdId, required this.keyboardPwd});

  factory IccardCreationResult.fromJson(Map<String, dynamic> json) {
    return IccardCreationResult(
      keyboardPwdId: json['keyboardPwdId'],
      keyboardPwd: json['keyboardPwd'],
    );
  }
}
