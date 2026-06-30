import 'package:api_app/screens/passcodes/new_passcode_screen.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:flutter/material.dart';
import '../../models/lock_communication_mode.dart';
import 'package:api_app/models/passcode.dart';
import 'package:api_app/screens/passcodes/passcode_detail_screen.dart';

class PasscodesScreen extends StatefulWidget {
  final int lockId;
  final String token;
  final String lockData;
  final String lockAlias;
  final LockCommunicationMode communicationMode;
  const PasscodesScreen({
    super.key,
    required this.lockId,
    required this.token,
    required this.lockData,
    required this.communicationMode,
    required this.lockAlias
  });
  @override
  State<PasscodesScreen> createState() => _PasscodesScreen();
}

class _PasscodesScreen extends State<PasscodesScreen> {
  final WifiPasscodeService wifiService = WifiPasscodeService();
  List<Passcode> passcodes = [];
  bool isLoading = true;

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
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Codigos de Acceso')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
        //Navegar a NewPasscodeScreen
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewPasscodeScreen(
              lockId: widget.lockId, 
              token: widget.token, 
              lockData: widget.lockData, 
              communicationMode: widget.communicationMode
            )
          )
        );
        if (refresh == true) {
          loadPasscodes();
        }
      },
      child: const Icon(Icons.add)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : passcodes.isEmpty 
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pin_outlined,
                  size: 70,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No existen códigos aún',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona + para generar uno',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                )
              ],
            ),
          )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: passcodes.length,
          itemBuilder: (context, index) {
            final passcode = passcodes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  child: Icon(Icons.password),
                ),
                title: Text(
                  passcode.keyboardPwdName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(passcode.keyboardPwd),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
                onTap: () async {
                  //Abrir detalles
                  final refresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PasscodeDetailScreen(
                        passcode: passcode,
                        token: widget.token,
                        lockId: widget.lockId,
                        lockAlias: widget.lockAlias,
                      ),
                    ),
                  );
                  if(refresh==true){
                    loadPasscodes();
                  }
                },
              ),
            );
          },
        ),
    );
  }
}
