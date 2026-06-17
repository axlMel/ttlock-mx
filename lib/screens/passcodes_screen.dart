import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:flutter/material.dart';
import '../models/lock_communication_mode.dart';
import 'package:api_app/models/passcode.dart';

class PasscodesScreen extends StatefulWidget {
  final int lockId;
  final String token;
  final String lockData;
  final LockCommunicationMode communicationMode;
  const PasscodesScreen({
    super.key,
    required this.lockId,
    required this.token,
    required this.lockData,
    required this.communicationMode,
  });
  @override
  State<PasscodesScreen> createState() => _PasscodesScreen();
}

class _PasscodesScreen extends State<PasscodesScreen> {
  final WifiPasscodeService wifiService = WifiPasscodeService();
  List<Passcode> passcodes = [];
  bool isloading = true;

  @override
  void initState() {
    super.initState();
    loadPasscodes();
  }

  Future<void> loadPasscodes() async {
    if (widget.communicationMode == LockCommunicationMode.wifi) {
      passcodes = await wifiService.getAllPasscodes(
        widget.token,
        widget.lockId,
      );
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Codigos de Acceso')),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: passcodes.length,
              itemBuilder: (context, index) {
                final passcode = passcodes[index];
                return ListTile(
                  title: Text(passcode.keyboardPwdName),
                  subtitle: Text(passcode.keyboardPwd),
                );
              },
            ),
    );
  }
}
