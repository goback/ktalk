import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:ktalk/common/utils/global_navigator.dart';
import 'package:ktalk/common/utils/logger.dart';

class VideoDownloadWidget extends StatelessWidget {
  final String downloadUrl;

  const VideoDownloadWidget({
    super.key,
    required this.downloadUrl,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        try {
          FileDownloader.downloadFile(
            url: downloadUrl,
            notificationType: NotificationType.all,
          );
        } catch (e, stackTrace) {
          logger.e(e);
          logger.e(stackTrace);
          GlobalNavigator.showAlertDialog(text: e.toString());
        }
      },
      child: const Text(
        '🎬',
        style: TextStyle(fontSize: 25),
      ),
    );
  }
}
