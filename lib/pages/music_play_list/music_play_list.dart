import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../../utils/utils.dart';
import '../play_page.dart';

class MusicPlayListPage extends StatefulWidget {
  const MusicPlayListPage({super.key});

  @override
  State<MusicPlayListPage> createState() => _MusicPlayListPageState();
}

class _MusicPlayListPageState extends State<MusicPlayListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _listTileKeys = [];
  @override
  void initState() {
    final player = Provider.of<PlayerInstance>(context, listen: false);
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double scrollOffset = 0;
      for (int i = 0; i < player.nowPlayingIdx; i++) {
        final key = _listTileKeys[i];
        final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          scrollOffset += renderBox.size.height;
        }
      }
      _scrollController.animateTo(
        scrollOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("播放列表"),
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        _listTileKeys.clear();
        for (int i = 0; i < player.musicList.length; i++) {
          _listTileKeys.add(GlobalKey());
        }
        return Column(
          children: [
            Container(
              child: Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: player.musicList.length,
                    itemBuilder: (context, idx) {
                      return GestureDetector(
                        key: _listTileKeys[idx],
                        onTap: () async {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return PlayPage();
                          }));
                          //await player.play(UrlSource(musicList[idx]["listenUrl"]));
                        },
                        child: Container(
                          color: Color.fromRGBO(250, 250, 250, 1),
                          child: GestureDetector(
                            onTap: () {
                              player.nowPlayingIdx = idx;
                              player.playList();
                            },
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                child: CachedNetworkImage(
                                  imageUrl: player.musicList[idx]["albumImg"],
                                ),
                              ),
                              title: Text(
                                player.musicList[idx]["name"],
                                style: TextStyle(
                                    color: player.nowPlayingIdx == idx
                                        ? MainColor
                                        : Colors.black),
                              ),
                              subtitle: Text(
                                player.musicList[idx]["artist"] +
                                    "  " +
                                    convertTime(
                                        player.musicList[idx]["playTimes"]),
                                style: TextStyle(
                                    color: player.nowPlayingIdx == idx
                                        ? MainColor
                                        : Colors.black38),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
            BannerAd()
          ],
        );
      }),
    );
  }
}
