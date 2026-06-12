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

  Future<void> unlock({
    required String lockData,
    required TTControlLockCallback onSuccess,
    required TTFailedCallback onError,
  }) async {
    TTLock.controlLock(lockData, TTControlAction.unlock, onSuccess, onError);
  }
}
