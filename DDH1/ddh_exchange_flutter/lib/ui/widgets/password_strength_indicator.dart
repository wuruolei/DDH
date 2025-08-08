import 'package:flutter/material.dart';

enum PasswordStrength {
  weak,
  fair,
  good,
  strong,
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool showText;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildStrengthBar(0, strength)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(1, strength)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(2, strength)),
            const SizedBox(width: 4),
            Expanded(child: _buildStrengthBar(3, strength)),
          ],
        ),
        if (showText && password.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _getStrengthIcon(strength),
                size: 16,
                color: _getStrengthColor(strength),
              ),
              const SizedBox(width: 8),
              Text(
                _getStrengthText(strength),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStrengthColor(strength),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPasswordRequirements(),
        ],
      ],
    );
  }

  Widget _buildStrengthBar(int index, PasswordStrength strength) {
    final isActive = index <= strength.index;
    
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: isActive ? _getStrengthColor(strength) : Colors.grey[300],
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final requirements = _getPasswordRequirements();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((requirement) {
        final isMet = requirement['isMet'] as bool;
        final text = requirement['text'] as String;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                isMet ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 14,
                color: isMet ? Colors.green : Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    color: isMet ? Colors.green : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    int score = 0;
    
    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    
    // Bonus for very long passwords
    if (password.length >= 16) score++;
    
    // Penalty for common patterns
    if (_hasCommonPatterns(password)) score--;
    
    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 6) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      RegExp(r'123456'),
      RegExp(r'password', caseSensitive: false),
      RegExp(r'qwerty', caseSensitive: false),
      RegExp(r'abc123', caseSensitive: false),
      RegExp(r'admin', caseSensitive: false),
    ];
    
    return commonPatterns.any((pattern) => password.contains(pattern));
  }

  List<Map<String, dynamic>> _getPasswordRequirements() {
    return [
      {
        'text': '至少8个字符',
        'isMet': password.length >= 8,
      },
      {
        'text': '包含小写字母',
        'isMet': password.contains(RegExp(r'[a-z]')),
      },
      {
        'text': '包含大写字母',
        'isMet': password.contains(RegExp(r'[A-Z]')),
      },
      {
        'text': '包含数字',
        'isMet': password.contains(RegExp(r'[0-9]')),
      },
      {
        'text': '包含特殊字符',
        'isMet': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      },
    ];
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.blue;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }

  IconData _getStrengthIcon(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Icons.warning;
      case PasswordStrength.fair:
        return Icons.info;
      case PasswordStrength.good:
        return Icons.check_circle_outline;
      case PasswordStrength.strong:
        return Icons.verified;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return '密码强度：弱';
      case PasswordStrength.fair:
        return '密码强度：一般';
      case PasswordStrength.good:
        return '密码强度：良好';
      case PasswordStrength.strong:
        return '密码强度：强';
    }
  }
}

// 简化版本的密码强度指示器，只显示强度条
class SimplePasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const SimplePasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return PasswordStrengthIndicator(
      password: password,
      showText: false,
    );
  }
}
