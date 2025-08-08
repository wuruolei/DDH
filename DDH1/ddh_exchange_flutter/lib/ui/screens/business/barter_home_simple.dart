import 'package:flutter/material.dart';

/// 积分易货主界面 - 简化版本（用于Web测试）
class BarterHomeSimple extends StatefulWidget {
  const BarterHomeSimple({super.key});

  @override
  State<BarterHomeSimple> createState() => _BarterHomeSimpleState();
}

class _BarterHomeSimpleState extends State<BarterHomeSimple> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '点点换',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => _showProfile(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '首页', icon: Icon(Icons.home)),
            Tab(text: '易货', icon: Icon(Icons.swap_horiz)),
            Tab(text: '积分', icon: Icon(Icons.stars)),
            Tab(text: '信用', icon: Icon(Icons.verified_user)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          _buildBarterTab(),
          _buildPointsTab(),
          _buildCreditTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPublishDialog(),
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// 构建首页标签
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickStats(),
          const SizedBox(height: 20),
          _buildSectionTitle('推荐物品', Icons.recommend),
          const SizedBox(height: 12),
          _buildRecommendedItems(),
          const SizedBox(height: 20),
          _buildSectionTitle('最近交易', Icons.history),
          const SizedBox(height: 12),
          _buildRecentTransactions(),
        ],
      ),
    );
  }

  /// 构建易货标签
  Widget _buildBarterTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: '我的物品'),
                Tab(text: '发现物品'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('我的物品列表功能开发中...', style: TextStyle(color: Colors.grey))),
                Center(child: Text('发现物品功能开发中...', style: TextStyle(color: Colors.grey))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建积分标签
  Widget _buildPointsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Center(child: Text('积分功能开发中...', style: TextStyle(color: Colors.grey, fontSize: 16))),
        ],
      ),
    );
  }

  /// 构建信用标签
  Widget _buildCreditTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Center(child: Text('信用功能开发中...', style: TextStyle(color: Colors.grey, fontSize: 16))),
        ],
      ),
    );
  }

  /// 构建欢迎卡片
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '欢迎使用点点换',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点点够总公司 - 积分易货平台',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWelcomeStatItem('我的积分', '1,250', Icons.stars),
              _buildWelcomeStatItem('信用等级', 'A+', Icons.verified_user),
              _buildWelcomeStatItem('交易次数', '23', Icons.swap_horiz),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建欢迎卡片统计项
  Widget _buildWelcomeStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// 构建快速统计
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('发布物品', '5', Icons.inventory, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('进行中', '2', Icons.swap_horiz, Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('完成交易', '18', Icons.check_circle, Colors.blue),
        ),
      ],
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItems() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory, color: Colors.blue[600], size: 32),
                const SizedBox(height: 8),
                Text('推荐物品 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('100 积分', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Icon(Icons.swap_horiz, color: Colors.blue[600]),
            ),
            title: Text('交易记录 ${index + 1}'),
            subtitle: Text('${DateTime.now().subtract(Duration(days: index)).toString().split(' ')[0]}'),
            trailing: const Text('已完成', style: TextStyle(color: Colors.green)),
          );
        },
      ),
    );
  }

  // ==================== 事件处理方法 ====================

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知功能开发中...')),
    );
  }

  void _showProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('个人资料功能开发中...')),
    );
  }

  void _showPublishDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('发布物品功能开发中...')),
    );
  }
}
