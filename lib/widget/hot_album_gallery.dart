import 'package:flutter/material.dart';

class HotAlbumGallery extends StatefulWidget {
  const HotAlbumGallery({super.key});

  @override
  State<HotAlbumGallery> createState() => _HotAlbumGalleryState();
}

class _HotAlbumGalleryState extends State<HotAlbumGallery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("二战百科"),
      ),
      body: Container(
        color: Colors.red,
      ),
    );
  }
}
