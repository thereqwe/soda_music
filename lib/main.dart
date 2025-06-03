import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:gif/gif.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/pages/advertisement_page/advertisement_page.dart';
import 'package:soda_music_flutter/pages/flash_page.dart';
import 'package:soda_music_flutter/pages/home_page.dart';
import 'package:soda_music_flutter/pages/music_play_list/music_play_list.dart';
import 'package:soda_music_flutter/pages/play_page.dart';
import 'package:soda_music_flutter/pages/stack_page.dart';
import 'package:soda_music_flutter/pages/test.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/utils/event_bus.dart';
import 'package:soda_music_flutter/utils/union_add.dart';
import 'package:umeng_common_sdk/umeng_common_sdk.dart';

import 'model/player.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:audio_service/audio_service.dart';

void main() async {
  await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: "mipmap/soda_logo");

  runApp(
    ChangeNotifierProvider(
      create: (_) => PlayerInstance(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景透明
      statusBarIconBrightness: Brightness.dark, // 状态栏图标为黑色
      statusBarBrightness: Brightness.light, // iOS 状态栏文字为黑色
    ));

    return MaterialApp(
      title: '苏打音乐',
      debugShowCheckedModeBanner: false,
      routes: {
        'StackPage': (context) => StackPage(),
      },
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(240, 240, 240, 1)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(scrolledUnderElevation: 0.0)),
      home: const MyHomePage(title: '苏打音乐'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _showOverlay(context);

      // Navigator.of(context).pushAndRemoveUntil(
      //     MaterialPageRoute(builder: (context) {
      //   return FlashPage();
      // }), (Route<dynamic> route) => false);
      await UnionAdvertisement().setupData();
      try {
        UmengCommonSdk.initCommon(
            '672c338a8f232a05f1ab3e30', '672c385d7e5e6a4eeb900c9a', 'normal');
      } catch (e) {
        UmengCommonSdk.reportError("失败的umeng sdk 初始化");
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return AdPage();
        return StackPage();
      }), (Route<dynamic> route) => false);
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  // 创建一个 OverlayEntry
  OverlayEntry _createOverlayEntry(BuildContext context) {
    late AnimationController _controller;
    final Throttler _throttler = Throttler();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20), // 动画持续时间
    ); // 让动画

    return OverlayEntry(
      builder: (context) =>
          Consumer<PlayerInstance>(builder: (context, player, _) {
        if (player.isPlaying && !_controller.isAnimating) {
          _controller.repeat(); // 启动动画
        } else if (!player.isPlaying && _controller.isAnimating) {
          _controller.stop(); // 停止动画
        }
        return player.musicListType == MusicListType.none
            ? SizedBox()
            : Positioned(
                bottom: 100,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                      width: player.isShortcutExpend ? 350 : 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(240, 240, 240, 1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // 阴影的颜色和透明度
                            spreadRadius: 5, // 扩散程度，数值越大，阴影越分散
                            blurRadius: 7, // 模糊程度，数值越大，阴影越模糊
                            offset: Offset(0, 3), // 阴影相对于 widget 的偏移量 (水平, 垂直)
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          player.isShortcutExpend == false
                              ? SizedBox()
                              : IconButton(
                                  onPressed: () {
                                    player.shrinkShortcut();
                                  },
                                  icon: Icon(Icons.keyboard_arrow_right)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (player.isShortcutExpend == false) {
                                  player.expandShortcut();
                                } else {
                                  final currentRoute =
                                      ModalRoute.of(context)?.settings.name;
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return PlayPage();
                                  }));
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: RotationTransition(
                                  turns: _controller,
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: player.img ?? "",
                                    placeholder: (context, url) =>
                                        Image.asset('assets/images/disc.png'),
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          player.isShortcutExpend == false
                              ? SizedBox()
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      // color: Colors.red,
                                      width: 160,
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        // textAlign: TextAlign.left,
                                        player.name ?? "",
                                        maxLines: 1,
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        //  textAlign: TextAlign.left,
                                        player.artist ?? "",
                                        maxLines: 1,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        player.isLoading
                                            ? Transform.scale(
                                                scale: 0.5,
                                                child:
                                                    CircularProgressIndicator())
                                            : IconButton(
                                                onPressed: () {
                                                  if (player.isPlaying) {
                                                    player.pause();
                                                  } else {
                                                    player.resume();
                                                  }
                                                },
                                                icon: Icon(player.isPlaying
                                                    ? Icons.pause
                                                    : Icons.play_arrow)),
                                        IconButton(
                                            onPressed: () {
                                              _throttler.throttle(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  onThrottle: () {
                                                    player.playNext();
                                                  });
                                            },
                                            icon: Icon(Icons.skip_next)),
                                        IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MusicPlayListPage();
                                              }));
                                            },
                                            icon: Icon(
                                                Icons.queue_music_outlined)),
                                        IconButton(
                                            onPressed: () {
                                              player.tooglePlayMode();
                                            },
                                            icon: Image.asset(
                                                width: 20,
                                                player.getPlayModeImgPath())),
                                      ],
                                    )
                                  ],
                                )
                        ],
                      )),
                ),
              );
      }),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final player = Provider.of<PlayerInstance>(context, listen: false);
    player.stop();
    super.dispose();
  }

  // 显示 Overlay
  void _showOverlay(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // 隐藏 Overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SizedBox(),
      ),
    );
  }
}
