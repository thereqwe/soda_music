import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class StarAvatar extends StatefulWidget {
  final imageUrl;
  const StarAvatar({super.key, required this.imageUrl});

  @override
  State<StarAvatar> createState() => _StarAvatarState();
}

class _StarAvatarState extends State<StarAvatar> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CachedNetworkImage(
            useOldImageOnUrlChange: true,
            placeholder: (context, url) =>
                Image.asset('assets/images/disc.png'),
            memCacheWidth: 200,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
            imageUrl: widget.imageUrl));
  }
}
