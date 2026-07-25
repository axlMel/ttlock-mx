import 'package:api_app/models/ekey.dart';
import 'package:api_app/models/lock_communication_mode.dart';
import 'package:api_app/models/qrcodes/qrcode.dart';

import 'package:api_app/screens/qrcodes/qrcode_detail_screen.dart';
import 'package:api_app/screens/qrcodes/new_qrcode_screen.dart';

import 'package:api_app/services/qrcodes/wifi_qrcode_service.dart';
import 'package:api_app/services/auth_manager.dart';

import 'package:api_app/theme/app_colors.dart';
import 'package:api_app/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';



import 'package:api_app/helpers/error_helper.dart';



class QrcodesScreen extends StatefulWidget {
  final EKey keyData;
  final LockCommunicationMode communicationMode;
  const QrcodesScreen({
    super.key,
    required this.keyData,
    required this.communicationMode,
  });
  @override
  State<QrcodesScreen> createState() => _QrcodesScreen();
}

class _QrcodesScreen extends State<QrcodesScreen> {
  final WifiQrcodeService wifiService = WifiQrcodeService();
  List<Qrcode> qrcodes = [];
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
    await loadQrcodes();
  }

  Future<void> loadQrcodes() async {
    try {
      if (widget.communicationMode == LockCommunicationMode.wifi) {
        qrcodes = await wifiService.getAllQrcodes(
          token,
          widget.keyData.lockInfo.lockId,
        );
      } else {
        // espacio para servicio BT
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

  List<Qrcode> get filteredQrcodes {
    if (searchText.trim().isEmpty) {
      return qrcodes;
    }
    return qrcodes.where((qrcode) {
      final query = searchText.toLowerCase();
      return qrcode.name.toLowerCase().contains(query) ||
          qrcode.creator.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> deleteAllQrcodes() async {
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
        // espacio reservado para servicio BT
      } else {
        await wifiService.deleteAllQrcodes(
          token,
          widget.keyData.lockInfo.lockId,
        );
        if (!mounted) return;
      }
      if (!mounted) return;
      await loadQrcodes();
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
              onPressed: qrcodes.isEmpty ? null : deleteAllQrcodes,
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
            //Navegar a NewQrcodeScreen
            final refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewQrcodeScreen(
                  keyData: widget.keyData,
                  communicationMode: widget.communicationMode,
                ),
              ),
            );
            if (refresh == true) {
              loadQrcodes();
            }
          },
          child: const Icon(Icons.add),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : qrcodes.isEmpty
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
                      'No existen códigos QR aún',
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
                      itemCount: filteredQrcodes.length,
                      itemBuilder: (context, index) {
                        final qrcode = filteredQrcodes[index];
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
                                    builder: (_) => QrcodeDetailScreen(
                                      qrcode: qrcode,
                                      keyData: widget.keyData,
                                      communicationMode: widget.communicationMode,
                                    ),
                                  ),
                                );
                                if (refresh == true) {
                                  loadQrcodes();
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
                                    Icons.qr_code_2,
                                    color: Colors.white,
                                  ),
                                ),

                                title: Text(
                                  qrcode.name,
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
                                        qrcode.formattedStartDate,
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13,
                                        ),
                                      ),

                                      const SizedBox(width:12),

                                      Expanded(
                                        child: Text(
                                          qrcode.typeName,
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
