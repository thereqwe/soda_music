import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/money_page/money_page.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../../utils/constants.dart';
import '../star_page/star_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "歌单保存在本地，卸载后会移除",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            BannerAd()
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("收藏歌单"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MoneyPage();
                }));
              },
              child: Text("❤️赞赏支持"))
        ],
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        List songList = player.collectionList;
        return Container(
          child: songList.length == 0
              ? Center(
                  child: Text("暂无收藏音乐,点击歌曲右边的爱心收藏吧~"),
                )
              : ListView.separated(
                  padding: EdgeInsets.only(bottom: 150),
                  shrinkWrap: true,
                  itemBuilder: (context, idx) {
                    return GestureDetector(
                      onTap: () async {
                        if (player.name != songList[idx]["name"]) {
                          player.setMusicList(
                              songList, MusicListType.album, idx);
                          player.playList();
                        }
                        // Navigator.of(context)
                        //     .push(MaterialPageRoute(builder: (context) {
                        //   return PlayPage();
                        // }));
                        //await player.play(UrlSource(songList[idx]["listenUrl"]));
                      },
                      child: ListTile(
                        leading: Container(
                            //       color: Colors.green,
                            child: Text(
                          "${idx + 1}",
                          style: TextStyle(fontSize: 16),
                        )),
                        title: Text(
                          songList[idx]["name"],
                          style: TextStyle(
                              color: player.name == songList[idx]["name"]
                                  ? MainColor
                                  : Colors.black),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0.0),
                          child: Wrap(
                            spacing: 12.0, // 水平间距
                            runSpacing: 6.0, // 垂直间距
                            children: () {
                              final artistStr =
                                  songList[idx]["artist"]?.toString() ?? "";
                              final artistIds =
                                  (songList[idx]["linkArtistIds"]?.toString() ??
                                          "")
                                      .split(',');

                              return artistStr
                                  .split(',')
                                  .asMap() // 将列表转换为带索引的Map
                                  .entries // 获取键值对迭代器
                                  .where((entry) =>
                                      entry.value.trim().isNotEmpty) // 过滤空字符串
                                  .map((entry) {
                                final index = entry.key;
                                final artist = entry.value.trim();
                                final hasValidId = index < artistIds.length &&
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
                                        color:
                                            player.name == songList[idx]["name"]
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
                        trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: player.name == songList[idx]["name"]
                                ? MainColor
                                : Colors.black38,
                          ),
                          onPressed: () {
                            player.toggleCollect(songList[idx]);
                          },
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
                  itemCount: songList.length),
        );
      }),
    );
  }
}
