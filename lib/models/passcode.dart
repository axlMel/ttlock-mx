import 'package:api_app/models/passcodes_form_data.dart';
class Passcode {
  final int keyboardPwdId;
  final int lockId;
  String keyboardPwd;
  String keyboardPwdName;
  final int keyboardPwdType;
  int startDate;
  int endDate;
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

  DateTime get startDateTime {
    return DateTime.fromMillisecondsSinceEpoch(
      startDate,
    );
  }

  DateTime? get endDateTime {

    if(endDate==0){
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      endDate,
    );
  }

  String get typeName {
    return PasscodesFormData.typeNames[
      keyboardPwdType
    ] ?? 'Desconocido';
  }

  String get formattedStartDate {

    final date=startDateTime;

    return
      '${date.day}/'
      '${date.month}/'
      '${date.year}'
      ' ${date.hour.toString().padLeft(2,'0')}:'
      '${date.minute.toString().padLeft(2,'0')}';
  }

  String get formattedEndDate {

    if(endDateTime==null){
      return 'Sin fecha límite';
    }

    final date=endDateTime!;

    return
      '${date.day}/'
      '${date.month}/'
      '${date.year}'
      ' ${date.hour.toString().padLeft(2,'0')}:'
      '${date.minute.toString().padLeft(2,'0')}';
  }

}
