import 'package:api_app/screens/passcodes/new_passcode_screen.dart';
import 'package:api_app/services/passcodes/bluetooth_passcode_service.dart';
import 'package:api_app/services/passcodes/wifi_passcode_service.dart';
import 'package:api_app/theme/app_colors.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';
import '../../models/lock_communication_mode.dart';
import 'package:api_app/models/passcode.dart';
import 'package:api_app/screens/passcodes/passcode_detail_screen.dart';
import 'package:api_app/helpers/error_helper.dart';
import 'package:api_app/models/ekey.dart';
import 'package:api_app/screens/passcodes/created_passcode_screen.dart';
import 'package:api_app/models/passcode_creation_result.dart';
import 'package:api_app/services/auth_manager.dart';

class PasscodesScreen extends StatefulWidget {
  final EKey keyData;
  final LockCommunicationMode communicationMode;
  const PasscodesScreen({
    super.key,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<PasscodesScreen> createState() => _PasscodesScreen();
}

class _PasscodesScreen extends State<PasscodesScreen> {
  final WifiPasscodeService wifiService = WifiPasscodeService();
  final BluetoothPasscodeService bluetoothService = BluetoothPasscodeService();
  List<Passcode> passcodes = [];
  bool isLoading = true;
  bool isRestarting = false;
  String searchText = '';
  late String token;

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';
    await loadPasscodes();
  }

  Future<void> loadPasscodes() async {
    try {
      if (widget.communicationMode == LockCommunicationMode.wifi) {
        passcodes = await wifiService.getAllPasscodes(
          token,
          widget.keyData.lockInfo.lockId,
        );
      } else {
        passcodes = await bluetoothService.getAllPasscodes(
          lockData: widget.keyData.lockInfo.lockData,
        );
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
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

  Future<void> deleteAllPasscodes() async {
    late PasscodeCreationResult result;
    final confirm = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Restablecer códigos'),
          content: const Text("Esta acción eliminará todos los códigos\n ¿Desea continuar?"),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context, false);},
              child: const Text('Cancelar')
            ),
            FilledButton(
              onPressed: () { Navigator.pop(context, true);},
              child: const Text('Aceptar')
            )
          ],
        );
      }
    );
    if (confirm != true) {
      return;
    }
    setState(() {
      isRestarting = true;
    });
    try {
      if (widget.communicationMode == LockCommunicationMode.bluetooth) {
        final newlockData = await bluetoothService.resetAllPasscodes(
          lockData: widget.keyData.lockInfo.lockData
        );
        widget.keyData.lockInfo.lockData = newlockData;
      } else {
        final now = DateTime.now();
        result = await wifiService.getRandomPasscode(
          token,
          widget.keyData.lockInfo.lockId,
          4,
          'Eliminar todos',
          now.millisecondsSinceEpoch,
          now.add(const Duration(days: 1)).millisecondsSinceEpoch,
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreatedPasscodeScreen(
              result: result,
              startDate: now,
              endDate: now.add(const Duration(days: 1)),
              keyData: widget.keyData,
              passcodeType: 4,
            ),
          ),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Codigos eliminados')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ErrorHelper.parse(e))));
    }
    finally{
      if(mounted){
        setState(() {
          isRestarting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isRestarting,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                deleteAllPasscodes();
              },
              icon: const Icon(
                Icons.restore,
              ),
            ),

            const SizedBox(width: 8),
          ],

          titleSpacing: 0,

          title: Container(
            height: 42,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),

            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText=value.toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText:'Buscar código...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                ),

                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),

                border: InputBorder.none,

                contentPadding:
                    const EdgeInsets.symmetric(
                      vertical:10,
                    ),
              ),
            ),
          ),
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
                  keyData: widget.keyData,
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredPasscodes.length,
                      itemBuilder: (context, index) {
                        final passcode = filteredPasscodes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
                                      keyData: widget.keyData,
                                      communicationMode: widget.communicationMode,
                                    ),
                                  ),
                                );
                                if (refresh == true) {
                                  loadPasscodes();
                                }
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 4,
                                ),

                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary,

                                  child: const Icon(
                                    Icons.password,
                                    color: Colors.white,
                                  ),
                                ),

                                title: Text(
                                  passcode.keyboardPwdName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),

                                subtitle: Padding(
                                  padding: const EdgeInsets.only(
                                    top: 6,
                                  ),

                                  child: Row(
                                    children: [

                                      Text(
                                        passcode.formattedStartDate,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(width:12),

                                      Expanded(
                                        child: Text(
                                          passcode.typeName,
                                          overflow: TextOverflow.ellipsis,

                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize:13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size:18,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      )
    );
  }
}
