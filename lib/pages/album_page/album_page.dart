import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/utils/constants.dart';

import '../../utils/api.dart';
import '../../utils/dialog_utils.dart';
import '../play_page.dart';
import '../star_page/star_page.dart';

class AlbumPage extends StatefulWidget {
  final String aid;
  const AlbumPage({super.key, required this.aid});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  var albumData = {};
  var musicList = [];
  bool _isExpanded = false; // 是

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getAlbumDetail();
    _getMusicInAlbum();
  }

  _getMusicInAlbum() async {
    final ret = await getMusicInAlbum(widget.aid);
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

  _getAlbumDetail() async {
    final ret = await getAlbumDetail(widget.aid);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    albumData = ret["data"];
    String title = albumData["albumName"];
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
          "${albumData["artist"] ?? ""} - ${albumData["albumName"] ?? ""} ",
          style: TextStyle(fontSize: titleSize),
        ),
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        return Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 250),
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
                            imageUrl: albumData["albumImg"] ?? "")),
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
                          child: CachedNetworkImage(
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              imageUrl: albumData["albumImg"] ?? "")),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 15.0, right: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "专辑简介:",
                //         style: TextStyle(
                //             fontSize: 13, fontWeight: FontWeight.normal),
                //       ),
                //       GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             _isExpanded = !_isExpanded; // 切换状态
                //           });
                //         },
                //         child: Padding(
                //           padding: const EdgeInsets.only(right: 0.0),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               Icon(
                //                 color: Colors.black38,
                //                 _isExpanded
                //                     ? Icons.expand_less
                //                     : Icons.expand_more, // 动态显示按钮文本
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //   child: GestureDetector(
                //     onTap: () {
                //       setState(() {
                //         _isExpanded = !_isExpanded; // 切换状态
                //       });
                //     },
                //     child: Text(
                //       albumData["introduction"] ?? "暂无简介",
                //       maxLines: _isExpanded ? null : 3,
                //       overflow:
                //           _isExpanded ? null : TextOverflow.ellipsis, // 省略号
                //     ),
                //   ),
                // ),
                // SizedBox(height: 8), // 间距
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
                            // Navigator.of(context)
                            //     .push(MaterialPageRoute(builder: (context) {
                            //   return PlayPage();
                            // }));
                            //await player.play(UrlSource(musicList[idx]["listenUrl"]));
                          },
                          child: ListTile(
                            leading: Container(
                                //       color: Colors.green,
                                child: Text(
                              "${idx + 1}",
                              style: TextStyle(fontSize: 16),
                            )),
                            title: Text(
                              musicList[idx]["name"],
                              style: TextStyle(
                                  color: player.name == musicList[idx]["name"]
                                      ? MainColor
                                      : Colors.black),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Wrap(
                                spacing: 12.0, // 水平间距
                                runSpacing: 6.0, // 垂直间距
                                children: () {
                                  final artistStr =
                                      musicList[idx]["artist"]?.toString() ??
                                          "";
                                  final artistIds = (musicList[idx]
                                                  ["linkArtistIds"]
                                              ?.toString() ??
                                          "")
                                      .split(',');

                                  return artistStr
                                      .split(',')
                                      .asMap() // 将列表转换为带索引的Map
                                      .entries // 获取键值对迭代器
                                      .where((entry) => entry.value
                                          .trim()
                                          .isNotEmpty) // 过滤空字符串
                                      .map((entry) {
                                    final index = entry.key;
                                    final artist = entry.value.trim();
                                    final hasValidId =
                                        index < artistIds.length &&
                                            artistIds[index].isNotEmpty;

                                    return GestureDetector(
                                      onTap: () {
                                        if (!hasValidId) return;

                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                            return StarPage(
                                                linkArtistId: artistIds[index]);
                                          }),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          artist,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: player.name ==
                                                    musicList[idx]["name"]
                                                ? MainColor
                                                : Colors.black38,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList();
                                }(),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  musicList[idx]["playTimes"],
                                  style: TextStyle(
                                      color:
                                          player.name == musicList[idx]["name"]
                                              ? MainColor
                                              : Colors.black38),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    player.toggleCollect(musicList[idx]);
                                  },
                                  child: Icon(
                                    Icons.favorite,
                                    color: player.judgeCollectionStatus(
                                            musicList[idx]["linkMid"])
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ],
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
