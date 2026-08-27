import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/brand_utils.dart';
import '../../../data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<NotificationProvider>().loadNotifications(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settings.translate('Notifikasi', 'Notifications'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notificationProvider.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.redAccent,
              ),
              onPressed: () => _showDeleteAllDialog(
                context,
                notificationProvider,
                settings,
                auth.user!.uid,
              ),
            ),
        ],
      ),
      body: notificationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : notificationProvider.notifications.isEmpty
          ? _buildEmptyState(settings)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notificationProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationProvider.notifications[index];
                return _buildNotificationItem(
                  context,
                  notification,
                  notificationProvider,
                  settings,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(SettingsProvider settings) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80,
            color: Colors.grey.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            settings.translate('Belum ada notifikasi', 'No notifications yet'),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settings.translate(
              'Semua notifikasi transaksi akan muncul di sini.',
              'All transaction notifications will appear here.',
            ),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
    SettingsProvider settings,
  ) {
    final dateText = DateFormat('dd MMM, HH:mm').format(notification.date);

    return Dismissible(
      key: Key(notification.id ?? notification.hashCode.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    settings.translate(
                      'Hapus Notifikasi?',
                      'Delete Notification?',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                settings.translate(
                  'Yakin ingin menghapus notifikasi ini?',
                  'Are you sure you want to delete this notification?',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    settings.translate('Batal', 'Cancel'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    settings.translate('Hapus', 'Delete'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        provider.deleteNotification(notification.id!);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        color: notification.isRead
            ? Theme.of(context).cardColor.withValues(alpha: 0.6)
            : Theme.of(context).cardColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!notification.isRead) {
              provider.markAsRead(notification.id!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(context, notification),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            dateText,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(
    BuildContext context,
    NotificationModel notification,
  ) {
    final title = notification.title.toLowerCase();
    final message = notification.message.toLowerCase();

    // Cek apakah ada brand di title atau message
    final assetPath =
        BrandUtils.getAssetPath(title) ?? BrandUtils.getAssetPath(message);

    // Cek apakah ini pemasukan atau pengeluaran
    final isIncome =
        title.contains('pemasukan') ||
        message.contains('pemasukan') ||
        title.contains('income') ||
        message.contains('income') ||
        title.contains('berhasil masuk') ||
        message.contains('berhasil masuk');

    final isExpense =
        title.contains('pengeluaran') ||
        message.contains('pengeluaran') ||
        title.contains('expense') ||
        message.contains('expense') ||
        title.contains('berhasil keluar') ||
        message.contains('berhasil keluar');

    if (assetPath != null) {
      return BrandUtils.getBrandIcon(assetPath, size: 40, isExpense: !isIncome);
    }

    if (notification.type == 'transaction') {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color:
              (isIncome ? Colors.green : (isExpense ? Colors.red : Colors.blue))
                  .withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome
              ? Icons.arrow_upward_rounded
              : (isExpense
                    ? Icons.arrow_downward_rounded
                    : Icons.swap_horiz_rounded),
          color: isIncome
              ? Colors.green
              : (isExpense ? Colors.red : Colors.blue),
          size: 20,
        ),
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(notification.type),
        color: _getNotificationColor(notification.type),
        size: 20,
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'transaction':
        return Icons.swap_horiz_rounded;
      case 'sync':
        return Icons.sync_rounded;
      case 'system':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'transaction':
        return Colors.green;
      case 'sync':
        return Colors.blue;
      case 'system':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  void _showDeleteAllDialog(
    BuildContext context,
    NotificationProvider provider,
    SettingsProvider settings,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(settings.translate('Hapus Semua?', 'Delete All?')),
        content: Text(
          settings.translate(
            'Apakah Anda yakin ingin menghapus semua notifikasi?',
            'Are you sure you want to delete all notifications?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Batal', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAllNotifications(userId);
              Navigator.pop(context);
            },
            child: Text(
              settings.translate('Hapus Semua', 'Delete All'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
