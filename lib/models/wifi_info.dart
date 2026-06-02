class WifiInfo {
  final String networkName;
  final String wifiMac;
  final int rssiGrade;
  final bool isOnline;
  final int powerSavingMode;

  WifiInfo({
    required this.networkName,
    required this.wifiMac,
    required this.rssiGrade,
    required this.isOnline,
    required this.powerSavingMode,
  });

  factory WifiInfo.fromJson(Map<String, dynamic> json) {
    return WifiInfo(
      networkName: json['networkName'] ?? '',
      wifiMac: json['wifiMac'] ?? '',
      rssiGrade: json['rssiGrade'] ?? 0,
      isOnline: json['isOnline'] == 1 || json['isOnline'] == true,
      powerSavingMode: json['powerSavingMode'] ?? 0,
    );
  }
}
