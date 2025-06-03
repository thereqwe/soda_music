import 'package:soda_music_flutter/utils/utils.dart';

import 'network_service.dart';

Future getMusics() async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getMusics",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getMusicDetail(String mid) async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getMusicDetail&mid=$mid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getHotAlbums() async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getHotAlbums",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getClassicAlbums() async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getClassicAlbums",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getAlbumDetail(String aid) async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getAlbumDetail&aid=$aid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

// 1451296804196
Future getMusicInAlbum(String aid) async {
  print("wow api2");
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getMusicInAlbum&aid=$aid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getRandomMusics() async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getRandomMusics",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getPack(String category) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getPack&category=$category",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getAlgerListenUrl(String linkMid) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getAlgerListenUrl&linkMid=$linkMid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getPackDetail(String pid) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getPackDetail&pid=$pid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getMusicInPack(String pid) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getMusicInPack&pid=$pid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future searchMusic(String searchRegStr, String str) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=searchMusic&searchRegStr=$searchRegStr",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future searchPack(String searchRegStr, String str) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=searchPack&searchRegStr=$searchRegStr",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future searchAlbum(String searchRegStr, String str) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=searchAlbum&searchRegStr=$searchRegStr",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getStar(String linkArtistId) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getStar&linkArtistId=$linkArtistId",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getStarAlbums(String linkArtistId) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getStarAlbums&linkArtistId=$linkArtistId",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getStarSongs(String linkArtistId) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getStarSongs&linkArtistId=$linkArtistId",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

//searchStar
Future searchStar(String searchRegStr, String str) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=searchStar&searchRegStr=$searchRegStr",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

//searchStar
Future getLyric(String linkMid) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getLyric&linkMid=$linkMid",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

Future getHotStars() async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getHotStars",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

//getCategoryMusics

Future getCategoryMusics(String category) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getCategoryMusics&category=$category",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}

//getAlbumLinkIdByAid
Future getAidByAlbumLinkId(String linkAlbumId) async {
  try {
    final r = await NetworkService().get(
        "music_action.php"
        "?action=getAidByAlbumLinkId&linkAlbumId=$linkAlbumId",
        {});
    return r;
  } catch (e) {
    pp(e);
  }
}
