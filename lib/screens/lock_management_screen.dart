import 'package:flutter/material.dart';
import '../models/ekey.dart';
import '../models/wifi_info.dart';
import '../theme/app_colors.dart';
import '../services/bluetooth_lock_service.dart';
import '../services/wifi_lock_service.dart';
import 'package:api_app/screens/passcodes/passcodes_screen.dart';
import '../models/lock_communication_mode.dart';
import '../services/auth_manager.dart';

class LockManagementScreen extends StatefulWidget {
  final EKey keyData;

  const LockManagementScreen({
    super.key,
    required this.keyData,
  });

  @override
  State<LockManagementScreen> createState() => _LockManagementScreenState();
}

class _LockManagementScreenState extends State<LockManagementScreen> {
  bool isRefreshing = false;
  WifiInfo? wifiInfo;
  bool isLoadingWifi = true;
  bool isUnlocking = false;
  final BluetoothLockService bluetoothService = BluetoothLockService();
  final WifiLockService wifiService = WifiLockService();
  late String token;

  String lastSync = 'Hace 2 min';
  LockCommunicationMode selectedMode = LockCommunicationMode.wifi;

  Future<void> loadWifiInfo() async {
    final result = await WifiLockService().getWifiDetails(
      token,
      widget.keyData.lockInfo.lockId,
    );
    if (!mounted) return;
    setState(() {
      wifiInfo = result;
      isLoadingWifi = false;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }
  Future<void> initialize() async {
    token = await AuthManager.getToken() ?? '';
    await loadWifiInfo();
  }

  Future<void> refreshLockStatus() async {
    setState(() {
      isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isRefreshing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Estado actualizado')));
  }

  Future<void> selectBluetoothMode() async {
    final bluetoothEnabled = await bluetoothService.isBluetoothEnabled();
    if (!mounted) return;
    if (!bluetoothEnabled) {
      await showBluetoothDisabledDialog();
      return;
    }
    setState(() {
      selectedMode = LockCommunicationMode.bluetooth;
    });
  }

  Future<void> showBluetoothDisabledDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bluetooth apagado'),
          content: const Text(
            'Para utilizar este modo active Bluetooth y vuelve a intentarrlo',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> unlockBluetooth() async {
    setState(() {
      isUnlocking = true;
    });
    await bluetoothService.unlock(
      lockData: widget.keyData.lockInfo.lockData,
      onSuccess: (lockTime, electricQuantity, uniqueId, lockData) {
        if (!mounted) return;
        setState(() {
          isUnlocking = false;
        });
        print('SUCCESS');
        print('LOCK TIME => $lockTime');
        print('BATTERY => $electricQuantity');
        print('UNIQUE ID => $uniqueId');
        print('LOCK DATA => $lockData');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chapa abierta por Bluetooth')),
        );
      },
      onError: (errorCode, errorMsg) {
        if (!mounted) return;
        setState(() {
          isUnlocking = false;
        });
        print('Error code = $errorCode');
        print('Error msg = $errorMsg');

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      },
    );
  }

  Future<void> unlockSelectedMode() async {
    if (selectedMode == LockCommunicationMode.bluetooth) {
      await unlockBluetooth();
      return;
    }
    await unlockWifi();
  }

  Future<void> unlockWifi() async {
    setState(() {
      isUnlocking = true;
    });
    try {
      await WifiLockService().unlock(
        token,
        widget.keyData.lockInfo.lockId,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chapa abierta por Wifi')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Wifi: $e')));
    } finally {
      setState(() {
        isUnlocking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // APPBAR
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,

              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
              ),

              title: Row(
                children: [
                  Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMode = LockCommunicationMode.wifi;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: selectedMode == LockCommunicationMode.wifi
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.wifi_rounded,
                              size: 20,
                              color: selectedMode == LockCommunicationMode.wifi
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: selectBluetoothMode,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  selectedMode ==
                                      LockCommunicationMode.bluetooth
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.bluetooth_rounded,
                              size: 20,
                              color:
                                  selectedMode ==
                                      LockCommunicationMode.bluetooth
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              actions: [
                IconButton(
                  onPressed: isRefreshing ? null : refreshLockStatus,
                  icon: isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

                child: Column(
                  children: [
                    // CARD PRINCIPAL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          // STATUS SUPERIOR
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: (wifiInfo?.isOnline ?? false)
                                      ? Colors.green.withOpacity(0.10)
                                      : Colors.red.withOpacity(0.10),

                                  borderRadius: BorderRadius.circular(20),
                                ),

                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: (wifiInfo?.isOnline ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      (wifiInfo?.isOnline ?? false)
                                          ? 'Online'
                                          : 'Offline',

                                      style: TextStyle(
                                        color: (wifiInfo?.isOnline ?? false)
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              GestureDetector(
                                onTap: refreshLockStatus,

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),

                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.10),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.battery_full,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),

                                      const SizedBox(width: 6),

                                      Text(
                                        '${widget.keyData.lockState.electricQuantity}%',

                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ICONO LOCK
                          GestureDetector(
                            onTap: isUnlocking ? null : unlockSelectedMode,
                            child: Column(
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.25),
                                        AppColors.primary.withOpacity(0.02),
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: isUnlocking
                                        ? const CircularProgressIndicator()
                                        : Container(
                                            width: 96,
                                            height: 96,
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.lock_outline,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                          ),
                                  ),
                                ),
                                if (isUnlocking) ...[
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Desbloqueando...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            widget.keyData.lockInfo.lockAlias,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // BOTONES RAPIDOS
                          const SizedBox(height: 18),

                          // INFO
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sync_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),

                                const SizedBox(width: 6),

                                Text(
                                  lastSync,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const Spacer(),

                                const Icon(
                                  Icons.wifi_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),

                                const SizedBox(width: 6),

                                Expanded(
                                  child: Text(
                                    wifiInfo?.networkName ?? 'Sin WiFi',
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Icon(Icons.settings_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        int columns = 3;
                        if (width < 360) {
                          columns = 2;
                        }

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          crossAxisCount: columns,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 150,

                          children: [
                            buildFeatureCard(
                              icon: Icons.key_rounded,
                              title: 'eKeys',
                              subtitle: 'Usuarios',
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.pin,
                              title: 'PIN',
                              subtitle: 'Contraseñas',
                              onTap: () {
                                 Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PasscodesScreen(
                                      keyData: widget.keyData,
                                      communicationMode: selectedMode,
                                    ),
                                  ),
                                );
                              },
                            ),

                            buildFeatureCard(
                              icon: Icons.credit_card,
                              title: 'Tarjetas',
                              subtitle: 'IC Cards',
                              onTap: () {
                              },
                            ),

                            buildFeatureCard(
                              icon: Icons.qr_code_2,
                              title: 'QR',
                              subtitle: 'Accesos',
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.history,
                              title: 'Logs',
                              subtitle: 'Auditoría',
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.people_alt_rounded,
                              title: 'Usuarios',
                              subtitle: 'Permisos',
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.settings,
                              title: 'Ajustes',
                              subtitle: 'Sistema',
                              onTap: () {},
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),

        const SizedBox(width: 10),

        Text(title, style: const TextStyle(color: AppColors.textSecondary)),

        const Spacer(),

        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),

        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Icon(icon, color: AppColors.primary, size: 28),
                ),

                const SizedBox(height: 14),

                Text(
                  title,
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
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
