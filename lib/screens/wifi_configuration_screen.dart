import 'package:flutter/material.dart';
import '../models/ekey.dart';
import '../theme/app_colors.dart';
import 'package:api_app/services/bluetooth_lock_service.dart';
import 'package:api_app/helpers/error_helper.dart';

class WifiConfigurationScreen extends StatefulWidget {
  final EKey keyData;
  const WifiConfigurationScreen({
    super.key,
    required this.keyData,
  });
  @override
  State<WifiConfigurationScreen> createState() =>
      _WifiConfigurationScreenState();
}

class _WifiConfigurationScreenState extends State<WifiConfigurationScreen> {

  final TextEditingController passwordController = TextEditingController();
  final BluetoothLockService bluetoothService = BluetoothLockService();
  bool isScanning = true;
  bool isConnecting = false;
  List<Map<String, dynamic>> wifiNetworks = [];
  Map<String, dynamic>? selectedWifi;

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    try {
      final enabled = await bluetoothService.isBluetoothEnabled();

      if (!enabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Active Bluetooth para continuar.'),
          ),
        );

        Navigator.pop(context);
        return;
      }

      await scanWifi();

    } catch (e) {
      if (!mounted) return;

      setState(() {
        isScanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
    }
  }
  Future<void> scanWifi() async {
    setState(() {
      isScanning = true;
      wifiNetworks.clear();
      selectedWifi = null;
    });
    try {
      final wifiList = await bluetoothService.scanWifi(
        lockData: widget.keyData.lockInfo.lockData,
      );
      if (!mounted) return;
      setState(() {
        wifiNetworks = wifiList;
        isScanning = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
    }
  }

  Future<void> connectWifi() async {
    if (selectedWifi == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione una red WiFi.'),
        ),
      );
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese la contraseña del WiFi.'),
        ),
      );
      return;
    }
    setState(() {
      isConnecting = true;
    });
    try {
      await bluetoothService.configWifi(
        wifiName: selectedWifi!['wifi'],
        wifiPassword: passwordController.text.trim(),
        lockData: widget.keyData.lockInfo.lockData,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WiFi configurado correctamente.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.parse(e)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isConnecting = false;
        });
      }
    }
  }

  InputDecoration buildInput(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Configurar WiFi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const Icon(
                  Icons.wifi,
                  color: AppColors.primary,
                  size: 42,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Configurar WiFi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Seleccione una red inalámbrica para conectar la cerradura.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 28),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Redes disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: isScanning
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : wifiNetworks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 42,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No fue posible obtener las redes WiFi.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 18),
                                FilledButton.icon(
                                  onPressed: scanWifi,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: wifiNetworks.length,
                            itemBuilder: (context, index) {
                              final wifi = wifiNetworks[index];

                              return ListTile(
                                leading: const Icon(Icons.wifi),
                                title: Text(wifi['wifi'] ?? ''),
                                subtitle: Text('${wifi['rssi']} dBm'),
                                trailing: selectedWifi == wifi
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primary,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    selectedWifi = wifi;
                                  });
                                },
                              );
                            },
                          ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: buildInput('Contraseña'),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (!isConnecting) {
                      connectWifi();
                    }
                  },
                  icon: const Icon(Icons.wifi),
                  label: Text(
                    isConnecting ? 'Conectando...' : 'Conectar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}