import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jieba_flutter/analysis/jieba_segmenter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/pages/album_page/album_page.dart';
import 'package:soda_music_flutter/pages/packPage/pack_page.dart';
import 'package:soda_music_flutter/pages/play_page.dart';
import 'package:soda_music_flutter/pages/star_page/star_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/utils/constants.dart';
import 'package:soda_music_flutter/utils/utils.dart';

import '../../utils/dialog_utils.dart';

// 统一的搜索结果项模型
enum SearchItemType { music, album, pack, star }

String searchHistoryKey = "searchHistoryKey";

class SearchResultItem {
  final SearchItemType type;
  final dynamic data;

  SearchResultItem(this.type, this.data);

  // 根据类型获取标题
  String get title {
    switch (type) {
      case SearchItemType.music:
        return data["name"] ?? "未知歌曲";
      case SearchItemType.album:
        return data["albumName"] ?? "未知专辑";
      case SearchItemType.pack:
        return data["packName"] ?? "未知歌单";
      case SearchItemType.star:
        return data["starName"] ?? "未知歌手";
    }
  }

  // 根据类型获取副标题
  String get subtitle {
    switch (type) {
      case SearchItemType.music:
        return data["artist"] ?? "未知艺术家";
      case SearchItemType.album:
        return data["artist"] ?? "未知艺术家";
      case SearchItemType.star:
        return data["starDesc"] ?? ""; // 歌手简介
      case SearchItemType.pack:
        return "";
    }
  }

  // 根据类型获取图片URL
  String get imageUrl {
    switch (type) {
      case SearchItemType.music:
        return data["albumImg"] ?? "";
      case SearchItemType.album:
        return data["albumImg"] ?? "";
      case SearchItemType.star:
        return data["starImg"] ?? ""; // 歌手头像
      case SearchItemType.pack:
        return data["packImg"] ?? "";
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final List<SearchResultItem> _searchResults = [];
  List<String> searchHistoryList = [];
  late SharedPreferences prefs;
  final suggestList = [
    "周杰伦",
    "林俊杰",
    "五月天",
    "周深",
    "邓紫棋",
    "薛之谦",
    "王力宏",
    "陶喆",
    "张学友",
    "梁静茹",
    "孙燕姿"
  ];

  TextEditingController _searchController = TextEditingController();
  late JiebaSegmenter seg;
  bool _isLoading = false;
  late TabController _tabController;

  // 分类结果存储
  final Map<SearchItemType, List<SearchResultItem>> _categorizedResults = {
    SearchItemType.music: [],
    SearchItemType.album: [],
    SearchItemType.pack: [],
    SearchItemType.star: [],
  };

  @override
  void initState() {
    super.initState();
    init();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  init() async {
    prefs = await SharedPreferences.getInstance();
    var a = prefs.getStringList(searchHistoryKey);
    searchHistoryList = prefs.getStringList(searchHistoryKey) ?? [];
    for (var i = 0; i < searchHistoryList.length; i++) {
      for (var j = 0; j < suggestList.length; j++) {
        if (suggestList[j] == searchHistoryList[i]) {
          suggestList.removeAt(j);
        }
      }
    }
    setState(() {});
    await JiebaSegmenter.init().then((value) {
      seg = JiebaSegmenter();
    });
  }

  void _search() async {
    setState(() {
      _categorizedResults.forEach((key, value) => value.clear());
      _searchResults.clear();
      _isLoading = true;
    });

    final str = _searchController.text;
    if (str.isEmpty) return;
    searchHistoryList.remove(str);
    searchHistoryList.insert(0, str);
    prefs.setStringList(searchHistoryKey, searchHistoryList);
    for (var i = 0; i < searchHistoryList.length; i++) {
      for (var j = 0; j < suggestList.length; j++) {
        if (suggestList[j] == searchHistoryList[i]) {
          suggestList.removeAt(j);
        }
      }
    }

    final ret = seg.process(str, SegMode.SEARCH);
    final list = [str];
    ret.forEach((val) {
      if (val.word.length > 1) {
        list.add(val.word);
      }
    });
    final searchRegStr = list.join("|");
    //  DialogUtils.showToast(context, list.join("|"));

    try {
      // 并行请求提高效率（假设searchStar为歌手搜索API）
      final results = await Future.wait([
        searchPack(searchRegStr, str), // 歌单
        searchMusic(searchRegStr, str), // 歌曲
        searchAlbum(searchRegStr, str), // 专辑
        searchStar(searchRegStr, str), // 歌手
      ]);

      // 处理歌单结果
      _handleResult(SearchItemType.pack, results[0]);
      // 处理歌曲结果
      _handleResult(SearchItemType.music, results[1]);
      // 处理专辑结果
      _handleResult(SearchItemType.album, results[2]);
      // 处理歌手结果
      _handleResult(SearchItemType.star, results[3]);
    } catch (e) {
      DialogUtils.showToast(context, "搜索过程中发生错误: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 统一结果处理方法
  void _handleResult(SearchItemType type, dynamic result) {
    if (result["code"].toString() == "0") {
      final arr = result["data"] as List;
      arr.forEach((item) {
        _categorizedResults[type]?.add(SearchResultItem(type, item));
        _searchResults.add(SearchResultItem(type, item));
      });
    } else {
      DialogUtils.showToast(context, "获取${_getCategoryName(type)}数据失败");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 30,
          child: TextField(
            controller: _searchController,
            onSubmitted: (val) => _search(),
            onChanged: (val) => setState(() {}),
            textInputAction: TextInputAction.search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "寻找好听的音乐...",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() {
                        _searchController.clear();
                        _searchResults.clear();
                        _categorizedResults
                            .forEach((key, value) => value.clear());
                      }),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        // 仅在有搜索内容时显示TabBar
        bottom: _searchResults.isNotEmpty
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "歌曲"),
                  Tab(text: "专辑"),
                  Tab(text: "歌单"),
                  Tab(text: "歌手"),
                ],
                indicatorColor: MainColor,
                labelColor: MainColor,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 2,
              )
            : null,
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        return Column(
          children: [
            // 搜索建议
            _searchResults.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: (searchHistoryList + suggestList).map((str) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            _searchController.text = str;
                            _search();
                          }),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.withOpacity(0.1),
                            ),
                            child: Text(str),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox(),

            // 加载指示器
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(),

            // 分类内容区域
            _searchResults.isNotEmpty
                ? Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCategoryList(SearchItemType.music),
                        _buildCategoryList(SearchItemType.album),
                        _buildCategoryList(SearchItemType.pack),
                        _buildCategoryList(SearchItemType.star),
                      ],
                    ),
                  )
                : const SizedBox(),
          ],
        );
      }),
    );
  }

  // 通用分类列表构建方法
  Widget _buildCategoryList(SearchItemType type) {
    final items = _categorizedResults[type];
    return items!.isEmpty && _searchController.text.isNotEmpty && !_isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text("没有找到相关${_getCategoryName(type)}",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildGridItem(item, type);
            },
          );
  }

  // 构建不同类型的GridItem
  Widget _buildGridItem(SearchResultItem item, SearchItemType type) {
    return GestureDetector(
      onTap: () => _handleItemTap(item, type),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片部分
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                imageUrl: item.imageUrl,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: type == SearchItemType.star
                        ? const Icon(Icons.person)
                        : const Icon(Icons.music_note),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: type == SearchItemType.star
                        ? const Icon(Icons.person_outline)
                        : const Icon(Icons.error_outline),
                  ),
                ),
              ),
            ),
            // 文本部分
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: type == SearchItemType.pack ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (type != SearchItemType.pack) const SizedBox(height: 4),
                  if (type != SearchItemType.pack)
                    Text(
                      item.subtitle,
                      maxLines: type == SearchItemType.star ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  if (type != SearchItemType.pack) const SizedBox(height: 4),
                  _buildTypeIndicator(type, item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建类型指示器
  Widget _buildTypeIndicator(SearchItemType type, SearchResultItem item) {
    switch (type) {
      case SearchItemType.music:
        return Row(
          children: [
            const Icon(Icons.music_note, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              convertTime(item.data["playTimes"] ?? 0),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        );
      case SearchItemType.album:
        return Row(
          children: [
            const Icon(Icons.album, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            const Text("专辑",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        );
      case SearchItemType.pack:
        return Row(
          children: [
            const Icon(Icons.playlist_play, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            const Text("歌单",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        );
      case SearchItemType.star:
        return Row(
          children: [
            const Icon(Icons.person, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            const Text("歌手",
                style: TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  // 处理点击事件
  void _handleItemTap(SearchResultItem item, SearchItemType type) {
    switch (type) {
      case SearchItemType.music:
        _handleMusicTap(item, type);
        break;
      case SearchItemType.album:
        _handleAlbumTap(item, type);
        break;
      case SearchItemType.pack:
        _handlePackTap(item, type);
        break;
      case SearchItemType.star:
        _handleStarTap(item, type);
        break;
    }
  }

  // 处理音乐点击
  void _handleMusicTap(SearchResultItem item, SearchItemType type) {
    final player = Provider.of<PlayerInstance>(context, listen: false);
    player.musicList.insert(player.nowPlayingIdx, item.data);
    player.setMusicList(
      player.musicList,
      MusicListType.album,
      player.nowPlayingIdx,
    );
    player.playList();
  }

  // 处理专辑点击
  void _handleAlbumTap(SearchResultItem item, SearchItemType type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AlbumPage(aid: item.data["aid"]),
    ));
  }

  // 处理歌单点击
  void _handlePackTap(SearchResultItem item, SearchItemType type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PackPage(
        pid: item.data["pid"],
        packImg: item.data["packImg"] ?? "",
      ),
    ));
  }

  // 处理歌手点击
  void _handleStarTap(SearchResultItem item, SearchItemType type) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StarPage(
        linkArtistId: item.data["linkArtistId"],
      ),
    ));
  }

  // 获取分类名称
  String _getCategoryName(SearchItemType type) {
    switch (type) {
      case SearchItemType.music:
        return "歌曲";
      case SearchItemType.album:
        return "专辑";
      case SearchItemType.pack:
        return "歌单";
      case SearchItemType.star:
        return "歌手";
      default:
        return "";
    }
  }
}
