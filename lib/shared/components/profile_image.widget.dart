import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double radius;
  final Color? backgroundColor;

  const ProfileImageWidget({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.radius = 50,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.pink[100];

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage(bgColor!);
    } else if (imageFile != null) {
      return _buildFileImage(bgColor!);
    } else {
      return _buildPlaceholder(bgColor!);
    }
  }

  Widget _buildNetworkImage(Color bgColor) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(bgColor),
    );
  }

  Widget _buildFileImage(Color bgColor) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      backgroundImage: FileImage(imageFile!),
    );
  }

  Widget _buildPlaceholder(Color bgColor) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(Icons.person, size: radius, color: Colors.white),
    );
  }
}
