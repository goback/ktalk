import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CustomImageViewerWidget extends StatelessWidget {
  final String imageUrl;

  const CustomImageViewerWidget({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return InteractiveViewer(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: ExtendedImage.network(imageUrl),
              ),
            );
          },
        );
      },
      child: ExtendedImage.network(
        imageUrl,
        constraints: const BoxConstraints(maxHeight: 200),
      ),
    );
  }
}
