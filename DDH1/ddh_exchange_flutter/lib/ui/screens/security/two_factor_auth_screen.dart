import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import '../../../bloc/auth_bloc.dart';
// import '../../../bloc/auth_event.dart';
// import '../../../bloc/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

enum TwoFactorAuthStep {
  setup,
  verify,
  backup,
  success,
}

class TwoFactorAuthScreen extends StatefulWidget {
  final bool isSetup; // true for setup, false for verification

  const TwoFactorAuthScreen({
    super.key,
    this.isSetup = true,
  });

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  TwoFactorAuthStep _currentStep = TwoFactorAuthStep.setup;
  final _verificationCodeController = TextEditingController();
  
  final bool _isLoading = false;
  String? _errorMessage;
  String? _secretKey;
  final List<String> _backupCodes = [];

  @override
  void initState() {
    super.initState();
    if (!widget.isSetup) {
      _currentStep = TwoFactorAuthStep.verify;
    }
  }

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isSetup ? '设置双因子认证' : '双因子认证'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                if (widget.isSetup) _buildStepIndicator(),
                if (widget.isSetup) const SizedBox(height: 24),
                Expanded(
                  child: _buildCurrentStepContent(),
                ),
                if (_errorMessage != null) ...[
                  _buildErrorBanner(),
                  const SizedBox(height: 16),
                ],
                _buildActionButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;

    if (!widget.isSetup) {
      title = '双因子认证';
      subtitle = '请输入您的认证器应用中显示的6位验证码';
    } else {
      switch (_currentStep) {
        case TwoFactorAuthStep.setup:
          title = '设置双因子认证';
          subtitle = '使用认证器应用扫描二维码以增强账户安全性';
          break;
        case TwoFactorAuthStep.verify:
          title = '验证设置';
          subtitle = '请输入认证器应用中显示的6位验证码以完成设置';
          break;
        case TwoFactorAuthStep.backup:
          title = '备份代码';
          subtitle = '请妥善保存这些备份代码，当您无法使用认证器时可以使用';
          break;
        case TwoFactorAuthStep.success:
          title = '设置完成';
          subtitle = '双因子认证已成功启用，您的账户现在更加安全';
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(0, _currentStep.index >= 0),
        _buildStepLine(_currentStep.index >= 1),
        _buildStepDot(1, _currentStep.index >= 1),
        _buildStepLine(_currentStep.index >= 2),
        _buildStepDot(2, _currentStep.index >= 2),
        _buildStepLine(_currentStep.index >= 3),
        _buildStepDot(3, _currentStep.index >= 3),
      ],
    );
  }

  Widget _buildStepDot(int step, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
      child: Center(
        child: Text(
          '${step + 1}',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    if (!widget.isSetup) {
      return _buildVerifyStep();
    }

    switch (_currentStep) {
      case TwoFactorAuthStep.setup:
        return _buildSetupStep();
      case TwoFactorAuthStep.verify:
        return _buildVerifyStep();
      case TwoFactorAuthStep.backup:
        return _buildBackupStep();
      case TwoFactorAuthStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildSetupStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // QR Code placeholder - 在实际应用中，这里应该显示真实的QR码
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 80, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('QR码将在此显示'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '使用认证器应用扫描此二维码',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildAuthenticatorApps(),
        const SizedBox(height: 24),
        _buildManualSetup(),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.security,
                size: 48,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                '输入验证码',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请输入认证器应用中显示的6位数字验证码',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildVerificationCodeInput(),
        const SizedBox(height: 24),
        const Text(
          '验证码每30秒更新一次',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(
                Icons.backup,
                size: 48,
                color: Colors.orange[600],
              ),
              const SizedBox(height: 16),
              Text(
                '备份代码',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请妥善保存这些备份代码，每个代码只能使用一次',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildBackupCodes(),
        const SizedBox(height: 24),
        _buildBackupInstructions(),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.1),
          ),
          child: const Icon(
            Icons.verified_user,
            color: Colors.green,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          '双因子认证设置成功！',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '您的账户现在受到双因子认证保护\n登录时需要输入验证码',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatorApps() {
    final apps = [
      {'name': 'Google Authenticator', 'icon': Icons.security},
      {'name': 'Microsoft Authenticator', 'icon': Icons.security},
      {'name': 'Authy', 'icon': Icons.security},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '推荐的认证器应用：',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...apps.map((app) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(app['icon'] as IconData, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Text(app['name'] as String),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildManualSetup() {
    return ExpansionTile(
      title: const Text('手动设置'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '如果无法扫描二维码，请手动输入以下密钥：',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _secretKey ?? 'JBSWY3DPEHPK3PXP',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _secretKey ?? 'JBSWY3DPEHPK3PXP'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密钥已复制到剪贴板')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCodeInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _verificationCodeController,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 8,
        ),
        decoration: const InputDecoration(
          hintText: '000000',
          counterText: '',
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildBackupCodes() {
    // 模拟备份代码
    final codes = _backupCodes.isNotEmpty ? _backupCodes : [
      'A1B2C3D4',
      'E5F6G7H8',
      'I9J0K1L2',
      'M3N4O5P6',
      'Q7R8S9T0',
      'U1V2W3X4',
      'Y5Z6A7B8',
      'C9D0E1F2',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '备份代码',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: codes.join('\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('备份代码已复制到剪贴板')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: codes.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    codes[index],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackupInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                '重要提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '• 请将这些备份代码保存在安全的地方\n'
            '• 每个代码只能使用一次\n'
            '• 当您无法使用认证器应用时可以使用备份代码\n'
            '• 不要与他人分享这些代码',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    VoidCallback? onPressed;

    if (!widget.isSetup) {
      buttonText = '验证';
      onPressed = _verificationCodeController.text.length == 6 ? _verifyCode : null;
    } else {
      switch (_currentStep) {
        case TwoFactorAuthStep.setup:
          buttonText = '下一步';
          onPressed = _nextStep;
          break;
        case TwoFactorAuthStep.verify:
          buttonText = '验证';
          onPressed = _verificationCodeController.text.length == 6 ? _verifyCode : null;
          break;
        case TwoFactorAuthStep.backup:
          buttonText = '我已保存备份代码';
          onPressed = _nextStep;
          break;
        case TwoFactorAuthStep.success:
          buttonText = '完成';
          onPressed = _finish;
          break;
      }
    }

    return CustomButton(
      text: buttonText,
      onPressed: onPressed,
      isLoading: _isLoading,
    );
  }

  void _nextStep() {
    setState(() {
      _currentStep = TwoFactorAuthStep.values[_currentStep.index + 1];
    });
  }

  void _verifyCode() {
    setState(() {
      _errorMessage = null;
    });

    // 在实际应用中，这里应该调用真实的验证API
    if (widget.isSetup) {
              // 临时占位实现
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('双因子认证设置功能开发中...')),
              );
    } else {
              // 临时占位实现
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('双因子认证验证功能开发中...')),
              );
    }
  }

  void _finish() {
    Navigator.of(context).pop(true);
  }
}
