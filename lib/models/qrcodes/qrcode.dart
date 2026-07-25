import 'qrcode_form_data.dart';
import 'cyclic_config.dart';
class Qrcode {
  final int qrCodeId;
  final int lockId;
  final int type;
  final int qrCodeNumber;
  String name;
  int startDate;
  int endDate;
  final int refreshTime;
  final int createDate;
  final int status;
  final String creator;
  final String link;
  final int qrCodeVersion;
  final List<CyclicConfig> cyclicConfig;

  Qrcode({
    required this.qrCodeId,
    required this.lockId,
    required this.type,
    required this.qrCodeNumber,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.refreshTime,
    required this.createDate,
    required this.status,
    required this.creator,
    required this.link,
    required this.qrCodeVersion,
    required this.cyclicConfig,
  });

  factory Qrcode.fromJson(Map<String, dynamic> json) {
    return Qrcode(
      qrCodeId: json['qrCodeId'],
      lockId: json['lockId'],
      type: json['type'],
      qrCodeNumber: json['qrCodeNumber'],
      name: json['name'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      refreshTime: json['refreshTime'] ?? 0,
      createDate: json['createDate'],
      status: json['status'],
      creator: json['creator'] ?? '',
      link: json['link'] ?? '',
      qrCodeVersion: json['qrCodeVersion'] ?? 1,
      cyclicConfig:
          (json['cyclicConfig'] as List<dynamic>?)
              ?.map((e) => CyclicConfig.fromJson(e))
              .toList() ??
          [],
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
    String get typeName {
    return QrcodeFormData.typeNames[
      type
    ] ?? 'Desconocido';
  }
}
