class EKey {
  final int keyId;
  final int lockId;
  final String lockAlias;
  final String lockData;
  final int electricQuantity;
  final String userType;
  final int? groupId;
  final String groupName;

  EKey({
    required this.keyId,
    required this.lockId,
    required this.lockAlias,
    required this.lockData,
    required this.electricQuantity,
    required this.userType,
    required this.groupId,
    required this.groupName,
  });

  factory EKey.fromJson(Map<String, dynamic> json,) {

    return EKey(
      keyId: json['keyId'],
      lockId: json['lockId'],
      lockAlias: json['lockAlias'] ?? 'Sin nombre',
      lockData: json['lockData'],
      electricQuantity: json['electricQuantity'],
      userType: json['userType'] ?? '',
      groupId: json['groupId'],
      groupName: json['groupName'] ?? '',
    );
  }
}
