class LockInfo {
  final int lockId;
  final String lockAlias;
  final String lockMac;
  final String lockName;
  String lockData;

  LockInfo({
    required this.lockId,
    required this.lockAlias,
    required this.lockMac,
    required this.lockName,
    required this.lockData,
  });

  factory LockInfo.fromJson(Map<String, dynamic> json) {
    return LockInfo(
      lockId: json['lockId'],
      lockAlias: json['lockAlias'] ?? 'Sin nombre',
      lockMac: json['lockMac'] ?? '',
      lockName: json['lockName'] ?? '',
      lockData: json['lockData'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'lockId': lockId,
      'lockAlias': lockAlias,
      'lockMac': lockMac,
      'lockName': lockName,
      'lockData': lockData,
    };
  }
}
