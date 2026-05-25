import 'package:flutter/material.dart';
import '../models/ekey.dart';
import '../theme/app_colors.dart';

class LockCard extends StatefulWidget {
  final EKey keyData;
  final VoidCallback onTap;

  const LockCard({super.key, required this.keyData, required this.onTap});
  @override
  State<LockCard> createState() => _LockCardState();
}

class _LockCardState extends State<LockCard> {
  bool isHovering = false;
  
  Color getBatteryColor() {
    if (widget.keyData.electricQuantity > 50) {
      return Colors.green;
    }

    if (widget.keyData.electricQuantity > 20) {
      return Colors.orange;
    }

    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },

      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 118,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border:  Border.all(
              color: isHovering
              ? AppColors.primary.withOpacity(0.25)
              : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isHovering
                ? Colors.black.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
                blurRadius: isHovering ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,

                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.keyData.electricQuantity}%',
                    style: TextStyle(
                      color: getBatteryColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.keyData.lockAlias,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
