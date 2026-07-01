import 'package:api_app/screens/passcodes/new_passcode_screen.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/theme/app_colors.dart';
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
    required this.lockAlias,
  });
  @override
  State<PasscodesScreen> createState() => _PasscodesScreen();
}

class _PasscodesScreen extends State<PasscodesScreen> {
  final WifiPasscodeService wifiService = WifiPasscodeService();
  List<Passcode> passcodes = [];
  bool isLoading = true;
  String searchText = '';

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

  List<Passcode> get filteredPasscodes {
    if (searchText.trim().isEmpty) {
      return passcodes;
    }
    return passcodes.where((passcode) {
      final query = searchText.toLowerCase();
      return passcode.keyboardPwdName.toLowerCase().contains(query) ||
          passcode.keyboardPwd.contains(query) ||
          passcode.typeName.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Códigos de acceso'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () async {
          //Navegar a NewPasscodeScreen
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewPasscodeScreen(
                lockId: widget.lockId,
                token: widget.token,
                lockData: widget.lockData,
                communicationMode: widget.communicationMode,
              ),
            ),
          );
          if (refresh == true) {
            loadPasscodes();
          }
        },
        child: const Icon(Icons.add),
      ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Presiona + para generar uno',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),

                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },

                    decoration: InputDecoration(
                      hintText: 'Buscar código',

                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      fillColor: Colors.grey.shade100,

                      contentPadding: const EdgeInsets.symmetric(vertical: 14),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPasscodes.length,
                    itemBuilder: (context, index) {
                      final passcode = filteredPasscodes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
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
                              if (refresh == true) {
                                loadPasscodes();
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: const Icon(
                                  Icons.password,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                passcode.keyboardPwdName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(passcode.formattedStartDate),
                                    const SizedBox(height: 4),
                                    Text(
                                      passcode.typeName,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
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
                                if (refresh == true) {
                                  loadPasscodes();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
