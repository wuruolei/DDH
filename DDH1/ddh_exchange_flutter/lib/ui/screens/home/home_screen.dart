import 'package:flutter/material.dart';
import 'dart:ui';
import '../../widgets/customer_service_qr_view.dart';
import '../../../utils/color_scheme_manager.dart';

/// 精确对照DDHExchangeApp iOS HomeView.swift的Flutter实现
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final screenSize = MediaQuery.of(context).size;
    
    // 检测设备类型和屏幕尺寸 - 精确对照iOS
    final isIPad = screenSize.width > 768 && screenSize.height > 1024;

    return Scaffold(
      body: Stack(
        children: [
          // 背景渐变 - 精确对照iOS backgroundGradient
          _buildBackgroundGradient(context, brightness),
          // 主要内容 - 精确对照iOS mainContent
          _buildMainContent(context, isIPad, brightness),
        ],
      ),
      appBar: AppBar(
        title: const Text('点点换'),
        titleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: TextColors.adaptive(brightness),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TextColors.adaptive(brightness),
        actions: [
          TextButton(
            onPressed: () {
              // 显示客服二维码弹窗
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CustomerServiceQRView(),
              );
            },
            child: Text(
              '客服',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
    );
  }

  /// 构建背景渐变 - 精确对照iOS backgroundGradient
  Widget _buildBackgroundGradient(BuildContext context, Brightness brightness) {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 主页背景渐变 - 精确对照iOS
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: brightness == Brightness.dark
                    ? [
                        const Color.fromRGBO(13, 26, 38, 1.0),  // Color(red: 0.05, green: 0.10, blue: 0.15)
                        const Color.fromRGBO(26, 38, 56, 1.0),  // Color(red: 0.10, green: 0.15, blue: 0.22)
                      ]
                    : [
                        const Color.fromRGBO(245, 250, 255, 1.0),  // Color(red: 0.96, green: 0.98, blue: 1.0)
                        const Color.fromRGBO(235, 242, 250, 1.0),  // Color(red: 0.92, green: 0.95, blue: 0.98)
                      ],
              ),
            ),
          ),
          // 中心光晕效果 - 精确对照iOS RadialGradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: brightness == Brightness.dark
                      ? [Colors.blue.withOpacity(0.2), Colors.transparent]
                      : [Colors.blue.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // 装饰性气泡1（青色）- 精确对照iOS Circle位置和颜色
          Positioned(
            right: screenSize.width * 0.2,  // offset(x: geometry.size.width * 0.3)
            top: screenSize.height * 0.15,   // offset(y: -geometry.size.height * 0.2)
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: brightness == Brightness.dark
                      ? [
                          Colors.cyan.withOpacity(0.15),
                          Colors.cyan.withOpacity(0.05),
                          Colors.transparent,
                        ]
                      : [
                          Colors.cyan.withOpacity(0.08),
                          Colors.cyan.withOpacity(0.02),
                          Colors.transparent,
                        ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(),
              ),
            ),
          ),
          // 装饰性气泡2（紫色）- 精确对照iOS Circle位置和颜色
          Positioned(
            left: screenSize.width * 0.1,    // offset(x: -geometry.size.width * 0.3)
            bottom: screenSize.height * 0.2, // offset(y: geometry.size.height * 0.3)
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: brightness == Brightness.dark
                      ? [
                          Colors.purple.withOpacity(0.12),
                          Colors.purple.withOpacity(0.04),
                          Colors.transparent,
                        ]
                      : [
                          Colors.purple.withOpacity(0.06),
                          Colors.purple.withOpacity(0.02),
                          Colors.transparent,
                        ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容 - 精确对照iOS mainContent
  Widget _buildMainContent(BuildContext context, bool isIPad, Brightness brightness) {
    if (isIPad) {
      return _buildIPadLayout(context, isIPad, brightness);
    } else {
      return _buildIPhoneLayout(context, isIPad, brightness);
    }
  }

  /// iPad布局 - 精确对照iOS iPadLayout
  Widget _buildIPadLayout(BuildContext context, bool isIPad, Brightness brightness) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20), // 添加顶部间距，避免被导航栏遮挡
            _buildContentArea(context, isIPad, brightness),
            const SizedBox(height: 40), // 底部间距
          ],
        ),
      ),
    );
  }

  /// iPhone布局 - 精确对照iOS iPhoneLayout
  Widget _buildIPhoneLayout(BuildContext context, bool isIPad, Brightness brightness) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),
          _buildContentArea(context, isIPad, brightness),
          const Spacer(),
        ],
      ),
    );
  }

  /// 内容区域 - 精确对照iOS contentArea
  Widget _buildContentArea(BuildContext context, bool isIPad, Brightness brightness) {
    return Column(
      children: [
        _buildTitleSection(context, isIPad, brightness),
        const SizedBox(height: 30),
        _buildQRCodeSection(context, isIPad, brightness),
        const SizedBox(height: 30),
        _buildFeaturesSection(context, isIPad, brightness),
      ],
    );
  }

  /// 标题区域 - 精确对照iOS titleSection
  Widget _buildTitleSection(BuildContext context, bool isIPad, Brightness brightness) {
    return Column(
      children: [
        Text(
          '欢迎使用点点换',
          style: TextStyle(
            fontSize: isIPad ? 32 : 28,
            fontWeight: FontWeight.bold,
            color: TextColors.adaptive(brightness),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '专业的数字货币兑换服务平台\n安全、快速、便捷',
          style: TextStyle(
            fontSize: isIPad ? 18 : 16,
            color: TextColors.adaptiveSecondary(brightness),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 二维码区域 - 精确对照iOS qrCodeSection
  Widget _buildQRCodeSection(BuildContext context, bool isIPad, Brightness brightness) {
    return Column(
      children: [
        // 微信二维码区域 - 根据设备调整大小，精确对照iOS
        Container(
          width: isIPad ? 350 : 250,
          height: isIPad ? 350 : 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: _buildQRCodeContent(isIPad),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          '扫一扫添加客服微信',
          style: TextStyle(
            fontSize: isIPad ? 20 : 16,  // title3 : body
            fontWeight: FontWeight.w500,  // .medium
            color: TextColors.adaptive(brightness),
          ),
        ),
      ],
    );
  }

  /// 构建二维码内容 - 精确对照iOS逻辑
  Widget _buildQRCodeContent(bool isIPad) {
    // 优先显示真实二维码图片，否则显示占位符
    // 这里模拟iOS的逻辑：if let qrImage = UIImage(named: "wechat_qrcode")
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code,
          size: isIPad ? 80 : 60,
          color: Colors.grey,
        ),
        const SizedBox(height: 8),
        Text(
          '客服二维码',
          style: TextStyle(
            fontSize: isIPad ? 16 : 12,  // body : caption
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 特色功能区域 - 精确对照iOS featuresSection
  Widget _buildFeaturesSection(BuildContext context, bool isIPad, Brightness brightness) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isIPad ? 20 : 0),
      child: Column(
        children: [
          Text(
            '服务特色',
            style: TextStyle(
              fontSize: isIPad ? 28 : 20,  // title2 : title3
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(brightness),
            ),
          ),
          SizedBox(height: isIPad ? 20 : 16),
          Column(
            children: [
              ServiceFeatureRow(
                icon: 'shield.fill',
                title: '安全保障',
                description: '专业团队提供安全可靠的服务保障',
                color: Colors.green,
                isIPad: isIPad,
                brightness: brightness,
              ),
              SizedBox(height: isIPad ? 16 : 12),
              ServiceFeatureRow(
                icon: 'clock.fill',
                title: '快速响应',
                description: '7×24小时在线客服，快速解决问题',
                color: Colors.blue,
                isIPad: isIPad,
                brightness: brightness,
              ),
              SizedBox(height: isIPad ? 16 : 12),
              ServiceFeatureRow(
                icon: 'heart.fill',
                title: '贴心服务',
                description: '一对一专属客服，提供贴心个性化服务',
                color: Colors.red,
                isIPad: isIPad,
                brightness: brightness,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 服务特色行组件 - 精确对照iOS ServiceFeatureRow
class ServiceFeatureRow extends StatelessWidget {
  final String icon;  // 改为String以支持SF Symbols名称
  final String title;
  final String description;
  final Color color;
  final bool isIPad;
  final Brightness brightness;

  const ServiceFeatureRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isIPad,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIPad ? 20 : 16,
        vertical: isIPad ? 14 : 10,
      ),
      decoration: BoxDecoration(
        color: BackgroundColors.adaptiveSecondary(brightness).withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // 图标区域 - 精确对照iOS frame(width:)
          SizedBox(
            width: isIPad ? 32 : 24,
            child: _buildIcon(),
          ),
          SizedBox(width: isIPad ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isIPad ? 20 : 16,  // title3 : body
                    fontWeight: FontWeight.w500,  // .medium
                    color: TextColors.adaptive(brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isIPad ? 16 : 12,  // body : caption
                    color: TextColors.adaptiveSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),  // 对照iOS中的Spacer()
        ],
      ),
    );
  }

  /// 构建图标 - 映射SF Symbols到Flutter Icons
  Widget _buildIcon() {
    IconData iconData;
    switch (icon) {
      case 'shield.fill':
        iconData = Icons.shield;
        break;
      case 'clock.fill':
        iconData = Icons.access_time;
        break;
      case 'heart.fill':
        iconData = Icons.favorite;
        break;
      default:
        iconData = Icons.help_outline;
    }
    
    return Icon(
      iconData,
      size: isIPad ? 28 : 20,  // title2 : title3
      color: color,
    );
  }
}
