import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/utils/constants.dart';

import '../../utils/api.dart';
import '../../utils/dialog_utils.dart';
import '../play_page.dart';

class PackPage extends StatefulWidget {
  final String pid;
  final String packImg;
  const PackPage({super.key, required this.pid, required this.packImg});

  @override
  State<PackPage> createState() => _PackPageState();
}

class _PackPageState extends State<PackPage> {
  var albumData = {};
  var musicList = [];
  bool _isExpanded = false; // 是

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPackDetail();
    _getMusicInPack();
  }

  _getMusicInPack() async {
    final ret = await getMusicInPack(widget.pid);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    musicList.clear();
    arr.forEach((item) {
      musicList.add(item);
    });
    setState(() {});
  }

  _getPackDetail() async {
    final ret = await getPackDetail(widget.pid);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    albumData = ret["data"];
    String title = albumData["packName"];
    if (title.length > 20) {
      titleSize = 13.0;
    } else {
      titleSize = 16.0;
    }
    setState(() {});
  }

  var titleSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${albumData["packName"] ?? ""} ",
          style: TextStyle(fontSize: titleSize),
        ),
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Positioned(
                        child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            fit: BoxFit.cover,
                            imageUrl: widget.packImg)),
                    Positioned(
                      child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          child: Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            color:
                                Colors.white.withOpacity(0.0), // 半透明背景，让模糊效果更明显
                          )),
                    ),
                    Container(
                      child: Center(
                          child: Hero(
                        tag: widget.pid,
                        child: CachedNetworkImage(
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            imageUrl: widget.packImg),
                      )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "歌单简介:",
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.normal),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded; // 切换状态
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 0.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                color: Colors.black38,
                                _isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more, // 动态显示按钮文本
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded; // 切换状态
                      });
                    },
                    child: Text(
                      albumData["introduction"] ?? "",
                      maxLines: _isExpanded ? null : 3,
                      overflow:
                          _isExpanded ? null : TextOverflow.ellipsis, // 省略号
                    ),
                  ),
                ),
                SizedBox(height: 8), // 间距
                // 展开/收起按钮

                Container(
                  child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(), // 禁用滑动
                      shrinkWrap: true,
                      itemBuilder: (context, idx) {
                        return GestureDetector(
                          onTap: () async {
                            if (player.name != musicList[idx]["name"]) {
                              player.setMusicList(
                                  musicList, MusicListType.album, idx);
                              player.playList();
                            }
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return PlayPage();
                            }));
                            //await player.play(UrlSource(musicList[idx]["listenUrl"]));
                          },
                          child: ListTile(
                            title: Text(
                              musicList[idx]["name"],
                              style: TextStyle(
                                  color: player.name == musicList[idx]["name"]
                                      ? MainColor
                                      : Colors.black),
                            ),
                            subtitle: Text(
                              musicList[idx]["playTimes"],
                              style: TextStyle(
                                  color: player.name == musicList[idx]["name"]
                                      ? MainColor
                                      : Colors.black38),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, idx) {
                        return Divider(
                          height: 0.3,
                          thickness: 0.3,
                          indent: 20,
                          endIndent: 20,
                        );
                      },
                      itemCount: musicList.length),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
