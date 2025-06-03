void pp(dynamic a, [dynamic b, dynamic c]) {
  print("wow" + a.toString() + "____" + b.toString() + "___" + c.toString());
}

String convertTime(String timeInput) {
  int minutes = 0;
  int seconds = 0;

  if (timeInput.contains(':')) {
    List<String> parts = timeInput.split(':');
    if (parts.length == 3) {
      minutes = int.parse(parts[1]) + int.parse(parts[0]) * 60;
      seconds = int.parse(parts[2]);
    } else if (parts.length == 2) {
      minutes = int.parse(parts[0]);
      seconds = int.parse(parts[1]);
    } else {
      throw ArgumentError('输入的时间格式不正确，请输入 00:03:01 或 03:01 格式的字符串');
    }
  } else {
    try {
      int totalSeconds = int.parse(timeInput);
      minutes = totalSeconds ~/ 60;
      seconds = totalSeconds % 60;
    } catch (e) {
      throw ArgumentError('输入的秒数格式不正确，请输入有效的整数秒数');
    }
  }

  String formattedMinutes = minutes.toString().padLeft(2, '0');
  String formattedSeconds = seconds.toString().padLeft(2, '0');
  return '$formattedMinutes:$formattedSeconds';
}

String formatMilliseconds2YMD(String millisecondsStr) {
  try {
    // 将字符串转换为毫秒数
    final milliseconds = int.parse(millisecondsStr);

    // 创建 DateTime 对象
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);

    // 提取年、月、日
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0'); // 补零
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  } catch (e) {
    print('日期格式化错误: $e');
    return '无效日期';
  }
}
