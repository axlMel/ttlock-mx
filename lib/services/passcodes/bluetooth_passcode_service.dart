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
        completer.completeError(error);
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
        completer.completeError(error);
      },
    );
    return completer.future;
  }

  Future<void> changePasscode({
    required String originalPasscode,
    required String customCode,
    required int startDate,
    required int endDate,
    required String lockData,
  }){
    final completer = Completer<void>();
    TTLock.modifyPasscode(
      originalPasscode,
      customCode,
      startDate,
      endDate,
      lockData,
      (){
        completer.complete();
      },
      (error, message) {
        completer.completeError(error);
      }
    );
    return completer.future;
  }

  Future<void> deletePasscode({
    required String passcode,
    required String lockData,
  }) {
    final completer = Completer<void>();
    TTLock.deletePasscode(
      passcode,
      lockData, 
      () {
        completer.complete();
      },
      (error, message) {
        completer.completeError(error);
      },
    );
    return completer.future;
  }

  Future<void> resetAllPasscodes({
    required String lockData
  }) {
    final completer = Completer<void>();
    TTLock.resetPasscode(
      lockData, 
      (_) {
        completer.complete();
      },
      (error, message) {
        completer.completeError(error);
      }
    );
    return completer.future;
  }
  
}