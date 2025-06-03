import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static void showToast(BuildContext context, String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3), // 持续时间
        backgroundColor: Colors.brown, // 背景颜色
      ),
    );
  }

  static void showConfirmationDialog(BuildContext context, String title,
      String notice, Function confrimCallback, Function cancelCallback,
      [String confirmBtnStr = "确定", String cancelBtnStr = "取消"]) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(notice),
          actions: <Widget>[
            TextButton(
              child: Text(cancelBtnStr),
              onPressed: () {
                // 用户点击取消时关闭对话框
                cancelCallback();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(confirmBtnStr),
              onPressed: () {
                // 用户点击确认时的逻辑
                Navigator.of(context).pop();
                confrimCallback();
                // 关闭对话框
                // 这里可以添加确认后的操作
              },
            ),
          ],
        );
      },
    );
  }

  static void showConfirmationDialogLong(BuildContext context, String title,
      String notice, Function confrimCallback, Function cancelCallback,
      [String confirmBtnStr = "确定", String cancelBtnStr = "取消"]) {
    // 显示确认对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
              height: 300, child: SingleChildScrollView(child: Text(notice))),
          actions: <Widget>[
            TextButton(
              child: Text(cancelBtnStr),
              onPressed: () {
                // 用户点击取消时关闭对话框
                cancelCallback();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(confirmBtnStr),
              onPressed: () {
                // 用户点击确认时的逻辑
                Navigator.of(context).pop();
                confrimCallback();
                // 关闭对话框
                // 这里可以添加确认后的操作
              },
            ),
          ],
        );
      },
    );
  }
}
