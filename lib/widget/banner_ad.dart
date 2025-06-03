import 'package:flutter/material.dart';
import 'package:flutter_unionad/bannerad/BannerAdView.dart';
import 'package:flutter_unionad/flutter_unionad.dart';

class BannerAd extends StatefulWidget {
  const BannerAd({super.key});

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: FlutterUnionadBannerView(
        //andrrid banner广告id 必填
        androidCodeId: "103198314",
        //ios banner广告id 必填
        iosCodeId: "103198314",
        // 期望view 宽度 dp 必填
        width: MediaQuery.of(context).size.width,
        //期望view高度 dp 必填
        height: 45,
        //广告事件回调 选填
        callBack: FlutterUnionadBannerCallBack(
          onShow: () {
            print("banner广告加载完成");
          },
          onDislike: (message) {
            print("banner不感兴趣 $message");
          },
          onFail: (error) {
            print("banner广告加载失败 $error");
          },
          onClick: () {
            print("banner广告点击");
          },
        ),
      ),
    );
  }
}
