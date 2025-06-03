import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unionad/flutter_unionad.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/stack_page.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/union_add.dart';
import '../../utils/utils.dart';
import '../home_page.dart';

class AdPage extends StatefulWidget {
  const AdPage({super.key});

  @override
  State<AdPage> createState() => _AdPageState();
}

class _AdPageState extends State<AdPage> {
  var _color = Colors.white;
  var _isAdReady = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _color,
        child: Consumer<PlayerInstance>(builder: (context, player, _) {
          return Stack(
            children: [
              FlutterUnionadSplashAdView(
                //android 开屏广告广告id 必填 889033013 102729400
                androidCodeId: "103495306",
                //ios 开屏广告广告id 必填
                iosCodeId: "103495306",
                //是否支持 DeepLink 选填
                supportDeepLink: true,
                // 期望view 宽度 dp 选填
                width: MediaQuery.of(context).size.width,
                //期望view高度 dp 选填
                height: MediaQuery.of(context).size.height - 40,
                //是否影藏跳过按钮(当影藏的时候显示自定义跳过按钮) 默认显示
                hideSkip: false,
                //超时时间
                timeout: 1000,
                callBack: FlutterUnionadSplashCallBack(
                  onShow: () {
                    print("开屏广告显示");
                    _isAdReady = true;
                    //     DialogUtils.showToast(context, "开屏广告加载完毕");
                    setState(() {});
                  },
                  onClick: () {
                    print("开屏广告点击");
                  },
                  onFail: (error) {
                    print("开屏广告失败 $error");
                    //  DialogUtils.showToast(context, "开屏广告失败 $error");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return StackPage();
                    }), (Route<dynamic> route) => false);
                  },
                  onFinish: () {
                    print("开屏广告倒计时结束");
                    //     DialogUtils.showToast(context, "开屏广告倒计时结束");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return StackPage();
                    }), (Route<dynamic> route) => false);
                  },
                  onSkip: () {
                    print("开屏广告跳过");
                    //      DialogUtils.showToast(context, "开屏广告跳过");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return StackPage();
                    }), (Route<dynamic> route) => false);
                  },
                  onTimeOut: () {
                    print("开屏广告超时");
                    // DialogUtils.showToast(context, "开屏广告超时");
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return StackPage();
                    }), (Route<dynamic> route) => false);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
