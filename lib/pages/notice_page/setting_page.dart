import 'package:flutter/material.dart';
import 'package:soda_music_flutter/pages/notice_page/about_us_page.dart';
import 'package:soda_music_flutter/pages/notice_page/privacy_page.dart';
import 'package:soda_music_flutter/pages/notice_page/privacy_page.dart';

import 'about_us_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final itemList = ["关于我们", "隐私政策"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: ListView.separated(
            itemBuilder: (context, idx) {
              return GestureDetector(
                onTap: () {
                  if (idx == 0) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return AboutUsPage();
                    }));
                  } else if (idx == 1) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return PrivacyPage();
                    }));
                  }
                },
                child: Text(
                  itemList[idx],
                  style: TextStyle(fontSize: 20),
                ),
              );
            },
            separatorBuilder: (context, idx) {
              return Divider();
            },
            itemCount: 2,
          ),
        ),
      ),
    );
  }
}
