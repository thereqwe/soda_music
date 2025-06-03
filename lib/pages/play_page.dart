import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/album_page/album_page.dart';
import 'package:soda_music_flutter/pages/lyric_page/lyric_page.dart';
import 'package:soda_music_flutter/pages/music_play_list/music_play_list.dart';
import 'package:soda_music_flutter/pages/stack_page.dart';
import 'package:soda_music_flutter/pages/star_page/star_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../utils/dialog_utils.dart';
import 'home_page.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = Provider.of<PlayerInstance>(context, listen: false);
      player.shrinkShortcut();
    });
  }

  // 控制播放进度
  void seekTo(Duration newPosition) async {
    final player = Provider.of<PlayerInstance>(context, listen: false);
    player.seekTo(newPosition);
  }

  Throttler _throttler = Throttler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<PlayerInstance>(builder: (context, player, _) {
            return IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LyricsPage(
                      linkMid: player.linkMid,
                      name: player.name,
                    );
                  }));
                },
                icon: Image.asset(
                  "assets/images/歌词.png",
                  width: 20,
                ));
          }),
          Consumer<PlayerInstance>(builder: (context, player, _) {
            return GestureDetector(
              onTap: () {
                player.toggleCollect(player.musicList[player.nowPlayingIdx]);
              },
              child: Icon(
                Icons.favorite,
                color: player.judgeCollectionStatus(player.linkMid)
                    ? Colors.red
                    : Colors.grey,
              ),
            );
          }),
          IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) {
                  print(route);
                  if (route is MaterialPageRoute) {
                    // 获取 builder 函数返回的 Widget 类型
                    final builderWidget = route.builder(context);
                    return builderWidget is StackPage;
                  }
                  return false;
                });
              },
              icon: Icon(Icons.home_outlined)),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MusicPlayListPage();
                }));
              },
              icon: Icon(Icons.queue_music_outlined))
        ],
        title: Consumer<PlayerInstance>(builder: (context, player, _) {
          return Text(
            player.name ?? "",
            style: TextStyle(fontSize: 16),
          );
        }),
      ),
      body: Stack(
        children: [
          Consumer<PlayerInstance>(builder: (context, player, _) {
            return Container(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      var ret = await getAidByAlbumLinkId(player.linkAlbumId);
                      if (ret["code"].toString() != "0") {
                        DialogUtils.showToast(context, "专辑信息失败");
                        return;
                      }
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        String aid = ret["data"]["aid"];
                        return AlbumPage(aid: aid);
                      }));
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.width * 0.8,
                            imageUrl: player.img ?? "",
                            //placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => SizedBox(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    player.name ?? "",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Wrap(
                      spacing: 12.0, // 水平间距
                      runSpacing: 6.0, // 垂直间距
                      children: (player.artist ?? "")
                          .split(',')
                          .asMap() // 将列表转换为带索引的Map
                          .entries // 获取键值对迭代器
                          .map((entry) {
                        final index = entry.key + 1; // 编号从1开始
                        final artist = entry.value.trim();

                        return GestureDetector(
                          onTap: () {
                            if (player.linkArtistIds.isEmpty) return;

                            final artistIds = player.linkArtistIds.split(',');
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return StarPage(
                                  linkArtistId: artistIds[index - 1]);
                            }));
                            //  DialogUtils.showToast(
                            //     context, "${artistIds[index - 1]}");
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  child: Text(
                                    '$index',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.0),
                                Text(
                                  artist,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Slider(
                      value: player.position.inSeconds.toDouble(),
                      min: 0,
                      max: player.duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        final newPosition = Duration(seconds: value.toInt());
                        seekTo(newPosition);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '        ${player.position.inMinutes}:${(player.position.inSeconds % 60).toString().padLeft(2, '0')} / ${player.duration.inMinutes}:${(player.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 16),
                      ),
                      IconButton(
                          onPressed: () {
                            player.tooglePlayMode();
                          },
                          icon: Image.asset(
                              width: 20, player.getPlayModeImgPath())),
                    ],
                    mainAxisSize: MainAxisSize.min,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _throttler.throttle(
                              duration: Duration(milliseconds: 500),
                              onThrottle: () {
                                player.playPre();
                              });
                        },
                        icon: Icon(
                          Icons.skip_previous,
                          size: 60,
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        //  color: Colors.green,
                        child: player.isLoading
                            ? Container(
                                width: 30,
                                child: Transform.scale(
                                    scale: 0.5,
                                    child: const CircularProgressIndicator()))
                            : IconButton(
                                onPressed: () async {
                                  if (player.isPlaying == false) {
                                    await player.resume();
                                  } else {
                                    await player.pause();
                                  }
                                },
                                icon: Icon(
                                  player.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 60,
                                )),
                      ),
                      Center(
                        child: IconButton(
                            onPressed: () {
                              _throttler.throttle(
                                  duration: Duration(milliseconds: 500),
                                  onThrottle: () {
                                    player.playNext();
                                  });
                            },
                            icon: Icon(
                              Icons.skip_next,
                              size: 60,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          Positioned(
            child: BannerAd(),
            bottom: 0,
          )
        ],
      ),
    );
  }
}
