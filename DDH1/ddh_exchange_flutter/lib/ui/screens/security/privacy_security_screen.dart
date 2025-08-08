import 'package:flutter/material.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricEnabled = false;
  bool _transactionPasswordEnabled = true;
  bool _loginNotificationEnabled = true;
  bool _transactionNotificationEnabled = true;
  bool _marketingNotificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私与安全'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSecuritySection(),
            _buildPrivacySection(),
            _buildNotificationSection(),
            _buildDataSection(),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: '安全设置',
      icon: Icons.security,
      children: [
        _buildSettingItem(
          icon: Icons.fingerprint,
          title: '生物识别登录',
          subtitle: '使用指纹或面容ID快速登录',
          trailing: Switch(
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              _showBiometricDialog(value);
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.lock,
          title: '修改登录密码',
          subtitle: '定期修改密码以保障账户安全',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _changeLoginPassword,
        ),
        _buildSettingItem(
          icon: Icons.vpn_key,
          title: '交易密码',
          subtitle: _transactionPasswordEnabled ? '已启用' : '未启用',
          trailing: Switch(
            value: _transactionPasswordEnabled,
            onChanged: (value) {
              if (value) {
                _setTransactionPassword();
              } else {
                _disableTransactionPassword();
              }
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.verified_user,
          title: '双重认证 (2FA)',
          subtitle: '为账户添加额外安全保护',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _setupTwoFactorAuth,
        ),
        _buildSettingItem(
          icon: Icons.devices,
          title: '设备管理',
          subtitle: '查看和管理登录设备',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _manageDevices,
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私设置',
      icon: Icons.privacy_tip,
      children: [
        _buildSettingItem(
          icon: Icons.visibility,
          title: '隐私政策',
          subtitle: '了解我们如何保护您的隐私',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _showPrivacyPolicy,
        ),
        _buildSettingItem(
          icon: Icons.cookie,
          title: 'Cookie设置',
          subtitle: '管理Cookie和跟踪偏好',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _manageCookies,
        ),
        _buildSettingItem(
          icon: Icons.location_on,
          title: '位置服务',
          subtitle: '控制应用访问位置信息',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _manageLocation,
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: '通知设置',
      icon: Icons.notifications,
      children: [
        _buildSettingItem(
          icon: Icons.login,
          title: '登录通知',
          subtitle: '新设备登录时接收通知',
          trailing: Switch(
            value: _loginNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _loginNotificationEnabled = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.swap_horiz,
          title: '交易通知',
          subtitle: '交易完成时接收通知',
          trailing: Switch(
            value: _transactionNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _transactionNotificationEnabled = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
        _buildSettingItem(
          icon: Icons.campaign,
          title: '营销通知',
          subtitle: '接收产品更新和优惠信息',
          trailing: Switch(
            value: _marketingNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _marketingNotificationEnabled = value;
              });
            },
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: '数据管理',
      icon: Icons.storage,
      children: [
        _buildSettingItem(
          icon: Icons.download,
          title: '导出数据',
          subtitle: '下载您的账户数据副本',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _exportData,
        ),
        _buildSettingItem(
          icon: Icons.delete_sweep,
          title: '清除缓存',
          subtitle: '清理应用缓存数据',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _clearCache,
        ),
        _buildSettingItem(
          icon: Icons.history,
          title: '活动记录',
          subtitle: '查看账户活动历史',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _viewActivityLog,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: '账户管理',
      icon: Icons.person,
      children: [
        _buildSettingItem(
          icon: Icons.pause_circle,
          title: '暂停账户',
          subtitle: '临时停用账户功能',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _pauseAccount,
          isDestructive: true,
        ),
        _buildSettingItem(
          icon: Icons.delete_forever,
          title: '删除账户',
          subtitle: '永久删除账户和所有数据',
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _deleteAccount,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  void _showBiometricDialog(bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(enabled ? '启用生物识别' : '关闭生物识别'),
        content: Text(
          enabled
              ? '启用生物识别登录后，您可以使用指纹或面容ID快速登录应用。'
              : '关闭生物识别登录后，您需要输入密码进行登录。',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _biometricEnabled = !enabled;
              });
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (enabled) {
                _enableBiometric();
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _enableBiometric() async {
    // TODO: 实现生物识别启用逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('生物识别已启用')),
    );
  }

  void _changeLoginPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  void _setTransactionPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置交易密码'),
        content: const Text('交易密码用于确认重要操作，请设置一个6位数字密码。'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _transactionPasswordEnabled = false;
              });
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 打开设置交易密码页面
              setState(() {
                _transactionPasswordEnabled = true;
              });
            },
            child: const Text('设置'),
          ),
        ],
      ),
    );
  }

  void _disableTransactionPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关闭交易密码'),
        content: const Text('关闭交易密码后，进行交易时将不需要输入交易密码。确定要关闭吗？'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _transactionPasswordEnabled = true;
              });
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _transactionPasswordEnabled = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('交易密码已关闭')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _setupTwoFactorAuth() {
    // TODO: 实现双重认证设置
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('双重认证功能开发中')),
    );
  }

  void _manageDevices() {
    // TODO: 实现设备管理
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设备管理功能开发中')),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: 显示隐私政策
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('隐私政策功能开发中')),
    );
  }

  void _manageCookies() {
    // TODO: 管理Cookie设置
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cookie设置功能开发中')),
    );
  }

  void _manageLocation() {
    // TODO: 管理位置服务
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('位置服务设置功能开发中')),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text('我们将为您准备数据导出文件，完成后会通过邮件发送给您。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据导出请求已提交')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('清除缓存将删除临时文件，但不会影响您的账户数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _viewActivityLog() {
    // TODO: 查看活动记录
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('活动记录功能开发中')),
    );
  }

  void _pauseAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('暂停账户'),
        content: const Text('暂停账户后，您将无法进行交易等操作。确定要暂停账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('账户暂停功能开发中')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('暂停'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户'),
        content: const Text('删除账户将永久删除所有数据，此操作不可恢复。确定要删除账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('账户删除功能开发中')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改密码'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '当前密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入当前密码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '新密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入新密码';
                  }
                  if (value.length < 6) {
                    return '密码至少6位';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '确认新密码',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return '两次输入的密码不一致';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('修改密码'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: 实现修改密码逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码修改成功')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
