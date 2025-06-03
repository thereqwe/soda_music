import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soda_music_flutter/model/player.dart';
import 'package:soda_music_flutter/utils/constants.dart';

import '../../utils/api.dart';

class LyricsPage extends StatefulWidget {
  final String linkMid;
  final String name;

  const LyricsPage({
    Key? key,
    required this.linkMid,
    required this.name,
  }) : super(key: key);

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  List<LyricLine> lyricLines = [];
  int currentLineIndex = 0;
  double scrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    init() async {
      final ret = await getLyric(widget.linkMid);
      final String lyrics = ret["data"];

      lyricLines = _parseLyrics(lyrics);
      setState(() {});
      _setupPositionListener();
    }

    init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _positionSubscription.cancel();
    super.dispose();
  }

  // 解析歌词文本
  List<LyricLine> _parseLyrics(String lyrics) {
    List<LyricLine> lines = [];
    final regex = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');

    // 先处理元数据行（作词、作曲等）
    final metadataRegex = RegExp(r'\[(\d+:\d+\.\d+)\]\s*([^\n]+)');
    lyrics.split('\n').forEach((line) {
      final metadataMatch = metadataRegex.firstMatch(line);
      if (metadataMatch != null &&
          (metadataMatch.group(2)?.contains('作词') ??
              false || metadataMatch.group(2)!.contains('作曲') ??
              false)) {
        lines.add(LyricLine(
          timeInMilliseconds: 0,
          text: metadataMatch.group(2)!,
          isMetadata: true,
        ));
      }
    });

    // 处理歌词行
    final lyricRegex = RegExp(r'\[(\d+):(\d+)\.(\d+)\](.*)');
    lyrics.split('\n').forEach((line) {
      final match = lyricRegex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds =
            int.parse(match.group(3)!.padRight(3, '0').substring(0, 3));
        final text = match.group(4)?.trim() ?? '';

        if (text.isNotEmpty) {
          lines.add(LyricLine(
            timeInMilliseconds:
                minutes * 60 * 1000 + seconds * 1000 + milliseconds,
            text: text,
          ));
        }
      }
    });

    return lines;
  }

  late StreamSubscription<Duration> _positionSubscription;
  // 设置播放位置监听器
  void _setupPositionListener() {
    // 延迟到组件构建完成后再获取context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final player = Provider.of<PlayerInstance>(context, listen: false);

      // _positionSubscription =
      //     player.player.onPositionChanged.listen((newPosition) {
      //   _updateCurrentLine(newPosition);
      // });

      // just audio
      player.player.positionStream.listen((newDuration) {
        _updateCurrentLine(newDuration);
      });
    });
  }

  // 更新当前播放的歌词行
  void _updateCurrentLine(Duration position) {
    final positionInMillis = position.inMilliseconds;
    int newIndex = 0;

    // 查找当前应该显示的歌词行
    for (int i = 0; i < lyricLines.length; i++) {
      if (!lyricLines[i].isMetadata &&
          lyricLines[i].timeInMilliseconds <= positionInMillis) {
        newIndex = i;
      }
    }

    // 如果索引变化了，更新状态
    if (newIndex != currentLineIndex) {
      setState(() {
        currentLineIndex = newIndex;
        _scrollToCurrentLine();
      });
    }
  }

  // 滚动到当前歌词行
  // 滚动到当前歌词行
  void _scrollToCurrentLine() {
    if (_scrollController.hasClients) {
      // 计算目标滚动位置，使当前行居中显示
      final double targetOffset = currentLineIndex * 40.0; // 假设每行高度约为40像素

      // 平滑滚动到目标位置
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(34, 179, 34, 1),
              Color.fromRGBO(34, 179, 34, 0.5)
            ],
          ),
        ),
        child: Center(
          child: Consumer<PlayerInstance>(builder: (context, player, _) {
            return Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top - 40),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: lyricLines.length,
                itemBuilder: (context, index) {
                  final line = lyricLines[index];
                  final isCurrent = index == currentLineIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      line.text,
                      style: TextStyle(
                        fontSize: line.isMetadata ? 14 : 18,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? Colors.yellowAccent
                            : line.isMetadata
                                ? Colors.grey
                                : Colors.white,
                        shadows: isCurrent
                            ? [const Shadow(color: Colors.black, blurRadius: 5)]
                            : [],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

// 歌词行数据模型
class LyricLine {
  final int timeInMilliseconds;
  final String text;
  final bool isMetadata;

  const LyricLine({
    required this.timeInMilliseconds,
    required this.text,
    this.isMetadata = false,
  });
}
