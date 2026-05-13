class Lock {
  final int lockId;
  final String lockName;
  final int groupId;

  Lock({
    required this.lockId,
    required this.lockName,
    required this.groupId,
  });

  factory Lock.fromJson(Map<String, dynamic> json){
    return Lock(
      lockId: json['lockId'],
      lockName: json['lockAlias'] ?? json['lockName'],
      groupId: json['groupId'],
    );
  }
}