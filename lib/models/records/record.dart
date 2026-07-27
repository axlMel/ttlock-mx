import 'package:flutter/material.dart';
class Record {
  final int recordId;
  final int lockId;
  final int recordTypeFromLock;
  final int recordType;
  final bool success;
  final String username;
  final String? keyboardPwd;
  final int lockDate;
  final int serverDate;
  final int? subRecordType;

  Record({
    required this.recordId,
    required this.lockId,
    required this.recordTypeFromLock,
    required this.recordType,
    required this.success,
    required this.username,
    this.keyboardPwd,
    required this.lockDate,
    required this.serverDate,
    this.subRecordType,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      recordId: json['recordId'] ?? 0,
      lockId: json['lockId'] ?? 0,
      recordTypeFromLock: json['recordTypeFromLock'] ?? 0,
      recordType: json['recordType'] ?? 0,
      success: (json['success'] ?? 0) == 1,
      username: json['username'] ?? '',
      keyboardPwd: json['keyboardPwd'],
      lockDate: json['lockDate'] ?? 0,
      serverDate: json['serverDate'] ?? 0,
      subRecordType: json['subRecordType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordId': recordId,
      'lockId': lockId,
      'recordTypeFromLock': recordTypeFromLock,
      'recordType': recordType,
      'success': success ? 1 : 0,
      'username': username,
      'keyboardPwd': keyboardPwd,
      'lockDate': lockDate,
      'serverDate': serverDate,
      'subRecordType': subRecordType,
    };
  }
  DateTime get lockDateTime {
    return DateTime.fromMillisecondsSinceEpoch(lockDate);
  }
  DateTime get serverDateTime {
    return DateTime.fromMillisecondsSinceEpoch(serverDate);
  }
  String get formattedLockDate {
    final date = lockDateTime;
    return
        '${date.day}/'
        '${date.month}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
  String get formattedServerDate {
    final date = serverDateTime;

    return
        '${date.day}/'
        '${date.month}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
  String get recordTypeName {
    switch (recordType) {
      case 1:
        return 'Desbloqueo';
      case 4:
        return 'PIN';
      case 7:
        return 'Tarjeta';
      case 8:
        return 'Huella';
      case 55:
        return 'Remoto';
      default:
        return 'Otro';
    }
  }
  IconData get icon {
    switch (recordType) {
      case 1:
        return Icons.lock_open;
      case 4:
        return Icons.pin;
      case 7:
        return Icons.credit_card;
      case 8:
        return Icons.fingerprint;
      case 55:
        return Icons.wifi;
      default:
        return Icons.history;
    }
  }
}