import 'package:flutter/material.dart';
import '../../../utils/color_scheme_manager.dart';

/// WebViewScreen - 通用网页浏览组件
/// 用于显示隐私政策、服务条款、帮助文档等网页内容
class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final String? content; // 可选的本地HTML内容

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    this.content,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // 模拟加载过程
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '加载失败，请检查网络连接';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TextColors.adaptive(brightness),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '完成',
              style: TextStyle(
                color: TextColors.adaptiveSecondary(brightness),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: BackgroundColors.adaptive(brightness),
        child: _buildContent(brightness),
      ),
    );
  }

  Widget _buildContent(Brightness brightness) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorView(brightness);
    }

    return _buildWebContent(brightness);
  }

  Widget _buildErrorView(Brightness brightness) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 16,
              color: TextColors.adaptiveSecondary(brightness),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadContent();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent(Brightness brightness) {
    // 由于Flutter Web的限制，这里使用模拟内容
    // 在实际应用中，可以使用webview_flutter包来显示真实网页
    
    String displayContent = widget.content ?? _getDefaultContent();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: TextColors.adaptive(brightness),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                displayContent,
                style: TextStyle(
                  fontSize: 16,
                  color: TextColors.adaptive(brightness),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultContent() {
    switch (widget.title) {
      case '隐私政策':
        return _getPrivacyPolicyContent();
      case '服务条款':
        return _getTermsOfServiceContent();
      default:
        return '正在加载内容...';
    }
  }

  String _getPrivacyPolicyContent() {
    return '''
DDH Exchange 隐私政策

生效日期：2024年1月1日

1. 信息收集
我们收集您在使用服务时提供的信息，包括：
• 账户信息（用户名、邮箱、手机号）
• 个人资料信息
• 使用数据和日志信息

2. 信息使用
我们使用收集的信息来：
• 提供和改善服务
• 处理交易和通信
• 确保平台安全
• 遵守法律要求

3. 信息分享
我们不会出售、交易或转让您的个人信息给第三方，除非：
• 获得您的明确同意
• 法律要求或政府机关要求
• 保护我们的权利和财产

4. 数据安全
我们采用行业标准的安全措施保护您的信息：
• 数据加密传输和存储
• 访问控制和权限管理
• 定期安全审计

5. 您的权利
您有权：
• 访问和更新个人信息
• 删除账户和数据
• 选择退出某些数据收集

6. Cookie使用
我们使用Cookie来改善用户体验，您可以通过浏览器设置管理Cookie。

7. 联系我们
如有隐私相关问题，请联系：
邮箱：privacy@ddhexchange.com
电话：400-123-4567

本政策可能会定期更新，请定期查看最新版本。
''';
  }

  String _getTermsOfServiceContent() {
    return '''
DDH Exchange 服务条款

生效日期：2024年1月1日

1. 服务说明
DDH Exchange是一个数字资产交易平台，为用户提供安全、便捷的交易服务。

2. 用户协议
使用本服务即表示您同意：
• 遵守所有适用的法律法规
• 提供真实、准确的信息
• 不从事违法或有害活动
• 保护账户安全

3. 使用规范
用户不得：
• 利用服务从事违法活动
• 发布虚假或误导性信息
• 干扰或破坏服务运行
• 侵犯他人权利

4. 知识产权
本平台的所有内容和技术均受知识产权保护，未经许可不得复制或使用。

5. 服务变更
我们保留随时修改或终止服务的权利，重大变更将提前通知用户。

6. 免责声明
• 服务按"现状"提供，不保证无中断
• 不对市场波动造成的损失承担责任
• 不对第三方服务承担责任

7. 争议解决
因使用服务产生的争议，应通过友好协商解决，协商不成的，提交仲裁解决。

8. 联系方式
如有问题，请联系：
邮箱：support@ddhexchange.com
电话：400-123-4567
地址：北京市朝阳区xxx街道xxx号

本条款的解释权归DDH Exchange所有。
''';
  }
}

/// 隐私政策页面 - 便捷创建方法
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WebViewScreen(
      title: '隐私政策',
      url: 'https://ddhexchange.com/privacy',
    );
  }
}

/// 服务条款页面 - 便捷创建方法
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const WebViewScreen(
      title: '服务条款',
      url: 'https://ddhexchange.com/terms',
    );
  }
}
