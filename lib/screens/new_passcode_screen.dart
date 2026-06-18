import 'package:flutter/material.dart';
import 'package:api_app/models/lock_communication_mode.dart';

class NewPasscodeScreen extends StatelessWidget {
  final int lockId;
  final String token;
  final String lockData;
  final LockCommunicationMode communicationMode;

  const NewPasscodeScreen({super.key, required this.lockId, required this.token, required this.lockData, required this.communicationMode});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo código'),
      ),
      body: const Center(
        child: Text(
          'Pantalla en construcción'
        ),
      )
    );
  }
  
}