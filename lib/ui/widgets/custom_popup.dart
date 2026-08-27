import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomPopup {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    bool isSuccess = true,
    VoidCallback? onConfirm,
    Duration autoCloseDuration = const Duration(milliseconds: 1200),
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // Auto-close timer
        Future.delayed(autoCloseDuration, () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
            if (onConfirm != null) onConfirm();
          }
        });

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isSuccess ? AppColors.success : AppColors.error)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: isSuccess ? AppColors.success : AppColors.error,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}
