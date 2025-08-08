import 'package:flutter/material.dart';
import '../../../models/barter_model.dart';
import '../../../models/points_model.dart';
import '../../../models/user_credit_model.dart';
import '../../../services/points_service.dart';
import '../../../services/barter_service.dart';
import '../../../services/user_credit_service.dart';
import '../../../services/network_service.dart';
import '../../../services/storage_service.dart';
import '../../../utils/logger.dart';

/// 积分易货主界面
class BarterHomeScreen extends StatefulWidget {
  const BarterHomeScreen({super.key});

  @override
  State<BarterHomeScreen> createState() => _BarterHomeScreenState();
}

class _BarterHomeScreenState extends State<BarterHomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late PointsService _pointsService;
  late BarterService _barterService;
  late UserCreditService _creditService;
  
  // 数据状态
  PointsAccount? _pointsAccount;
  UserCredit? _userCredit;
  List<BarterItem> _myItems = [];
  List<BarterItem> _recommendedItems = [];
  List<BarterTransaction> _myTransactions = [];
  
  bool _isLoading = true;
  String _currentUserId = 'user_demo_001'; // 演示用户ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initServices();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pointsService.dispose();
    _barterService.dispose();
    _creditService.dispose();
    super.dispose();
  }

  /// 初始化服务
  void _initServices() {
    final networkService = NetworkService();
    final storageService = StorageService();
    
    _pointsService = PointsService(
      networkService: networkService,
      storageService: storageService,
    );
    
    _barterService = BarterService(
      networkService: networkService,
      storageService: storageService,
      pointsService: _pointsService,
    );
    
    _creditService = UserCreditService(
      networkService: networkService,
      storageService: storageService,
    );
  }

  /// 加载数据
  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      // 并行加载所有数据
      final results = await Future.wait([
        _pointsService.getPointsAccount(_currentUserId),
        _creditService.getUserCredit(_currentUserId),
        _barterService.getMyBarterItems(_currentUserId),
        _barterService.searchBarterItems(BarterSearchCriteria(
          sortBy: 'newest',
        )),
        _barterService.getTransactionHistory(_currentUserId),
      ]);

      setState(() {
        _pointsAccount = results[0] as PointsAccount;
        _userCredit = results[1] as UserCredit;
        _myItems = results[2] as List<BarterItem>;
        _recommendedItems = (results[3] as List<BarterItem>).take(10).toList();
        _myTransactions = results[4] as List<BarterTransaction>;
        _isLoading = false;
      });

      Logger.i('积分易货主界面数据加载完成');
    } catch (e) {
      Logger.e('加载数据失败', error: e);
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: ${e.toString()}')),
        );
      }
    }
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
            Tab(icon: Icon(Icons.home), text: '首页'),
            Tab(icon: Icon(Icons.swap_horiz), text: '易货'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: '积分'),
            Tab(icon: Icon(Icons.star), text: '信用'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildBarterTab(),
                _buildPointsTab(),
                _buildCreditTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPublishDialog(),
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('发布物品', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  /// 构建首页标签
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildSectionTitle('推荐物品', Icons.recommend),
            const SizedBox(height: 12),
            _buildRecommendedItems(),
            const SizedBox(height: 24),
            _buildSectionTitle('最近交易', Icons.history),
            const SizedBox(height: 12),
            _buildRecentTransactions(),
          ],
        ),
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
          Expanded(
            child: TabBarView(
              children: [
                _buildMyItemsList(),
                _buildDiscoverItemsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建积分标签
  Widget _buildPointsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPointsCard(),
          const SizedBox(height: 24),
          _buildPointsActions(),
          const SizedBox(height: 24),
          _buildSectionTitle('积分任务', Icons.task_alt),
          const SizedBox(height: 12),
          _buildPointsTasks(),
        ],
      ),
    );
  }

  /// 构建信用标签
  Widget _buildCreditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreditCard(),
          const SizedBox(height: 24),
          _buildCreditStats(),
        ],
      ),
    );
  }

  // ==================== UI 组件方法 ====================

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
            '欢迎回来！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点点够总公司 - 积分易货平台',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWelcomeStatItem(
                '我的积分',
                _pointsAccount?.availablePoints.toString() ?? '0',
                Icons.account_balance_wallet,
              ),
              const SizedBox(width: 24),
              _buildWelcomeStatItem(
                '信用等级',
                _creditService.getCreditLevelDescription(_userCredit?.level ?? CreditLevel.bronze),
                Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建欢迎卡片统计项
  Widget _buildWelcomeStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建快速统计
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '我的物品',
            _myItems.length.toString(),
            Icons.inventory,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '进行中交易',
            _myTransactions.where((t) => 
              t.status == BarterTransactionStatus.pending ||
              t.status == BarterTransactionStatus.confirmed
            ).length.toString(),
            Icons.swap_horiz,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '完成交易',
            _myTransactions.where((t) => 
              t.status == BarterTransactionStatus.completed
            ).length.toString(),
            Icons.check_circle,
            Colors.blue,
          ),
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

  // ==================== 占位符方法 ====================

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
    if (_recommendedItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            '暂无推荐物品',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recommendedItems.length,
        itemBuilder: (context, index) {
          final item = _recommendedItems[index];
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 物品图片
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                // 物品信息
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '期望: ${item.expectedPoints}积分',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                item.location ?? '未知位置',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return const Center(
      child: Text('最近交易功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildMyItemsList() {
    return const Center(
      child: Text('我的物品列表功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildDiscoverItemsList() {
    return const Center(
      child: Text('发现物品功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildPointsCard() {
    return const Center(
      child: Text('积分卡片功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildPointsActions() {
    return const Center(
      child: Text('积分操作功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildPointsTasks() {
    return const Center(
      child: Text('积分任务功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildCreditCard() {
    return const Center(
      child: Text('信用卡片功能开发中...', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildCreditStats() {
    return const Center(
      child: Text('信用统计功能开发中...', style: TextStyle(color: Colors.grey)),
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
