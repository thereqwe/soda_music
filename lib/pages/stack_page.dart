import 'package:flutter/material.dart';
import 'package:soda_music_flutter/pages/category_page/category_page.dart';
import 'package:soda_music_flutter/pages/collection_page/collection_page.dart';
import 'package:soda_music_flutter/pages/home_page.dart';
import 'package:soda_music_flutter/pages/random_listen_page/random_listen_page.dart';
import 'package:soda_music_flutter/utils/constants.dart';

class StackPage extends StatefulWidget {
  const StackPage({super.key});

  @override
  State<StackPage> createState() => _StackPageState();
}

class _StackPageState extends State<StackPage> {
  var _currentIdx = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: MainColor,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIdx,
          onTap: (idx) {
            _currentIdx = idx;
            setState(() {});
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.music_note_rounded), label: "首页"),
            BottomNavigationBarItem(
                icon: Icon(Icons.library_music), label: "歌单分类"),
            BottomNavigationBarItem(
                icon: Icon(Icons.headphones_rounded), label: "随心听"),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: "收藏歌单"),
          ],
        ),
        body: IndexedStack(
          index: _currentIdx,
          children: [
            HomePage(),
            CategoryPage(),
            RandomListenPage(),
            CollectionPage()
          ],
        ),
      ),
    );
  }
}
