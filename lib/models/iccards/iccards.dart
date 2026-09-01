import 'iccard_form_data.dart';
import 'package:api_app/models/qrcodes/cyclic_config.dart';
class Iccard {
  final int cardId;
  final int lockId;
  final int cardNumber;
  String cardName;
  final int cardType;
  int startDate;
  int endDate;
  final int createDate;
  final String senderUsername;
  final List<CyclicConfig> cyclicConfig;

  Iccard({
    required this.cardId,
    required this.lockId,
    required this.cardNumber,
    required this.cardName,
    required this.cardType,
    required this.startDate,
    required this.endDate,
    required this.createDate,
    required this.senderUsername,
    required this.cyclicConfig,
  });

  factory Iccard.fromJson(Map<String, dynamic> json) {
    return Iccard(
      cardId: json['cardId'],
      lockId: json['lockId'],
      cardNumber: json['cardNumber'],
      cardName: json['cardName'],
      cardType: json['cardType'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      createDate: json['createDate'],
      senderUsername: json['senderUsername'] ?? '',
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
    return IccardFormData.typeNames[
      cardType
    ] ?? 'Desconocido';
  }
  String get formattedCreateDate {
    final date = DateTime.fromMillisecondsSinceEpoch(createDate);

    return
        '${date.day}/'
        '${date.month}/'
        '${date.year}'
        ' ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
