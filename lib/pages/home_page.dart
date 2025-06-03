import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soda_music_flutter/pages/album_page/album_page.dart';
import 'package:soda_music_flutter/pages/search_page/search_page.dart';
import 'package:soda_music_flutter/pages/star_page/star_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/widget/Star_avatar.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../utils/dialog_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final hotAlbumList = [];
  final classicAlbumList = [];
  final hotStarList = [];

  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _previousScrollPosition = 0;
  bool _isSearchBarVisible = true;

  @override
  void initState() {
    // TODO: implement initState

    WidgetsFlutterBinding.ensureInitialized();

    PaintingBinding.instance.imageCache.maximumSizeBytes =
        1024 * 1024 * 300; //最大300M

    super.initState();
    _getHotAlbums();
    _getClassicAlbums();
    _getHotStars();

    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 50, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scrollController.addListener(_handleScroll);
  }

  _getHotStars() async {
    final ret = await getHotStars();
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    hotStarList.clear();
    arr.forEach((item) {
      hotStarList.add(item);
    });
    setState(() {});
  }

  void _handleScroll() {
    double currentScrollPosition = _scrollController.position.pixels;
    if (currentScrollPosition > _previousScrollPosition &&
        _isSearchBarVisible) {
      // 向下滚动，隐藏搜索栏
      _animationController.forward();
      _isSearchBarVisible = false;
    } else if (currentScrollPosition < _previousScrollPosition &&
        !_isSearchBarVisible) {
      // 向上滚动，显示搜索栏
      _animationController.reverse();
      _isSearchBarVisible = true;
    }
    _previousScrollPosition = currentScrollPosition;
  }

  _getHotAlbums() async {
    final ret = await getHotAlbums();
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    hotAlbumList.clear();
    arr.forEach((item) {
      hotAlbumList.add(item);
    });
    setState(() {});
  }

  _getClassicAlbums() async {
    final ret = await getClassicAlbums();
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    classicAlbumList.clear();
    arr.forEach((item) {
      classicAlbumList.add(item);
    });
    setState(() {});
  }

  var adRow = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _animation.value / 50,
                    child: Container(
                        height: _animation.value,
                        color: GrayColor,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                            height: 30,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return SearchPage();
                                }));
                              },
                              child: TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(0),
                                  hintText: "寻找好听的音乐...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: const Icon(
                                    Icons.search,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),

                                  // 当输入框获得焦点时的边框样式
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  // 未获得焦点时的边框样式
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )),
                  );
                }),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      child: CarouselSlider(
                        options: CarouselOptions(
                          enlargeCenterPage: false,
                          height: 200.0,
                          viewportFraction: 1.0,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 10),
                        ),
                        items: hotAlbumList.map((item) {
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return AlbumPage(aid: item["aid"] ?? "");
                                  }));
                                },
                                child: Container(
                                  // color: MainColor,

                                  margin: EdgeInsets.symmetric(horizontal: 0.0),
                                  //decoration: BoxDecoration(color: Colors.amber),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedNetworkImage(
                                          memCacheWidth: MediaQuery.of(context)
                                              .size
                                              .width
                                              .toInt(),
                                          useOldImageOnUrlChange: true,
                                          fit: BoxFit.cover,
                                          height: 200,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  'assets/images/disc.png'),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          imageUrl: item["albumImg"] ?? "",
                                        ),
                                      ),

                                      Positioned.fill(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 5.0,
                                              sigmaY: 5.0), // 调整模糊强度
                                          child: Container(
                                            color: Colors
                                                .transparent, // 必须设置透明色，否则会完全遮挡原图
                                          ),
                                        ),
                                      ), // 调整模糊强度
                                      // **新增：居中图片（覆盖层）**
                                      Positioned(
                                        top: 0,
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        // 居中对齐
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.white70,
                                                    width: 2)),
                                            child: CachedNetworkImage(
                                              memCacheWidth:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width
                                                      .toInt(),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                      'assets/images/disc.png'),
                                              useOldImageOnUrlChange: true,
                                              fit: BoxFit.cover,
                                              height: 200,
                                              width: 200,
                                              imageUrl: item["albumImg"] ?? "",
                                            ),
                                          ),
                                        ),
                                        // 确保图片在原图上方
                                      ),
                                      Positioned(
                                          bottom: 5,
                                          left: 5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 200,
                                                child: Text(
                                                  item["albumName"],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 17,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Text(
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  item["artist"],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    shadows: [
                                                      Shadow(
                                                        color: Colors.black,
                                                        offset: Offset(1, 1),
                                                        blurRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    SizedBox(
                      height: 0,
                    ),
                    // 经典专辑列表
                    Container(
                      //  color: Colors.red,

                      child: GridView.builder(
                        //  scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero, // 移除默认的padding
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                              MediaQuery.of(context).size.width / 4, // 子项的最大宽度
                          childAspectRatio: 0.8, // 子项的宽高比
                        ),
                        itemCount: hotStarList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            // color: Colors.green,
                            margin: EdgeInsets.all(10.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return StarPage(
                                      linkArtistId: hotStarList[index]
                                          ["linkArtistId"]);
                                }));
                              },
                              child: Center(
                                  child: Column(
                                children: [
                                  StarAvatar(
                                    imageUrl: hotStarList[index]["starImg"],
                                  ),
                                  Text(
                                    hotStarList[index]["starName"],
                                    style: TextStyle(
                                        fontSize: hotStarList[index]["starName"]
                                                    .length >
                                                3
                                            ? 11
                                            : 12),
                                  )
                                ],
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                    BannerAd(),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.music_note),
                          Text(
                            "经典专辑",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    Column(
                      children: classicAlbumList.map((album) {
                        adRow++;
                        return Column(
                          children: [
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return AlbumPage(aid: album["aid"] ?? "");
                                  }));
                                },
                                child: ListTile(
                                  leading: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8)),
                                    width: 60,
                                    height: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        memCacheWidth: MediaQuery.of(context)
                                            .size
                                            .width
                                            .toInt(),
                                        useOldImageOnUrlChange:
                                            true, // 防止URL变化时立即刷新
                                        fit: BoxFit.cover,
                                        imageUrl: album["albumImg"] ?? "",
                                        // placeholder: (context, url) =>
                                        //     Image.asset(
                                        //         'assets/images/disc.png'),
                                      ),
                                    ),
                                  ),
                                  title: Text("${album["albumName"] ?? ""}"),
                                  subtitle: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      album["artist"] ?? ""),
                                ),
                              ),
                            ),
                            if (adRow % 10 == 0) BannerAd(),
                            Divider(
                              indent: 20,
                              endIndent: 20,
                              thickness: 0.3,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
