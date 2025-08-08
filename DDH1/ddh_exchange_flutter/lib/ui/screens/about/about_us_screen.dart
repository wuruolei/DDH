import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart'; // 简化版本暂不支持
import '../../../utils/color_scheme_manager.dart';

/// AboutUsScreen - 精确还原DDHExchangeApp iOS原生AboutUsView
/// 基于DDHExchangeApp/Views/Main/AboutUsView.swift完全重构
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于我们'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TextColors.adaptive(context),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '完成',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100), // AppBar空间
              _buildAppLogoSection(context),
              const SizedBox(height: 30),
              _buildAppIntroSection(context),
              const SizedBox(height: 30),
              _buildTeamSection(context),
              const SizedBox(height: 30),
              _buildContactSection(context),
              const SizedBox(height: 30),
              _buildMilestoneSection(context),
              const SizedBox(height: 30),
              _buildICPFilingSection(context),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// App Logo区域 - 对应iOS原生appLogoSection
  Widget _buildAppLogoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App图标和背景圆圈
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.credit_card,
              size: 80,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          // App名称和版本
          Column(
            children: [
              Text(
                '点点换',
                style: TextStyle(
                  fontSize: 34, // largeTitle
                  fontWeight: FontWeight.bold,
                  color: TextColors.adaptive(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '版本 1.1',
                style: TextStyle(
                  fontSize: 15, // subheadline
                  color: TextColors.adaptiveSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 产品介绍区域 - 对应iOS原生appIntroSection
  Widget _buildAppIntroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '产品介绍',
            style: TextStyle(
              fontSize: 17, // headline
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _FeatureCard(
                icon: Icons.people,
                title: '数字化服务平台',
                description: '专为用户设计的数字化服务管理平台，方便管理和获取各种服务',
                context: context,
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.message,
                title: '便捷的联系服务',
                description: '提供多种联系方式，包括微信二维码、客服支持等便民服务',
                context: context,
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.security,
                title: '安全可靠',
                description: '采用先进的加密技术，确保用户信息和联系数据安全',
                context: context,
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                icon: Icons.person_add,
                title: '邀请好友',
                description: '通过邀请码快速邀请好友加入平台，建立社交网络',
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 团队介绍区域 - 对应iOS原生teamSection
  Widget _buildTeamSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '团队介绍',
            style: TextStyle(
              fontSize: 17, // headline
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(context),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _TeamMemberCard(
                name: '张明',
                role: '产品总监',
                avatar: Icons.person_outline,
                description: '10年金融科技经验，专注青少年金融服务',
                context: context,
              ),
              const SizedBox(height: 12),
              _TeamMemberCard(
                name: '李华',
                role: '技术总监',
                avatar: Icons.computer,
                description: '资深全栈工程师，专注移动端和后端开发',
                context: context,
              ),
              const SizedBox(height: 12),
              _TeamMemberCard(
                name: '王芳',
                role: 'UI设计师',
                avatar: Icons.palette,
                description: '用户体验专家，致力于提升产品易用性',
                context: context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 联系我们区域 - 对应iOS原生contactSection
  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '联系我们',
            style: TextStyle(
              fontSize: 22, // title2
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(brightness),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _ContactInfoRow(
                icon: Icons.email,
                title: '商务合作',
                value: 'business@ddh.exchange',
                color: Colors.blue,
                onTap: () => _launchEmail('business@ddh.exchange'),
              ),
              _ContactInfoRow(
                icon: Icons.phone,
                title: '客服热线',
                value: '400-123-4567',
                color: Colors.green,
                onTap: () => _launchPhone('400-123-4567'),
              ),
              _ContactInfoRow(
                icon: Icons.language,
                title: '官方网站',
                value: 'https://a.ddg.org.cn',
                color: Colors.orange,
                onTap: () => _launchUrl('https://a.ddg.org.cn'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 发展历程区域 - 对应iOS原生milestoneSection
  Widget _buildMilestoneSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '发展历程',
            style: TextStyle(
              fontSize: 17, // headline
              fontWeight: FontWeight.bold,
              color: TextColors.adaptive(brightness),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _MilestoneCard(
                date: '2024年1月',
                title: '项目启动',
                description: '团队成立，开始产品规划和技术架构设计',
                brightness: brightness,
              ),
              const SizedBox(height: 16),
              _MilestoneCard(
                date: '2024年6月',
                title: '产品上线',
                description: '完成核心功能开发，开始内测和用户反馈收集',
                brightness: brightness,
              ),
              const SizedBox(height: 16),
              _MilestoneCard(
                date: '2024年12月',
                title: '正式发布',
                description: '通过App Store审核，正式为用户提供数字化服务',
                brightness: brightness,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 备案信息区域 - 对应iOS原生icpFilingSection
  Widget _buildICPFilingSection(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.grey.withOpacity(0.3),
          thickness: 1,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Text(
              '备案信息',
              style: TextStyle(
                fontSize: 17, // headline
                fontWeight: FontWeight.bold,
                color: TextColors.adaptive(brightness),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'ICP备案号：京ICP备2024000000号',
                    style: TextStyle(
                      fontSize: 14,
                      color: TextColors.adaptiveSecondary(brightness),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _launchUrl('https://beian.miit.gov.cn/'),
                    child: Text(
                      '工信部备案查询',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 辅助方法
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    // if (await canLaunchUrl(emailUri)) { // 简化版本暂不支持
    //   await launchUrl(emailUri);
    // }
    print('尝试发送邮件至: $email');
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    // if (await canLaunchUrl(phoneUri)) { // 简化版本暂不支持
    //   await launchUrl(phoneUri);
    // }
    print('尝试拨打电话: $phone');
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) { // 简化版本暂不支持
      // await launchUrl(uri, mode: LaunchMode.externalApplication); // 简化版本暂不支持
      print('尝试打开链接: $url');
    // }
  }
}

/// 特性卡片组件 - 对应iOS原生FeatureCard
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final BuildContext context;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22, // title2
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
                    fontSize: 16, // body
                    fontWeight: FontWeight.w500, // medium
                    color: TextColors.adaptive(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14, // caption
                    color: TextColors.adaptiveSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 团队成员卡片组件 - 对应iOS原生TeamMemberCard
class _TeamMemberCard extends StatelessWidget {
  final String name;
  final String role;
  final IconData avatar;
  final String description;
  final BuildContext context;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.avatar,
    required this.description,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            avatar,
            size: 28, // title
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16, // body
                        fontWeight: FontWeight.bold,
                        color: TextColors.adaptive(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        role,
                        style: const TextStyle(
                          fontSize: 12, // caption
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12, // caption
                    color: TextColors.adaptiveSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 联系信息行组件 - 对应iOS原生ContactInfoRow
class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactInfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // body
                    fontWeight: FontWeight.w500, // medium
                    color: TextColors.adaptive(brightness),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12, // caption
                    color: TextColors.adaptiveSecondary(brightness),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Icon(
              Icons.open_in_new,
              color: color,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 里程碑卡片组件 - 对应iOS原生MilestoneCard
class _MilestoneCard extends StatelessWidget {
  final String date;
  final String title;
  final String description;
  final Brightness brightness;

  const _MilestoneCard({
    required this.date,
    required this.title,
    required this.description,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.blue,
              size: 22, // title2
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12, // caption
                    fontWeight: FontWeight.w500, // medium
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16, // body
                    fontWeight: FontWeight.bold,
                    color: TextColors.adaptive(brightness),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12, // caption
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
}
