class PasscodesFormData {
  bool isCustom;
  int type;
  String name;
  String? customCode;
  DateTime startDate;
  DateTime? endDate;
  PasscodesFormData({
    required this.isCustom,
    required this.type,
    required this.name,
    this.customCode,
    required this.startDate,
    this.endDate,
  });
}