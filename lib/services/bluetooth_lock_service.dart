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
}
