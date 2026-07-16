import 'package:ttlock_flutter/ttlock.dart';

class ErrorHelper {

  static const Map<String, String> _errors = {

    // Generales
    '1':'Operación fallida',
    '10000':'El clientId no existe',
    '10001':'Cliente inválido',
    '10003':'El token no existe',
    '10004':'El token es inválido o fue revocado',
    '10007':'Usuario o contraseña inválidos',
    '10011':'Refresh token inválido',
    '20002':'No tienes permisos de administrador',
    '30002':'Nombre inválido. Solo se permiten letras y números',
    '30003':'El usuario ya existe',
    '30004':'Usuario inválido para eliminar',
    '30005':'La contraseña debe estar en formato MD5',
    '30006':'Se excedió el límite de llamadas a la API',
    '80000':'La fecha debe ser actual (máximo 5 minutos)',
    '80002':'Formato JSON inválido',
    '90000':'Error interno del servidor',
    '-3':'Parámetro inválido',

    '-2018':'Permisos insuficientes',

    // Lock
    '-1003':'La cerradura no existe',
    '-2025':'La cerradura está congelada',
    '-3011':'No puedes transferir la cerradura a tu propia cuenta',
    '-4043':'Esta función no es compatible con esta cerradura',
    '-4056':'La memoria de la cerradura está llena',
    '-4067':'El dispositivo NB no está registrado',
    '-4082':'Periodo de bloqueo automático inválido',

    // eKey
    '-1008':'La eKey no existe',
    '-1016':'Ya existe un nombre idéntico',
    '-1018':'El grupo no existe',
    '-1027':'No puedes enviar una eKey a una cuenta vinculada',
    '-2019':'No puedes enviarte una eKey a ti mismo',
    '-2020':'No puedes enviar una eKey al administrador',
    '-2023':'No es posible cambiar el periodo actualmente',
    '-4064':'La eKey solo puede enviarse a cuentas registradas',

    // Passcodes
    '-1007':'No existen códigos para esta cerradura',
    '-2009':'Código inválido',
    '-3006':'El código debe contener entre 6 y 9 dígitos',
    '-3007':'Ese código ya existe. Usa otro',
    '-3008':'Un código no utilizado no puede modificarse',
    '-3009':'No hay espacio disponible para más códigos personalizados',

    // Wifi / Gateway
    '-2012':'La cerradura no está conectada a un Gateway',
    '-3002':'El Gateway está fuera de línea',
    '-3003':'El Gateway está ocupado',
    '-3016':'No puedes transferir el Gateway a tu propia cuenta',
    '-3034':'La red no está configurada',
    '-3035':'La cerradura está en modo ahorro de energía',
    '-3036':'La cerradura está fuera de línea',
    '-3037':'La cerradura está ocupada',
    '-4037':'El Gateway no existe',

    // Tarjetas y huellas
    '-1021':'La tarjeta IC no existe',
    '-1023':'La huella digital no existe',
  };
  static const Map<TTLockError, String> _bluetoothErrors = {

    TTLockError.bluetoothOff:
        'Activa el Bluetooth para continuar.',
    TTLockError.bluetoothConnectTimeout:
        'No fue posible conectar con la cerradura.',
    TTLockError.bluetoothDisconnection:
        'Se perdió la conexión Bluetooth.',
    TTLockError.lockIsBusy:
        'La cerradura está ocupada.',
    TTLockError.invalidLockData:
        'La información de la cerradura es inválida.',
    TTLockError.invalidParameter:
        'Los datos enviados son inválidos.',
    TTLockError.passcodeExist:
        'Ese código ya existe.',
    TTLockError.passcodeNotExist:
        'Ese código no existe.',
    TTLockError.lackOfStorageSpaceWhenAddingPasscode:
        'La memoria de la cerradura está llena.',
  };
  static String parse(dynamic error) {

    if (error is TTLockError) {
      return _bluetoothErrors[error] ??
          'Ocurrió un error Bluetooth.';
    }

    final message = error.toString().replaceFirst(
        'Exception: ',
        '',
      );
    final regex = RegExp(r'\((-?\d+)\)');
    final match = regex.firstMatch(message);
    if (match != null) {
      final code = match.group(1);
      if (_errors.containsKey(code)) {
        return _errors[code]!;
      }
    }
    return message;
  }
}