import 'dart:async';
import 'package:ttlock_flutter/ttlock.dart';

class BluetoothLockService {
  Future<TTBluetoothState> getBluetoothState() async {
    final completer = Completer<TTBluetoothState>();
    TTLock.getBluetoothState((state) {
      completer.complete(state);
    });
    return completer.future;
  }

  Future<bool> isBluetoothEnabled() async {
    final state = await getBluetoothState();
    return state == TTBluetoothState.turnOn;
  }

  Future<Map<String, dynamic>> unlock({
    required String lockData,
  }) {
    final completer = Completer<Map<String, dynamic>>();

    TTLock.controlLock(
      lockData,
      TTControlAction.unlock,
      (
        int lockTime,
        int electricQuantity,
        int uniqueId,
        String newLockData,
      ) {
        completer.complete({
          'electricQuantity': electricQuantity,
          'lockData': newLockData,
        });
      },
      (error, message) {
        completer.completeError(error);
      },
    );

    return completer.future;
  }

  Future<List<Map<String, dynamic>>> scanWifi({
    required String lockData,
  }) {
    final completer = Completer<List<Map<String, dynamic>>>();
    List<Map<String, dynamic>> scannedWifi = [];
    TTLock.scanWifi(
      lockData,
      (bool finished, List wifiList) {
        scannedWifi = List<Map<String, dynamic>>.from(
          wifiList.map((e) => Map<String, dynamic>.from(e)),
        );

        if (finished && !completer.isCompleted) {
          completer.complete(scannedWifi);
        }
      },
      (error, message) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 120),
      onTimeout: () {
        throw Exception('No fue posible conectar con la cerradura');
      },
    );
  }

  Future<void> configWifi({
    required String wifiName,
    required String wifiPassword,
    required String lockData,
  }) {
    final completer = Completer<void>();
    TTLock.configWifi(
      wifiName,
      wifiPassword,
      lockData,
      () {
        completer.complete();
      },
      (error, message) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future;
  }

  Future<TTWifiInfoModel> getWifiInfo({
    required String lockData,
  }) {
    final completer = Completer<TTWifiInfoModel>();
    TTLock.getWifiInfo(
      lockData,
      (TTWifiInfoModel wifiInfo) {
        if (!completer.isCompleted) {
          completer.complete(wifiInfo);
        }
      },
      (error, message) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future;
  }
}
