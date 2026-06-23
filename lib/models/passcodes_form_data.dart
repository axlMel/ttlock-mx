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

  static const Map<int,String> typeNames = {

    1:'Una vez',
    2:'Permanente',
    3:'Periodo',
    5:'Fin de semana',
    6:'Diario',
    7:'Días laborales',
    8:'Lunes',
    9:'Martes',
    10:'Miércoles',
    11:'Jueves',
    12:'Viernes',
    13:'Sábado',
    14:'Domingo',

  };

  String get typeDescription {

    switch(type){

      case 1:
        return 'Este código expira 6 horas después de su creación si no se utiliza';

      case 2:
        return 'Seleccione desde que día será válido, debe utilizarse dentro de las primeras 24 horas';

      case 3:
        return 'Especifique el rango de periodo válido, debe utilizarse dentro de las primeras 24 horas';

      case 5:
        return 'Este código funciona durante fines de semana comenzando por el sábado';

      case 6:
        return 'Este código funciona diariamente, por favor especifique horarios';

      case 7:
        return 'Funciona únicamente en días laborales, por favor especifique horarios';

      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
        return 'Funciona únicamente el día seleccionado';

      default:
        return '';
    }
  }

  bool get requiresEndDate {
    return type != 1 && type != 2;
  }

  bool get requiresCustomCode {
    return isCustom;
  }

}