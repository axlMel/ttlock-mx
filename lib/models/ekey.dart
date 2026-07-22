import 'lock_info.dart';
import 'lock_state.dart';
import 'lock_capabilities.dart';

class EKey {
  final int keyId;
  final String userType;
  final int? groupId;
  final String groupName;
  final LockInfo lockInfo;
  final LockState lockState;
  final LockCapabilities capabilities;

  EKey({
    required this.keyId,
    required this.userType,
    required this.groupId,
    required this.groupName,
    required this.lockInfo,
    required this.lockState,
    required this.capabilities,
  });

  factory EKey.fromJson(Map<String, dynamic> json) {
    return EKey(
      keyId: json['keyId'],
      userType: json['userType'] ?? '',
      groupId: json['groupId'] ?? 0,
      groupName: json['groupName'] ?? '',
      lockInfo: LockInfo.fromJson(json),
      lockState: LockState.fromJson(json),
      capabilities: LockCapabilities.fromJson(json),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'keyId': keyId,
      'userType': userType,
      'groupId': groupId,
      'groupName': groupName,

      ...lockInfo.toJson(),
      ...lockState.toJson(),
      ...capabilities.toJson(),
    };
  }
}
