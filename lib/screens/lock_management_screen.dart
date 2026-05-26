import 'package:flutter/material.dart';
import '../models/ekey.dart';
import '../theme/app_colors.dart';

class LockManagementScreen extends StatefulWidget {
  final EKey keyData;

  const LockManagementScreen({super.key, required this.keyData});

  @override
  State<LockManagementScreen> createState() => _LockManagementScreenState();
}

class _LockManagementScreenState extends State<LockManagementScreen> {
  bool isOnline = true;
  bool isRefreshing = false;

  String wifiName = 'GT-CEDIS-5G';
  String firmware = 'v2.4.8';
  String lastSync = 'Hace 2 min';

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

              title: const Text(
                'TTLock',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: isOnline
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
                                        color: isOnline
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Text(
                                      isOnline ? 'Online' : 'Offline',

                                      style: TextStyle(
                                        color: isOnline
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
                                    horizontal: 12,
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
                                        '${widget.keyData.electricQuantity}%',

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

                          const SizedBox(height: 26),

                          // ICONO LOCK
                          Container(
                            width: 130,
                            height: 130,

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
                              child: Container(
                                width: 82,
                                height: 82,

                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),

                                child: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          Text(
                            widget.keyData.lockAlias,
                            textAlign: TextAlign.center,

                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'ID ${widget.keyData.lockId}',

                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // BOTONES RAPIDOS
                          Row(
                            children: [
                              Expanded(
                                child: buildPrimaryAction(
                                  icon: Icons.lock_open_rounded,
                                  title: 'Desbloquear',
                                  color: Colors.green,
                                  onTap: () {},
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: buildPrimaryAction(
                                  icon: Icons.wifi_rounded,
                                  title: wifiName,
                                  color: AppColors.primary,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // INFO
                          buildInfoRow(
                            icon: Icons.sync,
                            title: 'Última sincronización',
                            value: lastSync,
                          ),

                          const SizedBox(height: 12),

                          buildInfoRow(
                            icon: Icons.memory_rounded,
                            title: 'Firmware',
                            value: firmware,
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
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.credit_card,
                              title: 'Tarjetas',
                              subtitle: 'IC Cards',
                              onTap: () {},
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
                              icon: Icons.wifi,
                              title: 'WiFi',
                              subtitle: 'Red',
                              onTap: () {},
                            ),

                            buildFeatureCard(
                              icon: Icons.bluetooth,
                              title: 'Bluetooth',
                              subtitle: 'Conexión',
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

  Widget buildPrimaryAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Icon(icon, color: color),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
