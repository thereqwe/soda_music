import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_debouncer/flutter_debouncer.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soda_music_flutter/utils/api.dart';
import '../utils/constants.dart';
import '../utils/dialog_utils.dart';
import 'package:audio_session/audio_session.dart';
import 'dart:io' show Platform;
import 'package:just_audio/just_audio.dart';

enum MusicListType {
  none,
  album,
  random_heart,
}

enum QueuePlayMode {
  none,
  repeat_once,
  random,
  circle,
}

final QueuePlayModeKey = "QueuePlayModeKey";

class PlayerInstance with ChangeNotifier {
  var isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final player = AudioPlayer();
  var name = "";
  var img = "";
  var artist = "";
  var isShortcutExpend = false;
  var listenUrl = "";
  var musicList = [];
  var originalMusicList = [];
  var historyPlayIndexList = [];
  var musicListType = MusicListType.none;
  var nowPlayingIdx = 0;
  var playTimes = "";
  var linkMid = '';
  var source = '';
  var isLoading = false;
  var linkArtistIds = '';
  var linkAlbumId = '';
  QueuePlayMode queuePlayMode = QueuePlayMode.none;
  late final _session;

  //收藏
  late SharedPreferences prefs;
  List collectionList = [];

  Throttler throttler = Throttler();

  expandShortcut() {
    isShortcutExpend = true;
    notifyListeners();
  }

  playList() {
    name = musicList[nowPlayingIdx]["name"];
    img = musicList[nowPlayingIdx]["albumImg"];
    artist = musicList[nowPlayingIdx]["artist"];
    listenUrl = musicList[nowPlayingIdx]["listenUrl"];
    playTimes = musicList[nowPlayingIdx]["playTimes"];
    linkMid = musicList[nowPlayingIdx]["linkMid"];
    source = musicList[nowPlayingIdx]["source"];
    linkArtistIds = musicList[nowPlayingIdx]["linkArtistIds"];
    linkAlbumId = musicList[nowPlayingIdx]["linkAlbumId"];
    play(listenUrl);
    notifyListeners();
  }

  playPre() {
    nowPlayingIdx--;
    if (nowPlayingIdx < 0) {
      nowPlayingIdx = 0;
    }
    name = musicList[nowPlayingIdx]["name"];
    img = musicList[nowPlayingIdx]["albumImg"];
    artist = musicList[nowPlayingIdx]["artist"];
    listenUrl = musicList[nowPlayingIdx]["listenUrl"];
    playTimes = musicList[nowPlayingIdx]["playTimes"];
    linkMid = musicList[nowPlayingIdx]["linkMid"];
    source = musicList[nowPlayingIdx]["source"];
    linkArtistIds = musicList[nowPlayingIdx]["linkArtistIds"];
    linkAlbumId = musicList[nowPlayingIdx]["linkAlbumId"];
    play(listenUrl);
    notifyListeners();
  }

  playNext() {
    if (queuePlayMode == QueuePlayMode.random) {
      final random = Random();
      var i = 0;
      while (true) {
        if (i >= musicList.length) {
          nowPlayingIdx = historyPlayIndexList[0];
          historyPlayIndexList.clear();
          break;
        }
        i++;
        nowPlayingIdx = random.nextInt(musicList.length);
        if (historyPlayIndexList.contains(nowPlayingIdx)) {
          continue;
        } else {
          break;
        }
      }
    } else {
      nowPlayingIdx++;
    }
    if (nowPlayingIdx == musicList.length) {
      nowPlayingIdx = 0;
    }
    stop();
    name = musicList[nowPlayingIdx]["name"];
    img = musicList[nowPlayingIdx]["albumImg"];
    artist = musicList[nowPlayingIdx]["artist"];
    listenUrl = musicList[nowPlayingIdx]["listenUrl"];
    playTimes = musicList[nowPlayingIdx]["playTimes"];
    linkMid = musicList[nowPlayingIdx]["linkMid"];
    source = musicList[nowPlayingIdx]["source"];
    linkArtistIds = musicList[nowPlayingIdx]["linkArtistIds"];
    linkAlbumId = musicList[nowPlayingIdx]["linkAlbumId"];
    play(listenUrl);
    notifyListeners();
  }

  setMusicList(List val, MusicListType type, int startPlayIdx) {
    musicList = List.from(val);
    originalMusicList = List.from(val);
    musicListType = type;
    nowPlayingIdx = startPlayIdx;
    historyPlayIndexList.clear();

    notifyListeners();
  }

  shrinkShortcut() {
    isShortcutExpend = false;
    notifyListeners();
  }

  _collect(Map item) {
    for (var i = 0; i < collectionList.length; i++) {
      if (collectionList[i]["linkMid"] == item["linkMid"]) {
        return;
      }
    }
    collectionList.add(item);
    prefs.setString("collectionList", json.encode(collectionList));
    notifyListeners();
  }

  _deCollect(Map item) {
    for (var i = 0; i < collectionList.length; i++) {
      if (collectionList[i]["linkMid"] == item["linkMid"]) {
        collectionList.removeAt(i);
        prefs.setString("collectionList", json.encode(collectionList));
        notifyListeners();
      }
    }
  }

  toggleCollect(Map item) {
    if (judgeCollectionStatus(item["linkMid"])) {
      _deCollect(item);
    } else {
      _collect(item);
    }
  }

  judgeCollectionStatus(String linkMid) {
    for (var i = 0; i < collectionList.length; i++) {
      if (collectionList[i]["linkMid"] == linkMid) {
        return true;
      }
    }
    return false;
  }

  _setQueuePlayModeByCode(int val) {
    if (val == 1) {
      queuePlayMode = QueuePlayMode.circle;
    } else if (val == 2) {
      queuePlayMode = QueuePlayMode.random;
    } else if (val == 3) {
      queuePlayMode = QueuePlayMode.repeat_once;
    } else {
      queuePlayMode = QueuePlayMode.circle;
    }
    prefs.setInt(QueuePlayModeKey, val);
  }

  tooglePlayMode() {
    if (queuePlayMode == QueuePlayMode.repeat_once) {
      _setQueuePlayModeByCode(1); // chg->circle
    } else if (queuePlayMode == QueuePlayMode.circle) {
      _setQueuePlayModeByCode(2); // chg->random
    } else if (queuePlayMode == QueuePlayMode.random) {
      _setQueuePlayModeByCode(3); // chg->repeat once
    } else {
      _setQueuePlayModeByCode(2); // chg->random
    }
    notifyListeners();
  }

  getPlayModeImgPath() {
    if (queuePlayMode == QueuePlayMode.repeat_once) {
      return "assets/images/repeat-once.png";
    }
    if (queuePlayMode == QueuePlayMode.circle) {
      return "assets/images/repeat.png";
    }
    if (queuePlayMode == QueuePlayMode.random) {
      return "assets/images/shuffle.png";
    }
    return "assets/images/repeat.png";
  }

  var forcePause = false;
  PlayerInstance() {
    init() async {
      prefs = await SharedPreferences.getInstance();
      final ret = prefs.getString("collectionList");
      collectionList = json.decode(ret ?? "");

      int mode = prefs.getInt(QueuePlayModeKey) ?? 0;
      _setQueuePlayModeByCode(mode);

      _session = await AudioSession.instance;

      await _session.configure(AudioSessionConfiguration.music());
      await _session.setActive(true);

      // 监听音频中断事件
      _session.interruptionEventStream.listen((event) {
        if (event.type == AudioInterruptionType.pause && event.begin == true) {
          if (isPlaying == false) {
            forcePause = true;
          } else {
            forcePause = false;
          }
        } else if (event.type == AudioInterruptionType.pause &&
            event.begin == false) {
          if (forcePause == true) {
            player.pause();
            Future.delayed(Duration(seconds: 1), () {
              player.pause();
            });
          }
        } else if (event.type == AudioInterruptionType.duck) {
          print(event);
        } else {
          print(event);
        }
      });

      notifyListeners();
    }

    init();

    musicListType = MusicListType.none;
    // 获取音频时长
    player.durationStream.listen((newDuration) {
      duration = newDuration ?? const Duration(seconds: 0);
      notifyListeners();
    });

    // 获取音频播放位置
    player.positionStream.listen((newPosition) {
      if (!isPlaying) {
        player.pause();
        return;
      }
      // print("监控进度");
      // print(DateTime.now()); //
      // print(newPosition);
      position = newPosition;
      throttler.throttle(
          duration: const Duration(milliseconds: 1100),
          onThrottle: () {
            notifyListeners();
          });
    });

    if (isDebugMode) {
      //  player.setPlaybackRate(4);
    }

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (queuePlayMode == QueuePlayMode.random) {
          final random = Random();
          var i = 0;
          while (true) {
            if (i >= musicList.length) {
              nowPlayingIdx = historyPlayIndexList[0];
              historyPlayIndexList.clear();
              break;
            }
            i++;
            nowPlayingIdx = random.nextInt(musicList.length);
            if (historyPlayIndexList.contains(nowPlayingIdx)) {
              continue;
            } else {
              break;
            }
          }
        } else if (queuePlayMode == QueuePlayMode.repeat_once) {
          //nth
        } else {
          nowPlayingIdx++;
          if (nowPlayingIdx >= musicList.length) {
            nowPlayingIdx = 0;
          }
        }
        name = musicList[nowPlayingIdx]["name"];
        img = musicList[nowPlayingIdx]["albumImg"];
        artist = musicList[nowPlayingIdx]["artist"];
        listenUrl = musicList[nowPlayingIdx]["listenUrl"];
        playTimes = musicList[nowPlayingIdx]["playTimes"];
        linkMid = musicList[nowPlayingIdx]["linkMid"];
        source = musicList[nowPlayingIdx]["source"];
        linkArtistIds = musicList[nowPlayingIdx]["linkArtistIds"];
        linkAlbumId = musicList[nowPlayingIdx]["linkAlbumId"];
        play(listenUrl);
        notifyListeners();
      }
    });
  }

  setInfo(musicName, musicArtist, musicImg) {
    name = musicName;
    artist = musicArtist;
    img = musicImg;
    notifyListeners();
  }

  play(String url) async {
    // await player.stop();
    duration = Duration.zero;
    position = Duration.zero;

    if (historyPlayIndexList.contains(nowPlayingIdx) == false) {
      historyPlayIndexList.add(nowPlayingIdx);
    }
    // alger 的歌 地址是动态的
    final ret = await getAlgerListenUrl(linkMid);
    if (ret["code"].toString() != "0") {
      return;
    }
    url = ret["data"];
    isLoading = false;
    // notifyListeners();
    // await player.setUrl(url);

    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: linkMid,
          artist: artist,
          title: name,
          displayTitle: name,
          genre: "音乐",
          artUri: Uri.parse(img),
        ),
      ),
    );

    player.currentIndexStream.listen((index) {
      if (index != null) {
        print("当前播放第 ${index + 1} 首歌曲");
        // 在这里可以更新UI或其他逻辑
      }
    });

    player.play();
    isPlaying = true;
    listenUrl = url;
    position = Duration(seconds: 0);
    notifyListeners();
  }

  pause() async {
    await player.pause();
    isPlaying = false;
    notifyListeners();
  }

  //
  stop() async {
    await player.stop();
    isPlaying = false;
    notifyListeners();
  }

  resume() async {
    await player.play();
    isPlaying = true;
    notifyListeners();
  }

  void seekTo(Duration newPosition) async {
    await player.seek(newPosition);
  }
}
