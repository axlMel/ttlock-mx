import 'dart:async';

import 'package:api_app/models/passcode_creation_result.dart';
import 'package:ttlock_flutter/ttlock.dart';
import 'package:api_app/models/passcode.dart';

class BluetoothPasscodeService {
  Future<PasscodeCreationResult> createCustomPasscode({
    required String passcode,
    required int startDate,
    required int endDate,
    required String lockData,
  }) {
    final completer = Completer<PasscodeCreationResult>();
    TTLock.createCustomPasscode(
      passcode,
      startDate,
      endDate,
      lockData,
      () {
        completer.complete(
          PasscodeCreationResult(
            keyboardPwdId: 0,
            keyboardPwd: passcode,
          ),
        );
      },
      (error, message) {
        completer.completeError(
          Exception(message),
        );
      },
    );
    return completer.future;
  }
  Future<List<Passcode>> getAllPasscodes({
    required String lockData,
  }) {
    final completer = Completer<List<Passcode>>();

    TTLock.getAllValidPasscode(
      lockData,
      (list) {
        print('BT PASSCODES RAW: $list');
        final passcodes = list
            .map((e) => Passcode.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        completer.complete(passcodes);
      },
      (error, message) {
        completer.completeError(
          Exception(message),
        );
      },
    );

    return completer.future;
  }
}