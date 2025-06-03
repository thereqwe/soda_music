import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/help_page/help_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../../utils/dialog_utils.dart';

class RandomListenPage extends StatefulWidget {
  const RandomListenPage({super.key});

  @override
  State<RandomListenPage> createState() => _RandomListenPageState();
}

class _RandomListenPageState extends State<RandomListenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ));
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20), // 动画持续时间
    );
  }

  // 控制播放进度
  void seekTo(Duration newPosition) async {
    final player = Provider.of<PlayerInstance>(context, listen: false);
    player.seekTo(newPosition);
  }

  _getCategoryMusics(String category) async {
    var musicList = [];
    final ret = await getCategoryMusics(category);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }

    final arr = ret["data"] as List;
    musicList.clear();
    arr.forEach((item) {
      musicList.add(item);
    });
    return musicList;
  }

  // 让动画
  final Throttler _throttler = Throttler();

  final categoryList = [
    "流行",
    "欧美",
    "日语",
    "韩语",
    "轻音乐",
    "说唱",
    "儿歌",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return HelpPage();
                  }));
                },
                icon: Icon(Icons.settings))
          ],
          systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent, // 保持状态栏透明
          ),
          toolbarTextStyle: TextStyle(color: Colors.black),
          backgroundColor: Colors.transparent,
          title: Text(
            "随心听",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, // 渐变起始点
                  end: Alignment.bottomCenter, // 渐变结束点
                  colors: [
                    // 渐变颜色数组
                    MainColor,
                    Colors.white,
                  ],
                  stops: [0.0, 1.0], // 颜色终止位置(0.0-1.0)
                  tileMode: TileMode.clamp, // 超出范围的颜色处理方式
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8, top: 40),
                child: GridView.builder(
                  // shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3列
                    childAspectRatio: 1.0, // 正方形子项
                  ),
                  itemCount: categoryList.length,
                  itemBuilder: (context, index) {
                    return Consumer<PlayerInstance>(
                        builder: (context, player, _) {
                      return GestureDetector(
                        onTap: () async {
                          List musicList =
                              await _getCategoryMusics(categoryList[index]);
                          if (musicList.isEmpty) {
                            return;
                          }
                          player.setMusicList(
                              musicList, MusicListType.random_heart, 0);
                          player.playList();
                        },
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                height: 80,
                                width: 120,
                                "assets/images/${categoryList[index]}.jpeg",
                                fit: BoxFit.fill,
                              ),
                              Text(categoryList[index]),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
            Positioned(
              child: BannerAd(),
              bottom: 0,
            )
          ],
        ));
  }
}
