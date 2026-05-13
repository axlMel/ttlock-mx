class EKey {
  final int keyId;
  final int lockId;
  final String lockAlias;
  final String userType;
  final int groupId;
  final String groupName;

  EKey({
    required this.keyId,
    required this.lockId,
    required this.lockAlias,
    required this.userType,
    required this.groupId,
    required this.groupName,
  });

  factory EKey.fromJson(Map<String, dynamic> json,) {

    return EKey(
      keyId: json['keyId'],
      lockId: json['lockId'],
      lockAlias: json['lockAlias'] ?? 'Sin nombre',
      userType: json['userType'] ?? '',
      groupId: json['groupId'] ?? 0,
      groupName: json['groupName'] ?? '',
    );
  }
}