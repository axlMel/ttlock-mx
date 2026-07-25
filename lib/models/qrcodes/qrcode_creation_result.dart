class QrcodeCreationResult {
  final int qrCodeId;
  final int qrCodeNumber;
  final String link;

  QrcodeCreationResult({
    required this.qrCodeId,
    required this.qrCodeNumber,
    required this.link,
  });

  factory QrcodeCreationResult.fromJson(Map<String, dynamic> json) {
    return QrcodeCreationResult(
      qrCodeId: json['qrCodeId'],
      qrCodeNumber: json['qrCodeNumber'],
      link: json['link']
    );
  }
}
