import 'package:flutter/material.dart';
import 'package:soda_music_flutter/pages/play_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/utils/utils.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final musicList = [];
  //final player = AudioPlayer();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init() async {
      final ret = await getMusics();
      if (ret["code"].toString() != "0") {
        return;
      }
      final data = ret["data"] as List;
      data.forEach((music) {
        musicList.add(music);
      });
      setState(() {});
      print(ret);
    }

    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("播放测试页面"),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
            itemBuilder: (context, idx) {
              return GestureDetector(
                onTap: () async {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return PlayPage();
                  }));
                  //await player.play(UrlSource(musicList[idx]["listenUrl"]));
                },
                child: ListTile(
                  title: Text(musicList[idx]["name"]),
                  leading: Image.network(musicList[idx]["albumImg"]),
                  subtitle: Text(musicList[idx]["listenUrl"]),
                ),
              );
            },
            separatorBuilder: (context, idx) {
              return Divider();
            },
            itemCount: musicList.length),
      ),
    );
  }
}
