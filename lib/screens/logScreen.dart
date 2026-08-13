import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/services/log_service.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      appBar: AppHeader(
        title: 'System Logs',
        variant: AppHeaderVariant.compactTitle3,
        leading: Container(
          width: 44,
          height: 44,
          decoration: ShapeDecoration(
            color: colors.backgroundsPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: colors.labelsPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: colors.accentsRed),
          onPressed: () {
            LogService.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: AppText('Log berhasil dibersihkan', type: AppTextType.caption1),
              ),
            );
          },
        ),
      ),
      backgroundColor: colors.backgroundsPrimary,
      body: ValueListenableBuilder<List<String>>(
        valueListenable: LogService.logsNotifier,
        builder: (context, logs, child) {
          if (logs.isEmpty) {
            return Center(
              child: AppText(
                'Belum ada log tercatat',
                type: AppTextType.body,
                customColor: colors.labelsSecondary,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final logEntry = logs[logs.length - 1 - index]; // Newest first
              final isBle = logEntry.contains('[BLE]');
              final isError = logEntry.toLowerCase().contains('error') ||
                  logEntry.toLowerCase().contains('failed') ||
                  logEntry.toLowerCase().contains('exception');

              Color logColor = colors.labelsPrimary;
              if (isError) {
                logColor = colors.accentsRed;
              } else if (isBle) {
                logColor = colors.accentsBlue;
              }

              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                title: AppText(
                  logEntry,
                  type: AppTextType.caption1,
                  customColor: logColor,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: logEntry));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: AppText('Log disalin ke clipboard', type: AppTextType.caption1),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
