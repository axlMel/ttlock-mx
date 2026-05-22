import 'package:flutter/material.dart';
import '../models/ekey.dart';
import '../theme/app_colors.dart';

class LockCard extends StatelessWidget {
  final EKey keyData;
  final VoidCallback onTap;

  const LockCard({super.key, required this.keyData, required this.onTap});

  Color getBatteryColor() {
    if (keyData.electricQuantity > 50) {
      return Colors.green;
    }

    if (keyData.electricQuantity > 20) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                // ICONO
                Container(
                  width: 54,
                  height: 54,

                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const Spacer(),

                // BATERÍA
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: getBatteryColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.battery_full,
                        size: 18,
                        color: getBatteryColor(),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        '${keyData.electricQuantity}%',

                        style: TextStyle(
                          color: getBatteryColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // NOMBRE
            Text(
              keyData.lockAlias,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            // SUBINFO
            Text(
              'ID ${keyData.lockId}',

              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
