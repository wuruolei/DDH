import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/password_strength_indicator.dart';
import '../../widgets/loading_overlay.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('修改密码'),
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
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildCurrentPasswordField(),
                    const SizedBox(height: 24),
                    _buildNewPasswordField(),
                    const SizedBox(height: 16),
                    _buildPasswordStrengthIndicator(),
                    const SizedBox(height: 24),
                    _buildConfirmPasswordField(),
                    const SizedBox(height: 32),
                    if (_errorMessage != null) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: 16),
                    ],
                    if (_successMessage != null) ...[
                      _buildSuccessBanner(),
                      const SizedBox(height: 16),
                    ],
                    _buildChangePasswordButton(),
                    const SizedBox(height: 24),
                    _buildSecurityTips(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '修改密码',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '为了您的账户安全，请定期更新密码',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPasswordField() {
    return CustomTextField(
      controller: _currentPasswordController,
      labelText: '当前密码',
      hintText: '请输入当前密码',
      prefixIcon: const Icon(Icons.lock_outline),
      obscureText: !_isCurrentPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isCurrentPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入当前密码';
        }
        return null;
      },
    );
  }

  Widget _buildNewPasswordField() {
    return CustomTextField(
      controller: _newPasswordController,
      labelText: '新密码',
      hintText: '请输入新密码',
      prefixIcon: const Icon(Icons.lock_outline),
      obscureText: !_isNewPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isNewPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _isNewPasswordVisible = !_isNewPasswordVisible;
          });
        },
      ),
      onChanged: (value) {
        setState(() {}); // 触发密码强度指示器更新
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入新密码';
        }
        if (value.length < 8) {
          return '密码长度至少8位';
        }
        if (value == _currentPasswordController.text) {
          return '新密码不能与当前密码相同';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return PasswordStrengthIndicator(
      password: _newPasswordController.text,
      showText: true,
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      controller: _confirmPasswordController,
      labelText: '确认新密码',
      hintText: '请再次输入新密码',
      prefixIcon: const Icon(Icons.lock_outline),
      obscureText: !_isConfirmPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请确认新密码';
        }
        if (value != _newPasswordController.text) {
          return '两次输入的密码不一致';
        }
        return null;
      },
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

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton() {
    return CustomButton(
      text: '修改密码',
      onPressed: _canChangePassword() ? _changePassword : null,
      isLoading: _isLoading,
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                '安全提示',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSecurityTip('使用包含大小写字母、数字和特殊字符的强密码'),
          _buildSecurityTip('不要使用与其他账户相同的密码'),
          _buildSecurityTip('定期更换密码以保护账户安全'),
          _buildSecurityTip('不要在公共场所输入密码'),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[600],
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canChangePassword() {
    return _currentPasswordController.text.isNotEmpty &&
           _newPasswordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _newPasswordController.text == _confirmPasswordController.text &&
           _newPasswordController.text.length >= 8 &&
           _newPasswordController.text != _currentPasswordController.text;
  }

  void _changePassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });

      // 临时占位实现
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码修改功能开发中...')),
      );
    }
  }


}
