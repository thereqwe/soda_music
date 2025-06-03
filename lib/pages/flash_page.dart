import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soda_music_flutter/utils/dialog_utils.dart';
//import 'package:torch_flashlight/torch_flashlight.dart';

import 'notice_page/setting_page.dart';

class FlashPage extends StatefulWidget {
  const FlashPage({super.key});

  @override
  State<FlashPage> createState() => _FlashPageState();
}

class _FlashPageState extends State<FlashPage> {
  bool isFlashlightOn = false;

  @override
  void initState() {
    late SharedPreferences prefs;
    // TODO: implement initState
    super.initState();
    init() async {
      //  await TorchControl.ready();
      prefs = await SharedPreferences.getInstance();
      var isAgree = prefs.getBool("agree") ?? false;
      if (isAgree == false) {
        final notice = """
小信标用户使用及隐私安全协议

欢迎使用上海露懿科技有限公司旗下产品《小信标》！在您使用本应用前，请仔细阅读本协议。本协议旨在明确您与《小信标》之间的权利与义务，并保障您的个人信息安全。您的注册、登录及使用行为即视为您已阅读、理解并同意本协议的所有条款。

一、用户使用条款

1.1 服务内容
《小信标》所有用户均可免费访问全部内容，我们通过广告投放获取收入，未来不会加入任何内购项目。

1.2 用户权利与义务
1. 用户权利：您有权免费使用本应用的所有功能，并享受我们提供的历史学习服务。
2. 用户义务：您不得利用本应用从事任何违法活动，包括但不限于传播虚假信息、侵犯他人知识产权、破坏应用正常运行等。

1.3 账号管理
1. 账号注册：您可以通过手机号、邮箱或第三方平台账号注册。
2. 账号安全：您应妥善保管账号信息，并对因账号泄露导致的损失负责。如发现账号异常，请及时联系客服处理。

1.4 服务变更与终止
1. 服务变更：我们可能根据实际情况调整服务内容，并通过公告或通知告知用户。
2. 服务终止：如您不再需要使用本应用，可自行注销账号。我们保留在特定情况下终止服务的权利。

二、隐私安全条款

# 2.1 信息收集
我们仅收集实现应用功能所必需的信息，包括：
1. 设备信息：如设备型号、操作系统版本、设备识别码（如IMEI、IMSI、MAC地址）。
2. 使用数据：如浏览记录、点击行为、IP地址等。
3. 位置信息：当您使用与位置相关的功能时，我们会获取您的地理位置信息。

2.2 信息使用
1. 服务提供：我们使用您的信息为您提供个性化内容、优化用户体验及保障账号安全。
2. 广告投放：我们可能根据您的使用数据展示相关广告，但不会将您的个人信息直接提供给广告商。

2.3 信息保护
我们采取以下措施保护您的信息安全：
1. 技术措施：使用加密传输、访问控制等技术手段防止信息泄露。
2. 管理措施：对员工进行隐私保护培训，并定期进行合规审查。

2.4 信息共享与披露
1. 共享范围：未经您同意，我们不会向第三方共享您的个人信息，除非法律法规另有规定。
2. 披露情形：在以下情况下，我们可能披露您的信息：
    - 根据法律法规或政府机构的要求；
    - 为维护本应用的合法权益。

# 2.5 用户权利
1. 访问与更正：您有权访问和更正您的个人信息。
2. 删除与注销：您可要求删除个人信息或注销账号，我们将及时处理。
3. 撤回同意：您可随时撤回对信息处理的授权，但可能影响部分功能的使用。

三、其他条款

3.1 协议修改
我们可能根据需要修改本协议，并通过公告或通知告知用户。如您不同意修改后的条款，请停止使用本应用。

3.2 争议解决
如因本协议产生争议，双方应通过友好协商解决；协商不成的，可向有管辖权的人民法院提起诉讼。

3.3 法律适用
本协议的订立、履行及解释均适用中华人民共和国法律。

感谢您阅读《小信标用户使用及隐私安全协议》！ 如有任何疑问，请通过以下方式联系我们：
- thereqwe@qq.com
- QQ：523489996

《小信标》团队
2025年3月25日
      """;
        DialogUtils.showConfirmationDialogLong(context, "注意", notice, () {
          prefs.setBool("agree", true);
        }, () {
          _exitApp();
        }, "同意", "不同意");
      }
    }

    init();
  }

  void _exitApp() async {
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("小信标"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return SettingPage();
                }));
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: Container(
        color: Colors.yellow,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFlashlightOn ? Icons.flashlight_on : Icons.flashlight_off,
                size: 100,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!isFlashlightOn) {
                    //await TorchFlashlight.enableTorchFlashlight();
                    isFlashlightOn = !isFlashlightOn;
                    setState(() {});
                  } else {
                    // await TorchFlashlight.disableTorchFlashlight();
                    isFlashlightOn = !isFlashlightOn;
                    setState(() {});
                  }
                },
                child: Text(isFlashlightOn ? '关闭手电筒' : '打开手电筒'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
