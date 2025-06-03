import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/pages/packPage/pack_page.dart';
import 'package:soda_music_flutter/utils/api.dart';
import 'package:soda_music_flutter/widget/banner_ad.dart';

import '../../model/player.dart';
import '../../utils/constants.dart';
import '../../utils/dialog_utils.dart';
// 假设其他导入语句已正确配置

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpanded = false;
  String selectedCategory = "流行";
  List itemList = [];

  // 示例分类列表，根据实际情况调整

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      selectedCategory = category;
      isExpanded = false;
    });
    _getPack();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPack();
  }

  _getPack() async {
    final ret = await getPack(selectedCategory);
    if (ret["code"].toString() != "0") {
      DialogUtils.showToast(context, "data失败");
      return;
    }
    final arr = ret["data"] as List;
    itemList.clear();
    arr.forEach((item) {
      itemList.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("歌单分类"),
        backgroundColor: Colors.white,
        actions: [
          Container(
            child: GestureDetector(
              onTap: _toggleExpand,
              child: Row(
                children: [
                  Text(selectedCategory),
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 8,
          )
        ],
      ),
      body: Consumer<PlayerInstance>(builder: (context, player, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   //  height: 40,
            //   color: Color.fromRGBO(250, 250, 250, 1),
            //   child: ListTile(
            //     dense: true,
            //     // contentPadding: EdgeInsets.zero,
            //     title: Text("筛选:" + (selectedCategory ?? '选择分类')),
            //     trailing: Icon(
            //       isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            //     ),
            //     onTap: _toggleExpand,
            //   ),
            // ),
            if (isExpanded)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5, // 设置每行显示3个项目
                    mainAxisSpacing: 8.0, // 主轴间距
                    crossAxisSpacing: 8.0, // 交叉轴间距
                    childAspectRatio: 1.5, // 子项宽高比
                  ),
                  itemCount: categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryList[index];
                    return InkWell(
                      onTap: () => _selectCategory(category),
                      child: Card(
                        color: category == selectedCategory
                            ? MainColor
                            : Colors.white70,
                        elevation: 1.0,
                        child: Center(
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: category == selectedCategory
                                    ? Colors.white70
                                    : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 每行的列数
                ),
                itemCount: itemList.length,
                itemBuilder: (context, idx) {
                  return foo2(context, idx);
                },
              ),
            ),
            const BannerAd()
          ],
        );
      }),
    );
  }

  foo(context, idx) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PackPage(
            pid: itemList[idx]["pid"],
            packImg: itemList[idx]["packImg"],
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: Center(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Hero(
                  tag: itemList[idx]["pid"],
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.cover,
                    imageUrl: itemList[idx]["packImg"] ?? "",
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  child: Container(
                    color: Color.fromRGBO(34, 179, 34, 0.5),
                    width: MediaQuery.of(context).size.width / 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        itemList[idx]["packName"],
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
                  ))
            ],
          ),
        ),
      ),
    );
  }

  foo2(context, idx) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PackPage(
            pid: itemList[idx]["pid"],
            packImg: itemList[idx]["packImg"],
          );
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                    child: Hero(
                      tag: itemList[idx]["pid"],
                      child: CachedNetworkImage(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.cover,
                        imageUrl: itemList[idx]["packImg"] ?? "",
                      ),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                      color: Color.fromRGBO(34, 179, 34, 0.5),
                      width: MediaQuery.of(context).size.width / 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          itemList[idx]["packName"],
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
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
