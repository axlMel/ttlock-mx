import 'cyclic_config.dart';
class QrcodeFormData {

  int type;
  String name;
  DateTime startDate;
  DateTime? endDate;
  int refreshTime;
  int addType;
  List<CyclicConfig> cyclicConfig;

  QrcodeFormData({
    required this.type,
    required this.name,
    required this.startDate,
    this.endDate,
    this.refreshTime = 10,
    this.addType = 0,
    List<CyclicConfig>? cyclicConfig,
  }) : cyclicConfig = cyclicConfig ?? <CyclicConfig>[];

  static const Map<int,String> typeNames = {
    1:'Periódico',
    2:'Permanente',
    4:'Cíclico',
  };

  String get typeName =>
      typeNames[type] ?? 'Desconocido';

  String get typeDescription {

    switch(type){

      case 1:
        return 'El código será válido únicamente durante el periodo indicado.';

      case 2:
        return 'El código permanecerá activo hasta ser eliminado.';

      case 4:
        return 'El código será válido únicamente en los días y horarios configurados.';

      default:
        return '';
    }
  }

  bool get requiresEndDate => type == 1 || type == 4;

  bool get requiresCyclicConfig => type == 4;
}