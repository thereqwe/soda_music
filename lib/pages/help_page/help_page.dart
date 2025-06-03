import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("关于"),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 1,
                image: Image.asset("assets/images/唱片机.jpeg").image)),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Container(
          child: Padding(
            padding: EdgeInsets.only(top: 100),
            child: SelectableText(
              ""
              "苏打音乐希望给您带来动听的音乐\n"
              "官方网站: https://sodamusic.wuaze.com\n"
              "\n"
              "\n"
              "如有问题或想听的音乐可反馈邮箱"
              "sodamusic2021@outlook.com"
              ""
              "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              cursorColor: Colors.blue, // 光标颜色
            ),
          ),
        ),
      ),
    );
  }
}
