import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("联系我们"),
      ),
      body: Container(
        child: Center(
          child: Text("""
        邮箱:thereqwe@qq.com
        QQ:523489996
        上海露懿科技有限公司
        """),
        ),
      ),
    );
  }
}
