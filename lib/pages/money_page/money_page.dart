import 'package:flutter/material.dart';
import 'package:soda_music_flutter/utils/constants.dart';

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 150),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 感谢标题区域
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  "您的支持是我们前进的动力",
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 感谢说明卡片
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "为什么需要您的支持？",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: MainColor,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      "您的每一笔支持都将用于：",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    _buildSupportItem(Icons.person, "专业人员的持续开发与维护"),
                    _buildSupportItem(Icons.computer, "服务器与基础设施的升级"),
                    _buildSupportItem(Icons.update, "功能的持续优化与创新"),
                    const SizedBox(height: 12.0),
                    const Text(
                      "我们承诺将保持产品的纯净体验，您的支持纯粹是对我们团队的鼓励与肯定。",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              // 支持方式选择
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10.0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "支持方式",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // 支付方式选择
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPaymentOption(
                          icon: "assets/images/支付宝.jpg",
                          label: "支付宝",
                          onTap: () => _showPaymentDialog(
                              "支付宝", "assets/images/支付宝.jpg"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPaymentOption(
                          icon: "assets/images/微信.jpg",
                          label: "微信支付",
                          onTap: () => _showPaymentDialog(
                              "微信支付", "assets/images/微信.jpg"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建支持项目行
  Widget _buildSupportItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: MainColor, size: 20.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建支付选项卡片
  Widget _buildPaymentOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 280.0,
            height: 280.0,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
              border:
                  Border.all(color: Colors.red.withOpacity(0.3), width: 1.0),
            ),
            child: Image.asset(
              icon,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 显示支付弹窗
  void _showPaymentDialog(String paymentMethod, String image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("使用$paymentMethod支持我们"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "请使用$paymentMethod扫描下方二维码",
                style: const TextStyle(fontSize: 14.0),
              ),
              const SizedBox(height: 16.0),
              // 这里应该显示实际的支付二维码
              Container(
                width: 200.0,
                height: 200.0,
                color: Colors.grey[200],
                child: Center(child: Image.asset(image)),
              ),
              const SizedBox(height: 16.0),
              const Text(
                "金额随意，感谢支持！",
                style: TextStyle(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("已完成支付"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("取消"),
            ),
          ],
        );
      },
    );
  }
}
