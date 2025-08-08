import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart'; // 简化版本暂不支持
import '../../widgets/custom_button.dart';
import '../../../utils/color_scheme_manager.dart';

/// 精确对照DDHExchangeApp iOS InviteFriendsView.swift的Flutter实现
class InviteFriendsScreen extends StatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  State<InviteFriendsScreen> createState() => _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends State<InviteFriendsScreen>
    with TickerProviderStateMixin {
  // 状态变量 - 精确对照iOS InviteFriendsView
  String _inviteCode = "";
  bool _isGeneratingCode = false;

  bool _isShareContentReady = false;
  
  // 动画控制器
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 启动背景动画
    _backgroundAnimationController.repeat(reverse: true);
    
    // 加载现有邀请码
    _loadExistingInviteCode();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('邀请好友'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TextColors.adaptive(brightness),
      ),
      body: Stack(
        children: [
          // 背景渐变
          _buildBackgroundGradient(brightness),
          // 背景装饰
          _buildBackgroundDecorations(screenSize, brightness),
          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // 邀请说明区域
                  _buildInviteDescription(brightness),
                  const SizedBox(height: 32),
                  // 邀请码区域
                  _buildInviteCodeSection(brightness),
                  const SizedBox(height: 32),
                  // 邀请奖励说明
                  _buildRewardSection(brightness),
                  const SizedBox(height: 32),
                  // 使用说明
                  _buildInstructionSection(brightness),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建背景渐变 - 精确对照iOS backgroundGradient
  Widget _buildBackgroundGradient(Brightness brightness) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [
                  const Color.fromRGBO(15, 20, 31, 1.0),
                  const Color.fromRGBO(31, 36, 46, 1.0),
                ]
              : [
                  const Color.fromRGBO(250, 252, 255, 1.0),
                  const Color.fromRGBO(240, 245, 250, 1.0),
                ],
        ),
      ),
    );
  }

  /// 构建背景装饰 - 精确对照iOS backgroundDecorations
  Widget _buildBackgroundDecorations(Size screenSize, Brightness brightness) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 装饰圆圈 - 右上角
            Positioned(
              right: -30 + _backgroundAnimation.value * 10,
              top: 100 - _backgroundAnimation.value * 5,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(
                    brightness == Brightness.dark ? 0.1 : 0.05,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 邀请说明区域 - 精确对照iOS inviteDescription
  Widget _buildInviteDescription(Brightness brightness) {
    return Column(
      children: [
        Icon(
          Icons.people,
          size: 60,
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
        Text(
          '邀请好友加入',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: TextColors.adaptive(brightness),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '分享您的专属邀请码，让朋友快速加入点点换',
          style: TextStyle(
            fontSize: 16,
            color: TextColors.adaptiveSecondary(brightness),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 邀请码区域 - 精确对照iOS inviteCodeSection
  Widget _buildInviteCodeSection(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(brightness == Brightness.dark ? 0.4 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '您的邀请码',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TextColors.adaptive(brightness),
            ),
          ),
          const SizedBox(height: 16),
          if (_inviteCode.isEmpty) ...[
            // 生成邀请码按钮
            CustomButton(
              onPressed: _isGeneratingCode ? null : _generateInviteCode,
              text: _isGeneratingCode ? '生成中...' : '生成邀请码',
              isLoading: _isGeneratingCode,
            ),
          ] else ...[
            // 邀请码显示和操作
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withOpacity(0.3), width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteCode,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyInviteCode,
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    tooltip: '复制邀请码',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: _isShareContentReady ? _shareInviteCode : null,
                    text: '分享邀请码',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton.outlined(
                    onPressed: _generateInviteCode,
                    text: '重新生成',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 邀请奖励说明 - 精确对照iOS rewardSection
  Widget _buildRewardSection(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(brightness == Brightness.dark ? 0.4 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            '邀请奖励',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TextColors.adaptive(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _RewardRow(
                icon: Icons.card_giftcard,
                title: '邀请成功',
                description: '好友成功注册后，您将获得积分奖励',
                brightness: brightness,
              ),
              const SizedBox(height: 12),
              _RewardRow(
                icon: Icons.star,
                title: '活跃奖励',
                description: '好友活跃使用应用，您将获得额外奖励',
                brightness: brightness,
              ),
              const SizedBox(height: 12),
              _RewardRow(
                icon: Icons.workspace_premium,
                title: '等级提升',
                description: '邀请更多好友，提升您的会员等级',
                brightness: brightness,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 使用说明区域 - 精确对照iOS instructionSection
  Widget _buildInstructionSection(Brightness brightness) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(brightness == Brightness.dark ? 0.4 : 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.15)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '使用说明',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: TextColors.adaptive(brightness),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              _InstructionRow(
                number: '1',
                text: '点击"生成邀请码"获取您的专属邀请码',
                brightness: brightness,
              ),
              const SizedBox(height: 12),
              _InstructionRow(
                number: '2',
                text: '通过微信、QQ等方式分享邀请码给好友',
                brightness: brightness,
              ),
              const SizedBox(height: 12),
              _InstructionRow(
                number: '3',
                text: '好友使用邀请码注册后，双方都将获得奖励',
                brightness: brightness,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 生成邀请码 - 精确对照iOS generateInviteCode
  Future<void> _generateInviteCode() async {
    setState(() {
      _isGeneratingCode = true;
    });

    try {
      // 模拟API调用延迟
      await Future.delayed(const Duration(seconds: 2));
      
      // 生成基于时间戳的邀请码
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random();
      final userHash = random.nextInt(10000);
      final newInviteCode = "DDH$userHash${timestamp % 10000}";
      
      setState(() {
        _inviteCode = newInviteCode;
        _isGeneratingCode = false;
      });
      
      // 准备分享内容
      _prepareShareContent();
      
    } catch (error) {
      setState(() {
        _isGeneratingCode = false;
        // 备用邀请码生成
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _inviteCode = "DDH${timestamp % 1000000}";
      });
      
      _prepareShareContent();
    }
  }

  /// 加载现有邀请码 - 精确对照iOS loadExistingInviteCode
  void _loadExistingInviteCode() {
    // 这里可以从本地存储或服务器加载现有邀请码
    // 暂时留空，实际项目中需要实现
  }

  /// 准备分享内容 - 精确对照iOS prepareShareContent
  void _prepareShareContent() {
    if (_inviteCode.isEmpty) {
      setState(() {
        _isShareContentReady = false;
      });
      return;
    }
    
    setState(() {
      _isShareContentReady = true;
    });
  }

  /// 复制邀请码 - 精确对照iOS copyInviteCode
  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: _inviteCode));
    
    // 复制状态已简化
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('邀请码已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // 复制状态管理已简化
  }

  /// 分享邀请码 - 精确对照iOS shareInviteCode
  void _shareInviteCode() {
    if (_inviteCode.isEmpty || !_isShareContentReady) {
      return;
    }
    
    // Share.share( // 简化版本暂不支持
    debugPrint('分享邀请码: $_inviteCode');
    // 分享内容已简化，直接显示邀请码
  }
}

/// 奖励行组件 - 精确对照iOS RewardRow
class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Brightness brightness;

  const _RewardRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TextColors.adaptive(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: TextColors.adaptiveSecondary(brightness),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 说明行组件 - 精确对照iOS InstructionRow
class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;
  final Brightness brightness;

  const _InstructionRow({
    required this.number,
    required this.text,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: TextColors.adaptive(brightness),
            ),
          ),
        ),
      ],
    );
  }
}
