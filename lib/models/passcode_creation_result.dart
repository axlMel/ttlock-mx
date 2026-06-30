class PasscodeCreationResult {
  final int keyboardPwdId;
  final String keyboardPwd;

  PasscodeCreationResult({required this.keyboardPwdId, required this.keyboardPwd});

  factory PasscodeCreationResult.fromJson(Map<String, dynamic> json) {
    return PasscodeCreationResult(
      keyboardPwdId: json['keyboardPwdId'],
      keyboardPwd: json['keyboardPwd'],
    );
  }
}
