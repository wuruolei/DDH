import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'services/logger.dart';
import 'services/advertisement_service.dart';
import 'services/storage_service.dart';
import 'models/advertisement.dart';
import 'models/user.dart';
import 'ui/widgets/banner_carousel.dart';

void main() {
  runApp(const DDHEnhancedApp());
}

class DDHEnhancedApp extends StatelessWidget {
  const DDHEnhancedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '点点换 - 积分兑换易货平台',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        fontFamily: GoogleFonts.nunito().fontFamily,
      ),
      home: const EnhancedMainTabScreen(),
    );
  }
}

class EnhancedMainTabScreen extends StatefulWidget {
  const EnhancedMainTabScreen({super.key});

  @override
  State<EnhancedMainTabScreen> createState() => _EnhancedMainTabScreenState();
}

class _EnhancedMainTabScreenState extends State<EnhancedMainTabScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoading = false;

  // 动画控制器
  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  late AnimationController _pageAnimationController;
  late Animation<double> _pageAnimation;

  // 搜索功能
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];

  // 热门搜索标签
  final List<String> _hotSearchTags = [
    'iPhone', 'AirPods', '保温杯', '蓝牙耳机', '运动手环',
    '面膜', '口红', '瑜伽垫', '智能手表', '香水'
  ];

  // 广告服务
  final AdvertisementService _advertisementService = AdvertisementService();

  // 广告数据
  List<Advertisement> _bannerAds = [];
  List<Advertisement> _welcomeAds = [];
  int _currentAdIndex = 0;
  Timer? _adTimer;

  // 页面控制器
  PageController _adPageController = PageController();
  PageController _welcomePageController = PageController();

  // 购物车
  List<Map<String, dynamic>> _cartItems = [];
  int get _totalCartPoints => _cartItems.fold(0, (sum, item) => sum + (item['points'] as int) * (item['quantity'] as int));

  // 模拟数据
  final List<Map<String, dynamic>> _recommendedItems = [
    {
      'id': 1,
      'name': 'iPhone 15 Pro',
      'description': '全新苹果手机，256GB存储',
      'points': 8000,
      'image': 'assets/images/iphone.jpg',
      'category': '数码产品',
      'stock': 5,
    },
    {
      'id': 2,
      'name': 'AirPods Pro',
      'description': '苹果无线降噪耳机',
      'points': 1500,
      'image': 'assets/images/airpods.jpg',
      'category': '数码产品',
      'stock': 10,
    },
    {
      'id': 3,
      'name': '保温杯',
      'description': '304不锈钢保温杯，500ml',
      'points': 200,
      'image': 'assets/images/cup.jpg',
      'category': '生活用品',
      'stock': 20,
    },
    {
      'id': 4,
      'name': '蓝牙耳机',
      'description': '高品质蓝牙耳机，续航20小时',
      'points': 300,
      'image': 'assets/images/headphones.jpg',
      'category': '数码产品',
      'stock': 15,
    },
    {
      'id': 5,
      'name': '面膜套装',
      'description': '补水保湿面膜，10片装',
      'points': 150,
      'image': 'assets/images/mask.jpg',
      'category': '美妆护肤',
      'stock': 30,
    },
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'id': 1,
      'type': 'exchange',
      'title': '兑换 AirPods Pro',
      'points': -1500,
      'date': '2024-01-15',
      'status': '已完成',
    },
    {
      'id': 2,
      'type': 'earn',
      'title': '签到奖励',
      'points': 50,
      'date': '2024-01-14',
      'status': '已到账',
    },
    {
      'id': 3,
      'type': 'exchange',
      'title': '兑换保温杯',
      'points': -200,
      'date': '2024-01-13',
      'status': '已完成',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _loadAdvertisements();
    _startAdTimer();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();
    _pageAnimationController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // 模拟数据加载
      await Future.delayed(const Duration(milliseconds: 500));
      Logger.info('数据加载完成');
    } catch (e) {
      Logger.error('数据加载失败: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAdvertisements() async {
    try {
      _bannerAds = await _advertisementService.getBanners();
      _welcomeAds = await _advertisementService.getBanners();
      setState(() {});
      Logger.info('广告数据加载完成，共${_bannerAds.length}条横幅广告');
    } catch (e) {
      Logger.error('广告数据加载失败: $e');
    }
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    if (_bannerAds.isNotEmpty) {
      _adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          _nextAd();
        }
      });
    }
  }

  void _nextAd() {
    if (_bannerAds.isNotEmpty) {
      setState(() {
        _currentAdIndex = (_currentAdIndex + 1) % _bannerAds.length;
      });
      _adPageController.animateToPage(
        _currentAdIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousAd() {
    if (_bannerAds.isNotEmpty) {
      setState(() {
        _currentAdIndex = (_currentAdIndex - 1 + _bannerAds.length) % _bannerAds.length;
      });
      _adPageController.animateToPage(
        _currentAdIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _handleAdClick(Advertisement ad) async {
    try {
      await _advertisementService.recordAdClick(ad);
      
      if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) {
        String? link = ad.targetUrl;
        if (link == '/exchange') {
          setState(() {
            _selectedIndex = 1; // 跳转到兑换页
          });
        } else if (link == '/profile') {
          setState(() {
            _selectedIndex = 2; // 跳转到个人中心
          });
        } else if (link!.startsWith('http')) {
          // 外部链接
          final Uri url = Uri.parse(link);
          if (await canLaunchUrl(url)) {
            await launchUrl(url);
          }
        }
      }
      
      Logger.info('广告点击处理完成: ${ad.title}');
    } catch (e) {
      Logger.error('广告点击处理失败: $e');
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    final existingIndex = _cartItems.indexWhere((cartItem) => cartItem['id'] == item['id']);
    
    setState(() {
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['quantity']++;
      } else {
        _cartItems.add({
          ...item,
          'quantity': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} 已加入购物车'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '查看',
          onPressed: _showCartDialog,
        ),
      ),
    );
  }

  void _removeFromCart(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  void _updateCartItemQuantity(int index, int quantity) {
    setState(() {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index]['quantity'] = quantity;
      }
    });
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('购物车'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _cartItems.isEmpty
              ? const Center(child: Text('购物车为空'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.shopping_bag, color: Colors.grey[600]),
                            ),
                            title: Text(item['name']),
                            subtitle: Text('${item['points']} 积分'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => _updateCartItemQuantity(index, item['quantity'] - 1),
                                ),
                                Text('${item['quantity']}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => _updateCartItemQuantity(index, item['quantity'] + 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeFromCart(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '总计: $_totalCartPoints 积分',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _processCartCheckout();
                          },
                          child: const Text('立即兑换'),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _processCartCheckout() {
    if (_cartItems.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认兑换'),
        content: Text('确定要兑换这些商品吗？总计 $_totalCartPoints 积分'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('兑换成功！')),
              );
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索商品'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '输入商品名称...',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行搜索逻辑
              _performSearch(_searchController.text);
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    setState(() {
      _searchResults = _recommendedItems
          .where((item) => item['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
      _selectedIndex = 1; // 切换到兑换页面显示搜索结果
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('找到 ${_searchResults.length} 个相关商品')),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _pageAnimationController.dispose();
    _searchController.dispose();
    _adPageController.dispose();
    _welcomePageController.dispose();
    _adTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _pageAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _pageAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 50 * (1 - _pageAnimation.value)),
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildHomeTab(),
                  _buildExchangeTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AnimatedBuilder(
        animation: _logoAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _logoAnimation.value,
            child: Text(
              '点点换',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.blue[600],
      elevation: 0,
      actions: [
        IconButton(
          icon: Badge(
            label: Text('${_cartItems.length}'),
            isLabelVisible: _cartItems.isNotEmpty,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          onPressed: _showCartDialog,
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        _pageAnimationController.reset();
        _pageAnimationController.forward();
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue[600],
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.nunito(),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz),
          label: '兑换',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex != 0) return null;
    
    return FloatingActionButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布功能开发中...')),
        );
      },
      backgroundColor: Colors.orange[600],
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdBanner(),
            const SizedBox(height: 24),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildSectionTitle('推荐物品', Icons.recommend),
            const SizedBox(height: 16),
            _buildRecommendedItems(),
            const SizedBox(height: 24),
            _buildSectionTitle('最近交易', Icons.history),
            const SizedBox(height: 16),
            _buildRecentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeTab() {
    final displayItems = _searchResults.isNotEmpty ? _searchResults : _recommendedItems;
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.stars, color: Colors.orange[600], size: 24),
              const SizedBox(width: 8),
              Text(
                '可用积分: 1250',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.blue[600]),
                onPressed: _showCartDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return _buildExchangeItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileStats(),
          const SizedBox(height: 24),
          _buildProfileMenu(),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    if (_bannerAds.isEmpty) {
      return _buildDefaultAdBanner();
    }

    return Container(
      height: 180,
      child: PageView.builder(
        controller: _adPageController,
        onPageChanged: (index) {
          setState(() => _currentAdIndex = index);
        },
        itemCount: _bannerAds.length,
        itemBuilder: (context, index) {
          final ad = _bannerAds[index];
          return GestureDetector(
            onTap: () => _handleAdClick(ad),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.blue[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.campaign, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ad.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ad.subtitle ?? '精选推荐',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '立即查看',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Row(
                              children: List.generate(_bannerAds.length, (dotIndex) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  width: dotIndex == _currentAdIndex ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: dotIndex == _currentAdIndex
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAdBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[300], size: 28),
                    const SizedBox(width: 12),
                    Text(
                      '新用户福利',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '注册送500积分，立即开始兑换之旅',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '立即体验',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.stars, color: Colors.amber[300], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '当前积分: 1250',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('今日签到', '已完成', Icons.check_circle, Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('本月兑换', '3次', Icons.swap_horiz, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('积分余额', '1250', Icons.stars, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.nunito(
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            if (title.contains('推荐')) {
              setState(() => _selectedIndex = 1);
            }
          },
          child: Text(
            '查看更多',
            style: GoogleFonts.nunito(
              color: Colors.blue[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItems() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Icon(Icons.shopping_bag, color: Colors.grey[600], size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.stars, color: Colors.orange[600], size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${item['points']}',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _addToCart(item),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
    return Column(
      children: _recentTransactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: transaction['type'] == 'exchange' 
                      ? Colors.red[50] 
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  transaction['type'] == 'exchange' 
                      ? Icons.swap_horiz 
                      : Icons.add_circle,
                  color: transaction['type'] == 'exchange' 
                      ? Colors.red[600] 
                      : Colors.green[600],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['date'],
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction['points'] > 0 ? '+' : ''}${transaction['points']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: transaction['points'] > 0 
                          ? Colors.green[600] 
                          : Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      transaction['status'],
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExchangeItemCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(Icons.shopping_bag, color: Colors.grey[600], size: 48),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.orange[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${item['points']}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '立即兑换',
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: 48,
              color: Colors.purple[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '点点用户',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'VIP会员',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Row(
      children: [
        Expanded(
          child: _buildProfileStatCard('总积分', '1250', Icons.stars, Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProfileStatCard('兑换次数', '15', Icons.swap_horiz, Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProfileStatCard('会员等级', 'VIP', Icons.diamond, Colors.purple),
        ),
      ],
    );
  }

  Widget _buildProfileStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final menuItems = [
      {'title': '我的积分', 'icon': Icons.stars, 'color': Colors.orange},
      {'title': '兑换记录', 'icon': Icons.history, 'color': Colors.blue},
      {'title': '我的收藏', 'icon': Icons.favorite, 'color': Colors.red},
      {'title': '设置', 'icon': Icons.settings, 'color': Colors.grey},
      {'title': '帮助与反馈', 'icon': Icons.help, 'color': Colors.green},
      {'title': '关于我们', 'icon': Icons.info, 'color': Colors.purple},
    ];

    return Column(
      children: menuItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['title']} 功能开发中...')),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.grey[50],
          ),
        );
      }).toList(),
    );
  }
}
