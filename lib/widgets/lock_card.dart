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
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Row(
              children: [
                // ICONO
                Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.lock_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const Spacer(),

                // BATERÍA
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: getBatteryColor().withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.battery_full,
                        size: 14,
                        color: getBatteryColor(),
                      ),

                      const SizedBox(width: 2),

                      Text(
                        '${keyData.electricQuantity}%',

                        style: TextStyle(
                          color: getBatteryColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // NOMBRE
            Text(
              keyData.lockAlias,

              maxLines: 2,
              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 6),

            // SUBINFO
            Text(
              'ID ${keyData.lockId}',

              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
