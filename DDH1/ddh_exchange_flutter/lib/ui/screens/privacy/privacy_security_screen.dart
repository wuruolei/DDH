import 'package:flutter/material.dart';
import '../../../utils/color_scheme_manager.dart';
import '../auth/change_password_screen.dart';
import '../common/web_view_screen.dart';

/// PrivacySecurityScreen - 精确还原DDHExchangeApp iOS原生PrivacySecurityView
/// 基于DDHExchangeApp/Views/Main/PrivacySecurityView.swift完全重构
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  // 状态变量 - 对应iOS原生
  bool _notificationsEnabled = true;
  bool _dataAnalyticsEnabled = false;


  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私与安全'),
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
        color: BackgroundColors.adaptive(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
            child: Column(
              children: [
                // 安全设置区域 - 对应iOS原生
                _buildSecuritySettingsSection(brightness),
                
                const SizedBox(height: 24),
                
                // 隐私设置区域 - 对应iOS原生
                _buildPrivacySettingsSection(brightness),
                
                const SizedBox(height: 24),
                
                // 法律条款区域 - 对应iOS原生
                _buildLegalSection(brightness),
                
                const SizedBox(height: 24),
                
                // 账户管理区域 - 对应iOS原生
                _buildAccountManagementSection(brightness),
                
                const SizedBox(height: 24),
                
                // 安全提示 - 对应iOS原生
                _buildSecurityTip(brightness),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 安全设置区域 - 对应iOS原生安全设置区域
  Widget _buildSecuritySettingsSection(Brightness brightness) {
    return Column(
      children: [
        _SectionHeader(title: '安全设置', brightness: brightness),
        Container(
          decoration: BoxDecoration(
            color: BackgroundColors.card(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _SecurityOptionRow(
            icon: Icons.key,
            title: '修改密码',
            description: '更改您的登录密码',
            onTap: () => _showChangePassword(),
            brightness: brightness,
          ),
        ),
      ],
    );
  }

  /// 隐私设置区域 - 对应iOS原生隐私设置区域
  Widget _buildPrivacySettingsSection(Brightness brightness) {
    return Column(
      children: [
        _SectionHeader(title: '隐私设置', brightness: brightness),
        Container(
          decoration: BoxDecoration(
            color: BackgroundColors.card(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _SecurityOptionRow(
                icon: Icons.notifications,
                title: '推送通知',
                description: '接收应用通知和提醒',
                isToggle: true,
                isEnabled: _notificationsEnabled,
                onToggle: (value) => _toggleNotifications(),
                brightness: brightness,
              ),
              Divider(
                height: 1,
                indent: 60,
                color: Colors.grey.withOpacity(0.3),
              ),
              _SecurityOptionRow(
                icon: Icons.bar_chart,
                title: '数据分析',
                description: '帮助改善应用体验',
                isToggle: true,
                isEnabled: _dataAnalyticsEnabled,
                onToggle: (value) => _toggleDataAnalytics(),
                brightness: brightness,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 法律条款区域 - 对应iOS原生法律条款区域
  Widget _buildLegalSection(Brightness brightness) {
    return Column(
      children: [
        _SectionHeader(title: '法律条款', brightness: brightness),
        Container(
          decoration: BoxDecoration(
            color: BackgroundColors.card(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _SecurityOptionRow(
                icon: Icons.description,
                title: '隐私政策',
                description: '查看我们的隐私政策',
                onTap: () => _showPrivacyPolicy(),
                brightness: brightness,
              ),
              Divider(
                height: 1,
                indent: 60,
                color: Colors.grey.withOpacity(0.3),
              ),
              _SecurityOptionRow(
                icon: Icons.article,
                title: '服务条款',
                description: '查看服务使用条款',
                onTap: () => _showTermsOfService(),
                brightness: brightness,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 账户管理区域 - 对应iOS原生危险操作区域
  Widget _buildAccountManagementSection(Brightness brightness) {
    return Column(
      children: [
        _SectionHeader(title: '账户管理', brightness: brightness),
        Container(
          decoration: BoxDecoration(
            color: BackgroundColors.card(brightness),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _SecurityOptionRow(
            icon: Icons.delete_forever,
            title: '删除账户',
            description: '永久删除您的账户和所有数据',
            onTap: () => _showDeleteAccountDialog(),
            brightness: brightness,
            isDangerous: true,
          ),
        ),
      ],
    );
  }

  /// 安全提示 - 对应iOS原生SecurityTipRow
  Widget _buildSecurityTip(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '安全提示',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '为了您的账户安全，请定期更新密码，不要与他人分享您的登录信息。',
                  style: TextStyle(
                    fontSize: 14,
                    color: TextColors.adaptiveSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 业务逻辑方法
  void _loadSettings() {
    // 加载保存的设置
    // TODO: 从SharedPreferences或其他存储中加载设置
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
    // TODO: 保存设置并处理推送通知权限
    debugPrint('推送通知已${_notificationsEnabled ? '启用' : '禁用'}');
  }

  void _toggleDataAnalytics() {
    setState(() {
      _dataAnalyticsEnabled = !_dataAnalyticsEnabled;
    });
    // TODO: 保存设置
    debugPrint('数据分析已${_dataAnalyticsEnabled ? '启用' : '禁用'}');
  }

  void _showChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyScreen(),
      ),
    );
  }

  void _showTermsOfService() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsOfServiceScreen(),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: const Text('此操作无法撤销。删除账户将永久移除您的所有数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // TODO: 实现删除账户逻辑
    Navigator.of(context).pop();
  }
}

/// 区域标题组件 - 对应iOS原生SectionHeader
class _SectionHeader extends StatelessWidget {
  final String title;
  final Brightness brightness;

  const _SectionHeader({
    required this.title,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20, // title3
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

/// 安全选项行组件 - 对应iOS原生SecurityOptionRow
class _SecurityOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;
  final Brightness brightness;
  final bool isDangerous;

  const _SecurityOptionRow({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
    this.isToggle = false,
    this.isEnabled = false,
    this.onToggle,
    required this.brightness,
    this.isDangerous = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isToggle ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: (isDangerous ? Colors.red : Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDangerous ? Colors.red : Colors.blue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDangerous ? Colors.red : TextColors.adaptive(brightness),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: TextColors.adaptiveSecondary(brightness),
                    ),
                  ),
                ],
              ),
            ),
            if (isToggle)
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: Colors.blue,
              )
            else
              Icon(
                Icons.chevron_right,
                color: TextColors.adaptiveSecondary(brightness),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// 修改密码模态框 - 临时实现
class _ChangePasswordModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              '修改密码',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('修改密码功能开发中...'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 隐私政策视图 - 临时实现
class _PrivacyPolicyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
      body: const Center(
        child: Text('隐私政策内容开发中...'),
      ),
    );
  }
}

/// 服务条款视图 - 临时实现
class _TermsOfServiceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务条款'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
      body: const Center(
        child: Text('服务条款内容开发中...'),
      ),
    );
  }
}
