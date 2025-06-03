import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/album_page/album_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/utils.dart';

class StarPage extends StatefulWidget {
  final linkArtistId;
  const StarPage({super.key, required this.linkArtistId});

  @override
  State<StarPage> createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  var starName = '';
  var starImg = '';
  var introduction = '';
  var starData;
  var albumList = [];
  var songList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getStar();
    _getStarSongs();
    _getStarAlbums();
  }

  _getStarSongs() async {
    final ret = await getStarSongs(widget.linkArtistId);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    songList.clear();
    arr.forEach((item) {
      for (var i = 0; i < songList.length; i++) {
        if (songList[i]["name"] == item["name"]) {
          return;
        }
      }
      songList.add(item);
    });
    setState(() {});
  }

  _getStar() async {
    final ret = await getStar(widget.linkArtistId);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }

    starData = ret["data"];
    starName = starData["starName"];
    starImg = starData["starImg"];
    introduction = starData["introduction"];

    setState(() {});
  }

  _getStarAlbums() async {
    final ret = await getStarAlbums(widget.linkArtistId);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    albumList.clear();
    arr.forEach((item) {
      albumList.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(starName),
        ),
        body: DefaultTabController(
          length: 3,
          child: Container(
            // color: Colors.red,
            child: Column(
              children: [
                Stack(
                  children: [
                    Positioned(
                        child: CachedNetworkImage(
                            memCacheWidth:
                                MediaQuery.of(context).size.width.toInt(),
                            placeholder: (context, url) =>
                                Image.asset('assets/images/disc.png'),
                            useOldImageOnUrlChange: true,
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            fit: BoxFit.cover,
                            imageUrl: starImg)),
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
                              memCacheWidth:
                                  MediaQuery.of(context).size.width.toInt(),
                              placeholder: (context, url) =>
                                  Image.asset('assets/images/disc.png'),
                              useOldImageOnUrlChange: true,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              imageUrl: starImg ?? "")),
                    ),
                  ],
                ),
                TabBar(
                  tabs: [Tab(text: '歌曲'), Tab(text: '专辑'), Tab(text: '简介')],
                ),
                Expanded(
                  child: TabBarView(children: [
                    Consumer<PlayerInstance>(builder: (context, player, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 15),
                            child: GestureDetector(
                              onTap: () {
                                player.setMusicList(
                                    songList, MusicListType.album, 0);
                                player.playList();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("播放全部"),
                                  Icon(Icons.play_arrow)
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                                itemBuilder: (context, idx) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (player.name !=
                                          songList[idx]["linkMid"]) {
                                        player.setMusicList(
                                            songList, MusicListType.album, idx);
                                        player.playList();
                                      }
                                    },
                                    child: ListTile(
                                      title: Text(
                                        songList[idx]["name"],
                                        style: TextStyle(
                                            color: player.linkMid ==
                                                    songList[idx]["linkMid"]
                                                ? MainColor
                                                : Colors.black87),
                                      ),
                                      subtitle: Text(
                                        songList[idx]["playTimes"],
                                        style: TextStyle(
                                            color: player.linkMid ==
                                                    songList[idx]["linkMid"]
                                                ? MainColor
                                                : Colors.black54),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          player.toggleCollect(songList[idx]);
                                        },
                                        child: Icon(
                                          Icons.favorite,
                                          color: player.judgeCollectionStatus(
                                                  songList[idx]["linkMid"])
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, idx) {
                                  return Divider(
                                    thickness: 0.1,
                                  );
                                },
                                padding: EdgeInsets.only(bottom: 150),
                                itemCount: songList.length),
                          ),
                        ],
                      );
                    }),
                    ListView.separated(
                        itemBuilder: (context, idx) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AlbumPage(aid: albumList[idx]["aid"]);
                              }));
                            },
                            child: ListTile(
                              leading: Container(
                                //  color: Colors.green,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    memCacheWidth: MediaQuery.of(context)
                                        .size
                                        .width
                                        .toInt(),
                                    placeholder: (context, url) =>
                                        Image.asset('assets/images/disc.png'),
                                    useOldImageOnUrlChange: true,
                                    width: 80,
                                    imageUrl: albumList[idx]["albumImg"],
                                  ),
                                ),
                              ),
                              title: Text(albumList[idx]["albumName"]),
                              subtitle: Text(albumList[idx]["companyName"] +
                                  " " +
                                  formatMilliseconds2YMD(
                                      albumList[idx]["publishTime"])),
                            ),
                          );
                        },
                        separatorBuilder: (context, idx) {
                          return Divider(
                            thickness: 0.1,
                          );
                        },
                        itemCount: albumList.length),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(child: Text(introduction)),
                    )
                  ]),
                ),
                BannerAd()
              ],
            ),
          ),
        ));
  }
}
