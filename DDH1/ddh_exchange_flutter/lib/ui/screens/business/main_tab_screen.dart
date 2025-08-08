import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/logger.dart';
import '../../../services/advertisement_service.dart';
import '../../../services/storage_service.dart';
import '../../../models/advertisement.dart';
import '../../../models/user.dart';
import '../../widgets/banner_carousel.dart';

/// 广告横幅数据模型
class AdBannerData {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final String buttonText;
  final String targetPage;

  const AdBannerData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.buttonText,
    required this.targetPage,
  });
}

/// 主标签页屏幕 - 清理版本
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = false;

  late AnimationController _logoAnimationController;
  late Animation<double> _logoAnimation;
  late AnimationController _pageAnimationController;
  late Animation<double> _pageAnimation;
  
  // 搜索功能相关状态
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  List<String> _searchHistory = [];
  
  // 热门搜索标签
  final List<String> _hotSearchTags = [
    'iPhone', 'AirPods', '保温杯', '蓝牙耳机', '运动手环', 
    '面膜', '口红', '瑜伽垫', '智能手表', '香水'
  ];
  
  // 发布功能相关状态
  final TextEditingController _publishNameController = TextEditingController();
  final TextEditingController _publishPointsController = TextEditingController();
  final TextEditingController _publishDescriptionController = TextEditingController();
  final TextEditingController _publishContactController = TextEditingController();
  String _selectedCategory = '';
  bool _isPublishing = false;
  
  // 发布分类选项
  final List<String> _publishCategories = [
    '数码产品', '生活用品', '美妆护肤', '运动健身', '其他'
  ];
  
  // 反馈功能相关状态
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _feedbackContactController = TextEditingController();
  String _selectedFeedbackType = '';
  
  // Tab导航相关状态
  int _selectedIndex = 0;
  
  // 发布功能额外状态变量
  String _selectedPublishCategory = '';
  List<String> _selectedPublishImages = [];
  
  // 广告服务
  final AdvertisementService _advertisementService = AdvertisementService();
  
  // 动态广告数据
  List<Advertisement> _bannerAds = [];
  List<Advertisement> _welcomeAds = [];
  Map<String, dynamic>? _adConfig;
  
  int _currentAdIndex = 0;
  Timer? _adTimer;
  
  int _currentWelcomeAdIndex = 0;
  PageController _welcomePageController = PageController();
  
  // 广告轮播相关
  PageController _adPageController = PageController();
  List<AdBannerData> _adBanners = [];
  
  // 广告数据模型
  final List<AdBannerData> _defaultAdBanners = [
    AdBannerData(
      title: '新用户福利',
      subtitle: '注册送500积分，立即开始兑换之旅',
      icon: Icons.star,
      gradientColors: [Colors.purple.shade400, Colors.purple.shade600, Colors.deepPurple.shade600],
      buttonText: '立即体验',
      targetPage: 'exchange',
    ),
    AdBannerData(
      title: '热门推荐',
      subtitle: '精选好物限时兑换，数量有限先到先得',
      icon: Icons.local_fire_department,
      gradientColors: [Colors.red.shade400, Colors.red.shade600, Colors.deepOrange.shade600],
      buttonText: '立即抢购',
      targetPage: 'exchange',
    ),
    AdBannerData(
      title: '积分翻倍',
      subtitle: '完成任务获得双倍积分，轻松兑换心仪商品',
      icon: Icons.trending_up,
      gradientColors: [Colors.green.shade400, Colors.green.shade600, Colors.teal.shade600],
      buttonText: '赚积分',
      targetPage: 'tasks',
    ),
    AdBannerData(
      title: '品牌专区',
      subtitle: 'Apple产品专享优惠，正品保证售后无忧',
      icon: Icons.devices,
      gradientColors: [Colors.blue.shade400, Colors.blue.shade600, Colors.indigo.shade600],
      buttonText: '查看详情',
      targetPage: 'exchange',
    ),
  ];
  
  // 加载状态
  bool _isLoadingAds = true;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    _logoAnimationController.repeat();
    
    _pageAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 初始化页面动画
    _pageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 启动页面动画
    _pageAnimationController.forward();
    
    // 初始化广告数据
    _adBanners = List.from(_defaultAdBanners);
    
    // 启动默认广告轮播
    _startWelcomeAdTimer();
    
    // 加载广告数据
    _loadAdvertisements();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟数据加载
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    // 刷新状态已简化
    await Future.delayed(const Duration(seconds: 1));
  }
  
  // 广告切换方法
  void _nextAd() {
    if (_adBanners.isEmpty) return;
    final nextIndex = (_currentAdIndex + 1) % _adBanners.length;
    _adPageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  void _previousAd() {
    if (_adBanners.isEmpty) return;
    final previousIndex = (_currentAdIndex - 1 + _adBanners.length) % _adBanners.length;
    _adPageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // 加载广告数据
  Future<void> _loadAdvertisements() async {
    try {
      setState(() {
        _isLoadingAds = true;
      });
      
      final advertisementResponse = await _advertisementService.getAdvertisements();
      final adConfig = await _advertisementService.getAdConfig();
      
      setState(() {
        _bannerAds = advertisementResponse; // 直接使用广告列表作为横幅广告
        _welcomeAds = advertisementResponse; // 同样用于欢迎页广告
        _adConfig = adConfig ?? {}; // 使用广告配置
        _isLoadingAds = false;
      });
      
      // 初始化广告轮播定时器
      _startAdTimer();
      
    } catch (e) {
      debugPrint('加载广告数据失败: $e');
      setState(() {
        _isLoadingAds = false;
      });
    }
  }
  
  // 启动广告轮播定时器
  void _startAdTimer() {
    _adTimer?.cancel(); // 取消现有定时器
    
    // 优先使用默认广告数据，确保轮播始终工作
    if (_adBanners.isNotEmpty) {
      _startWelcomeAdTimer();
      return;
    }
    
    // 备用：使用后台加载的广告数据
    final adsToUse = _bannerAds.isNotEmpty ? _bannerAds : [];
    if (adsToUse.isEmpty) return;
    
    // 从配置中获取轮播间隔，默认4秒
    final interval = _adConfig?['bannerAutoPlayInterval'] ?? 4000;
    final enableAutoPlay = _adConfig?['enableBannerAutoPlay'] ?? true;
    
    if (enableAutoPlay) {
      _adTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
        if (adsToUse.isNotEmpty) {
          setState(() {
            _currentAdIndex = (_currentAdIndex + 1) % adsToUse.length;
          });
        }
      });
    }
  }
  
  // 启动欢迎广告轮播定时器（用于默认广告数据）
  void _startWelcomeAdTimer() {
    _adTimer?.cancel();
    
    if (_adBanners.isEmpty) return;
    
    _adTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_adBanners.isNotEmpty) {
        final nextIndex = (_currentAdIndex + 1) % _adBanners.length;
        
        // 更新当前索引
        setState(() {
          _currentAdIndex = nextIndex;
        });
        
        // 执行页面切换动画（安全检查）
        if (_adPageController.hasClients) {
          _adPageController.animateToPage(
            nextIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }
  
  @override
  void dispose() {
    _logoAnimationController.dispose();
    _pageAnimationController.dispose();
    _adTimer?.cancel();
    _welcomePageController.dispose();
    _adPageController.dispose();
    _searchController.dispose();
    _publishNameController.dispose();
    _publishPointsController.dispose();
    _publishDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _pageAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildExchangeTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz),
            label: '兑换',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: _showPublishDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue[600],
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _logoAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.8,
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              // 主要阴影 - 更深层次
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                              // 蓝色光晕效果
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                                spreadRadius: 2,
                              ),
                              // 内部高光
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 4,
                                offset: const Offset(-1, -1),
                                spreadRadius: 0,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.blue[100]!.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.blue[50]!.withValues(alpha: 0.8),
                                  Colors.blue[100]!.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey[50]!,
                                    ],
                                  ),
                                ),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      'assets/images/app_logo.png', // 使用高清版本
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover, // 改为cover以获得更好的显示效果
                                      filterQuality: FilterQuality.high, // 高质量渲染
                                      errorBuilder: (context, error, stackTrace) {
                                        // 更精美的备用图标设计
                                        return Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.blue[400]!,
                                                Colors.blue[600]!,
                                                Colors.blue[800]!,
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // 背景装饰
                                              Positioned(
                                                top: 3,
                                                right: 3,
                                                child: Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.white.withOpacity(0.3),
                                                  ),
                                                ),
                                              ),
                                              // 主图标
                                              const Icon(
                                                Icons.swap_horiz,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  // 优化后的品牌文字
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '点点换',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: _showNotifications,
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: _showSearch,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: _isLoading ? _buildSkeletonLoader() : _buildHomeContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 广告轮播区域（包含新用户福利内容）
          _buildWelcomeCard(),
          const SizedBox(height: 32), // 增加间距
          
          // 用户统计数据
          _buildQuickStats(),
          const SizedBox(height: 32), // 增加间距
          
          // 积分易货区域
          _buildSectionTitle('积分易货', Icons.swap_horiz),
          const SizedBox(height: 16),
          _buildBarterSection(),
          const SizedBox(height: 40), // 增加区域间分隔
          
          // 推荐物品区域
          _buildSectionTitle('推荐物品', Icons.recommend),
          const SizedBox(height: 16),
          _buildRecommendedItems(),
          const SizedBox(height: 40), // 增加区域间分隔
          
          // 最近交易区域
          _buildSectionTitle('最近交易', Icons.history),
          const SizedBox(height: 16),
          _buildRecentTransactions(),
          
          // 底部留白，确保内容不被底部导航遮挡
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // 顶部扁平广告横幕
  Widget _buildAdBanner() {
    if (_isLoadingAds) {
      return Container(
        width: double.infinity,
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_bannerAds.isEmpty) return const SizedBox.shrink();
    
    final currentAd = _bannerAds[_currentAdIndex];
    
    return GestureDetector(
      onTap: () => _handleAdClick(currentAd),
      child: Container(
        width: double.infinity,
        height: 80, // 降低高度为扁平样式
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(int.parse(currentAd.backgroundColor.replaceFirst('#', '0xFF'))),
              Color(int.parse(currentAd.backgroundColor.replaceFirst('#', '0xFF'))).withOpacity(0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(int.parse(currentAd.backgroundColor.replaceFirst('#', '0xFF'))).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 左侧图标
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _advertisementService.getIconData(currentAd.iconName),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // 中间内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentAd.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentAd.subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // 右侧箭头
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.7),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 处理广告点击事件
  void _handleAdClick(Advertisement ad) async {
    try {
      if (ad.actionType == 'internal') {
        // 内部路由跳转
        final link = ad.actionUrl;
        if (link == '/exchange') {
          setState(() {
            _selectedIndex = 1; // 切换到兑换页
          });
        } else if (link != null && link.startsWith('/exchange?category=')) {
          setState(() {
            _selectedIndex = 1; // 切换到兑换页
          });
          // 这里可以添加具体的分类筛选逻辑
        }
      } else if (ad.targetUrl != null && ad.targetUrl!.startsWith('http')) {
        // 外部链接跳转
        final url = Uri.parse(ad.targetUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      }
      
      // 显示点击反馈
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '正在跳转到: ${ad.title}',
            style: GoogleFonts.nunito(color: Colors.white),
          ),
          backgroundColor: Color(int.parse(ad.backgroundColor.replaceFirst('#', '0xFF'))),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      // 错误处理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('跳转失败，请稍后再试'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 新用户福利卡片
  Widget _buildNewUserBenefitCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.purple[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '新用户福利',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '注册送500积分，立即开始兑换之旅',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.8),
            size: 18,
          ),
        ],
      ),
    );
  }
  
  // 欢迎卡片广告框架（左右可控制）
  Widget _buildWelcomeCard() {
    // 支持左右切换的广告轮播卡片
    return Container(
      width: double.infinity,
      height: 180,
      margin: const EdgeInsets.only(bottom: 24),
      child: Stack(
        children: [
          // 广告轮播主体
          PageView.builder(
            controller: _adPageController,
            onPageChanged: (index) {
              setState(() {
                _currentAdIndex = index;
              });
            },
            itemCount: _adBanners.length,
            itemBuilder: (context, index) {
              final ad = _adBanners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: ad.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ad.gradientColors[0].withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // 左侧内容
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 标题
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    ad.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                            const SizedBox(height: 12),
                            // 描述
                            Text(
                              ad.subtitle,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            // 行动按钮
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                ad.buttonText,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
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
          
          // 左切换按钮
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _previousAd();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 右切换按钮
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _nextAd();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 底部指示器
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _adBanners.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _currentAdIndex ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentAdIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 欢迎广告单项构建
  Widget _buildWelcomeAdItem(Advertisement ad) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          debugPrint('🎯 广告卡片被点击: ${ad.title}');
          print('🎯 广告卡片被点击: ${ad.title}'); // 确保在Web控制台显示
          _handleWelcomeAdClick(ad);
          
          // 显示点击反馈
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('点击了广告: ${ad.title}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Color(int.parse(ad.backgroundColor.replaceFirst('#', '0xFF'))),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
        width: double.infinity,
        height: 140, // 设置固定高度，避免布局约束问题
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(int.parse(ad.backgroundColor.replaceFirst('#', '0xFF'))),
              Color(int.parse(ad.backgroundColor.replaceFirst('#', '0xFF'))).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和图标行
              Row(
                children: [
                  Icon(
                    Icons.campaign,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18, // 稍微减小字体
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ad.subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12, // 稍微减小字体
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 广告统计信息（简化显示）
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildWelcomeStatItem('热度', '9.5', Icons.local_fire_department),
                  _buildWelcomeStatItem('参与', '1.2k', Icons.people),
                  _buildWelcomeStatItem('好评', '98%', Icons.thumb_up),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
  
  // 欢迎广告统计项 - 优化版本，彻底避免溢出
  Widget _buildWelcomeStatItem(String label, String value, IconData icon) {
    return Container(
      width: 50,
      height: 40, // 增加高度避免溢出
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(height: 2),
          // 数值
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 9, // 减小字体避免溢出
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // 标签
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 7, // 减小字体避免溢出
              color: Colors.white.withOpacity(0.8),
              height: 1.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  // 欢迎广告控制方法
  void _previousWelcomeAd() {
    if (_welcomeAds.isEmpty) return;
    
    if (_currentWelcomeAdIndex > 0) {
      _welcomePageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _welcomePageController.animateToPage(
        _welcomeAds.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _nextWelcomeAd() {
    if (_welcomeAds.isEmpty) return;
    
    if (_currentWelcomeAdIndex < _welcomeAds.length - 1) {
      _welcomePageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _welcomePageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  // 广告点击处理
  void _handleWelcomeAdClick(Advertisement ad) async {
    // 上报点击事件
    await _advertisementService.recordAdClick(ad);
    
    if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty) {
      // 内部路由跳转
      String? link = ad.targetUrl;
      if (link == '/exchange') {
        setState(() {
          _selectedIndex = 1; // 跳转到兑换页
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('跳转到兑换页面 - ${ad.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (link != null && link.contains('/exchange?category=')) {
        setState(() {
          _selectedIndex = 1; // 跳转到兑换页并筛选
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('跳转到热门商品 - ${ad.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (link == '/profile') {
        setState(() {
          _selectedIndex = 3; // 跳转到个人中心
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('跳转到个人中心 - ${ad.title}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.blue[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue[100]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[500],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue[400]!,
                  Colors.blue[600]!,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBarterAction('发布物品', Icons.add_circle_outline, Colors.green),
              _buildBarterAction('我的物品', Icons.inventory_2_outlined, Colors.blue),
              _buildBarterAction('发现物品', Icons.search, Colors.orange),
              _buildBarterAction('交易记录', Icons.history, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarterAction(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showComingSoon(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedItems() {
    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          final categories = [
            {'name': '数码产品', 'icon': Icons.phone_android, 'color': Colors.blue, 'gradient': [Colors.blue[400]!, Colors.blue[600]!]},
            {'name': '生活用品', 'icon': Icons.home, 'color': Colors.green, 'gradient': [Colors.green[400]!, Colors.green[600]!]},
            {'name': '美妆护肤', 'icon': Icons.face, 'color': Colors.pink, 'gradient': [Colors.pink[400]!, Colors.pink[600]!]},
            {'name': '运动健身', 'icon': Icons.fitness_center, 'color': Colors.orange, 'gradient': [Colors.orange[400]!, Colors.orange[600]!]},
            {'name': '图书文具', 'icon': Icons.book, 'color': Colors.purple, 'gradient': [Colors.purple[400]!, Colors.purple[600]!]},
          ];
          
          final category = categories[index];
          final gradient = category['gradient'] as List<Color>;
          
          return GestureDetector(
            onTap: () => _showComingSoon(),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    (category['color'] as Color).withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (category['color'] as Color).withOpacity(0.1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (category['color'] as Color).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradient,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (category['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category['name'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (category['color'] as Color).withOpacity(0.1),
                            (category['color'] as Color).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (category['color'] as Color).withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '${(index + 1) * 20}+ 商品',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: category['color'] as Color,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      children: List.generate(3, (index) {
        final transactions = [
          {
            'title': '易货成功',
            'subtitle': '您的iPhone耳机 ⇄ 蓝牙音箱',
            'points': '+50',
            'color': Colors.green,
          },
          {
            'title': '积分兑换',
            'subtitle': '兑换了星巴克咖啡券',
            'points': '-200',
            'color': Colors.red,
          },
          {
            'title': '发布奖励',
            'subtitle': '发布了全新运动鞋获得奖励',
            'points': '+10',
            'color': Colors.blue,
          },
        ];
        
        final transaction = transactions[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                (transaction['color'] as Color).withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (transaction['color'] as Color).withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (transaction['color'] as Color).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 2,
                offset: const Offset(0, -1),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (transaction['color'] as Color).withOpacity(0.8),
                      transaction['color'] as Color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (transaction['color'] as Color).withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _getTransactionIcon(transaction['title'] as String),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction['subtitle'] as String,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[600],
                        letterSpacing: 0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (transaction['color'] as Color).withOpacity(0.1),
                      (transaction['color'] as Color).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (transaction['color'] as Color).withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  transaction['points'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: transaction['color'] as Color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getTransactionIcon(String transactionType) {
    switch (transactionType) {
      case '易货成功':
        return Icons.swap_horiz;
      case '积分兑换':
        return Icons.redeem;
      case '发布奖励':
        return Icons.add_circle;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Widget _buildExchangeTab() {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF667eea),
                  const Color(0xFF764ba2),
                  const Color(0xFF6B73FF),
                  const Color(0xFF9068BE),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '积分兑换商城',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.8,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                onPressed: _showExchangeSearch,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                onPressed: _showExchangeCart,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.95),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 1,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                indicatorPadding: const EdgeInsets.all(6),
                labelColor: const Color(0xFF667eea),
                unselectedLabelColor: Colors.white.withOpacity(0.9),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                tabs: [
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🔥',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text('热门商品'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '📱',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text('数码产品'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🏠',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text('生活用品'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '💄',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text('美妆护肤'),
                        ],
                      ),
                    ),
                  ),
                  Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '⚽',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                          Text('运动健身'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildExchangeContent('热门商品'),
            _buildExchangeContent('数码产品'),
            _buildExchangeContent('生活用品'),
            _buildExchangeContent('美妆护肤'),
            _buildExchangeContent('运动健身'),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeContent(String category) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          // 积分信息卡片
          SliverToBoxAdapter(
            child: _buildPointsInfoCard(),
          ),
          // 商品网格
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final items = _getExchangeItems(category);
                  final item = items[index % items.length];
                  return _buildExchangeItem(item);
                },
                childCount: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B6B),
            const Color(0xFFFFE66D),
            const Color(0xFFFF8E53),
            const Color(0xFFFF6B35),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFFFF8E53).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '我的积分余额',
                                style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '1,250',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '积分',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🎉 今日获得 +50 积分',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildQuickPointsAction(
                  '赚积分',
                  Icons.add_circle_outline,
                  () => _showComingSoon(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickPointsAction(
                  '积分记录',
                  Icons.history,
                  _showPointsHistory,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickPointsAction(
                  '积分规则',
                  Icons.help_outline,
                  () => _showComingSoon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPointsAction(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeItem(Map<String, dynamic> item) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // 商品卡片点击事件
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('查看 ${item['name']} 详情'),
                backgroundColor: Colors.blue[600],
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 商品图片区域
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item['color'].withOpacity(0.1),
                          item['color'].withOpacity(0.05),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  item['color'].withOpacity(0.9),
                                  item['color'],
                                  item['color'].withOpacity(0.8),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: item['color'].withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: item['color'].withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 1,
                                  offset: const Offset(0, -1),
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'],
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // 商品徽章
                        if (item['badge'] != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    item['color'].withOpacity(0.9),
                                    item['color'],
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: item['color'].withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                item['badge'],
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // 商品信息区域
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 16,
                                      color: Colors.orange[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item['points']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[600],
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '积分',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // 立即兑换按钮 - 优化布局和位置
                            Container(
                              width: 85,
                              height: 36,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // 兑换按钮点击事件
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('正在兑换 ${item['name']}...'),
                                        backgroundColor: Colors.blue[600],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    width: 85,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue[400]!,
                                          Colors.blue[600]!,
                                          Colors.blue[700]!,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 1,
                                          offset: const Offset(0, -1),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '立即兑换',
                                            style: GoogleFonts.nunito(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getExchangeItems(String category) {
    switch (category) {
      case '热门商品':
        return [
          {'name': '星巴克咖啡券', 'points': 200, 'icon': Icons.local_cafe, 'color': Colors.brown, 'badge': '热门'},
          {'name': '网易云音乐VIP', 'points': 150, 'icon': Icons.music_note, 'color': Colors.red, 'badge': '新品'},
          {'name': '麦当劳套餐券', 'points': 300, 'icon': Icons.fastfood, 'color': Colors.orange, 'badge': '热门'},
          {'name': '爱奇艺会员', 'points': 180, 'icon': Icons.play_circle, 'color': Colors.green},
          {'name': '滴滴打车券', 'points': 100, 'icon': Icons.local_taxi, 'color': Colors.blue},
        ];
      case '数码产品':
        return [
          {'name': 'AirPods Pro', 'points': 1500, 'icon': Icons.headphones, 'color': Colors.grey, 'badge': '热门'},
          {'name': '小米手环7', 'points': 800, 'icon': Icons.watch, 'color': Colors.orange},
          {'name': '罗技鼠标', 'points': 400, 'icon': Icons.mouse, 'color': Colors.blue},
          {'name': '华为充电器', 'points': 300, 'icon': Icons.battery_charging_full, 'color': Colors.green},
          {'name': '蓝牙音箱', 'points': 600, 'icon': Icons.speaker, 'color': Colors.purple},
        ];
      case '生活用品':
        return [
          {'name': '保温杯', 'points': 250, 'icon': Icons.local_drink, 'color': Colors.pink},
          {'name': '毛巾套装', 'points': 180, 'icon': Icons.dry_cleaning, 'color': Colors.blue},
          {'name': '香薰蜡烛', 'points': 120, 'icon': Icons.local_fire_department, 'color': Colors.orange},
          {'name': '收纳盒', 'points': 200, 'icon': Icons.inventory_2, 'color': Colors.brown},
          {'name': '植物盆栽', 'points': 150, 'icon': Icons.local_florist, 'color': Colors.green},
        ];
      case '美妆护肤':
        return [
          {'name': '雅诗兰黛精华', 'points': 800, 'icon': Icons.face, 'color': Colors.pink, 'badge': '新品'},
          {'name': '欧莱雅面膜', 'points': 300, 'icon': Icons.face_retouching_natural, 'color': Colors.purple},
          {'name': '兰蔻口红', 'points': 400, 'icon': Icons.colorize, 'color': Colors.red},
          {'name': '科颜氨水', 'points': 350, 'icon': Icons.water_drop, 'color': Colors.blue},
          {'name': '美容仪', 'points': 1200, 'icon': Icons.spa, 'color': Colors.green},
        ];
      case '运动健身':
        return [
          {'name': '瑜伽垃', 'points': 200, 'icon': Icons.fitness_center, 'color': Colors.purple},
          {'name': '运动水杯', 'points': 120, 'icon': Icons.sports_baseball, 'color': Colors.blue},
          {'name': '跑步鞋', 'points': 600, 'icon': Icons.directions_run, 'color': Colors.orange},
          {'name': '健身手套', 'points': 80, 'icon': Icons.back_hand, 'color': Colors.grey},
          {'name': '蛋白粉', 'points': 400, 'icon': Icons.local_pharmacy, 'color': Colors.green},
        ];
      default:
        return [];
    }
  }

  Widget _buildProfileTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 个人信息卡片
            _buildProfileCard(),
            const SizedBox(height: 20),
            // 积分统计卡片
            _buildPointsStatsCard(),
            const SizedBox(height: 20),
            // 我的商品
            _buildMyItemsSection(),
            const SizedBox(height: 20),
            // 功能菜单
            _buildFunctionMenu(),
            const SizedBox(height: 20),
            // 设置与帮助
            _buildSettingsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSkeletonCard(height: 120),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSkeletonCard(height: 80)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 80)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 80)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSkeletonCard(height: 100),
          const SizedBox(height: 20),
          _buildSkeletonCard(height: 200),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildShimmerEffect(),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _logoAnimation.value - 0.3,
                _logoAnimation.value,
                _logoAnimation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('通知功能开发中...')),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        autofocus: true,
                        onChanged: (value) => _performSearch(value),
                        decoration: InputDecoration(
                          hintText: '搜索商品名称...',
                          hintStyle: GoogleFonts.nunito(
                            color: Colors.grey[500],
                          ),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: GoogleFonts.nunito(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 热门搜索
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '热门搜索',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hotSearchTags.map((tag) {
                      return GestureDetector(
                        onTap: () => _performSearch(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 搜索结果
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  void _showPublishDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Text(
                    '发布商品',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  _isPublishing 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: _isPublishing ? null : () {
                          if (_validatePublishForm()) {
                            Navigator.pop(context);
                            _publishItem();
                          }
                        },
                        child: Text(
                          '发布',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isPublishing ? Colors.grey[400] : Colors.blue[600],
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            // 发布表单
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品图片
                    _buildPublishImageSection(),
                    const SizedBox(height: 24),
                    // 商品名称
                    _buildPublishTextField('商品名称', '请输入商品名称', Icons.inventory, _publishNameController),
                    const SizedBox(height: 20),
                    // 商品分类
                    _buildPublishCategorySection(),
                    const SizedBox(height: 20),
                    // 积分价格
                    _buildPublishTextField('积分价格', '请输入积分数量', Icons.stars, _publishPointsController, isNumber: true),
                    const SizedBox(height: 20),
                    // 商品描述
                    _buildPublishDescriptionField(),
                    const SizedBox(height: 20),
                    // 联系方式
                    _buildPublishTextField('联系方式', '请输入您的联系方式', Icons.contact_phone, _publishContactController),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 搜索标题栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 24,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '搜索商品',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '取消',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 搜索输入框
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: '输入商品名称搜索...',
                  hintStyle: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 搜索内容区域
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildSearchSuggestions()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  // 搜索执行方法
  void _performSearch(String query) {
    setState(() {
      // 搜索查询已简化，直接清理结果
      _searchResults.clear();
      
      if (query.isEmpty) {
        return;
      }
      
      // 搜索所有分类的商品
      for (int i = 0; i < 5; i++) {
        final categoryItems = _getItemsForCategory(i);
        for (final item in categoryItems) {
          if (item['name'].toString().toLowerCase().contains(query.toLowerCase())) {
            _searchResults.add(item);
          }
        }
      }
      
      // 添加到搜索历史
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      }
    });
  }

  // 构建搜索建议页面
  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门搜索
          if (_hotSearchTags.isNotEmpty) ...[
            Text(
              '热门搜索',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hotSearchTags.map((tag) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = tag;
                    _performSearch(tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // 搜索历史
          if (_searchHistory.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索历史',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.clear();
                    });
                  },
                  child: Text(
                    '清空',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._searchHistory.map((history) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.history, color: Colors.grey[400], size: 20),
                title: Text(
                  history,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      _searchHistory.remove(history);
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 18),
                ),
                onTap: () {
                  _searchController.text = history;
                  _performSearch(history);
                },
              );
            }).toList(),
          ],
          
          // 搜索提示
          if (_searchHistory.isEmpty && _hotSearchTags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '输入关键词搜索商品',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '支持搜索商品名称、分类等',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 构建搜索结果页面
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '未找到相关商品',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '试试其他关键词或浏览热门商品',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // 搜索结果标题
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(
                '搜索结果',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_searchResults.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 搜索结果列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final item = _searchResults[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'],
                      size: 24,
                      color: item['color'],
                    ),
                  ),
                  title: Text(
                    item['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: Colors.orange[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${item['points']} 积分',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showProductDetails(item);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white,
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showExchangeCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽条
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '购物车',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '共${_cartItems.length}件商品',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: _cartItems.isNotEmpty ? _clearCart : null,
                        child: Text(
                          '清空',
                          style: GoogleFonts.nunito(
                            color: _cartItems.isNotEmpty ? Colors.red[600] : Colors.grey[400],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[200], height: 1),
            // 购物车内容
            Expanded(
              child: _buildCartContent(),
            ),
            // 底部结算栏
            if (_cartItems.isNotEmpty) _buildCartBottomBar(),
          ],
        ),
      ),
    );
  }

  void _showPointsHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 24,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '积分明细',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '关闭',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 积分总览
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前积分',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1,250',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '今日获得 +50 积分',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            // 积分记录列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildPointsHistoryItem(
                    '签到奖励',
                    '+20',
                    '今天 09:30',
                    Icons.event_available,
                    Colors.green,
                    true,
                  ),
                  _buildPointsHistoryItem(
                    '邀请好友奖励',
                    '+30',
                    '今天 08:15',
                    Icons.person_add,
                    Colors.blue,
                    true,
                  ),
                  _buildPointsHistoryItem(
                    '兑换商品',
                    '-150',
                    '昨天 16:42',
                    Icons.shopping_bag,
                    Colors.red,
                    false,
                  ),
                  _buildPointsHistoryItem(
                    '发布商品奖励',
                    '+100',
                    '昨天 14:20',
                    Icons.publish,
                    Colors.orange,
                    true,
                  ),
                  _buildPointsHistoryItem(
                    '完成任务',
                    '+50',
                    '2天前 10:30',
                    Icons.task_alt,
                    Colors.purple,
                    true,
                  ),
                  _buildPointsHistoryItem(
                    '兑换商品',
                    '-200',
                    '3天前 15:18',
                    Icons.shopping_bag,
                    Colors.red,
                    false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeItemDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item['icon'],
                            size: 40,
                            color: item['color'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    size: 20,
                                    color: Colors.orange[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['points']} 积分',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '商品详情',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '商品描述',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '这是一个优质的商品，适合日常使用。使用积分即可兑换，无需额外费用。品质保证，支持7天无理由退换。',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDetailTag('品质保证', Colors.green),
                              const SizedBox(width: 8),
                              _buildDetailTag('7天退换', Colors.blue),
                              const SizedBox(width: 8),
                              _buildDetailTag('积分兑换', Colors.orange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 商品规格信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '商品规格',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSpecRow('库存数量', '${(item['points'] / 10).round()}件'),
                          _buildSpecRow('兑换限制', '每人限兑1件'),
                          _buildSpecRow('有效期', '长期有效'),
                          _buildSpecRow('配送方式', '包邮到家'),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // 双按钮布局：加入购物车 + 立即兑换
                    Row(
                      children: [
                        // 加入购物车按钮
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[600]!, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _addToCart(item);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '加入购物车',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 立即兑换按钮
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmExchange(item);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '立即兑换',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  // 商品详情标签构建方法
  Widget _buildDetailTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // 商品规格行构建方法
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 积分明细记录项构建方法
  Widget _buildPointsHistoryItem(
    String title,
    String points,
    String time,
    IconData icon,
    Color color,
    bool isIncome,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          // 标题和时间
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // 积分变动
          Text(
            points,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green[600] : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  // 计算购物车总积分
  int _calculateTotalPoints() {
    return _cartItems.fold(0, (total, item) => total + (item['points'] as int));
  }

  // 清空购物车
  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '清空购物车',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '确定要清空购物车中的所有商品吗？',
          style: GoogleFonts.nunito(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('购物车已清空'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('确认清空', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 购物车结算
  void _checkoutCart() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('购物车为空，请先添加商品'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final totalPoints = _calculateTotalPoints();
    if (totalPoints > 1250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('积分余额不足，请移除部分商品'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '确认结算',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '即将兑换 ${_cartItems.length} 件商品',
              style: GoogleFonts.nunito(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '消耗积分: $totalPoints',
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Text(
              '剩余积分: ${1250 - totalPoints}',
              style: GoogleFonts.nunito(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCartCheckout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('确认兑换', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 处理购物车结算
  void _processCartCheckout() {
    setState(() {
      _cartItems.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('兑换成功！商品将在3-5个工作日内发货'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '查看订单',
          textColor: Colors.white,
          onPressed: () {
            // 跳转到订单页面
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('订单管理功能开发中...')),
            );
          },
        ),
      ),
    );
  }

  // 发布商品表单校验
  bool _validatePublishForm() {
    // 校验商品名称
    if (_publishNameController.text.trim().isEmpty) {
      _showValidationError('请输入商品名称');
      return false;
    }
    
    if (_publishNameController.text.trim().length < 2) {
      _showValidationError('商品名称至少需要2个字符');
      return false;
    }

    // 校验积分价格
    if (_publishPointsController.text.trim().isEmpty) {
      _showValidationError('请输入积分价格');
      return false;
    }
    
    final points = int.tryParse(_publishPointsController.text.trim());
    if (points == null || points <= 0) {
      _showValidationError('积分价格必须为正整数');
      return false;
    }
    
    if (points < 10 || points > 10000) {
      _showValidationError('积分价格必须在10-10000之间');
      return false;
    }

    // 校验商品分类
    if (_selectedPublishCategory.isEmpty) {
      _showValidationError('请选择商品分类');
      return false;
    }

    // 校验商品描述
    if (_publishDescriptionController.text.trim().isEmpty) {
      _showValidationError('请输入商品描述');
      return false;
    }
    
    if (_publishDescriptionController.text.trim().length < 10) {
      _showValidationError('商品描述至少需要10个字符');
      return false;
    }

    // 校验联系方式
    if (_publishContactController.text.trim().isEmpty) {
      _showValidationError('请输入联系方式');
      return false;
    }

    return true;
  }

  // 显示校验错误信息
  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // 发布商品处理
  void _publishItem() {
    setState(() {
      _isPublishing = true;
    });

    // 模拟发布过程
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isPublishing = false;
      });

      // 清空表单
      _publishNameController.clear();
      _publishPointsController.clear();
      _publishDescriptionController.clear();
      _publishContactController.clear();
      _selectedPublishCategory = '';
      _selectedPublishImages.clear();

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '商品发布成功！审核通过后将显示在兑换列表中',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: SnackBarAction(
            label: '查看我的发布',
            textColor: Colors.white,
            onPressed: () {
              // 跳转到个人中心的发布管理
              setState(() {
                _selectedIndex = 2; // 切换到个人中心页面
              });
            },
          ),
        ),
      );
    });
  }

  void _confirmExchange(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '确认兑换',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '是否确认使用 ${item['points']} 积分兑换 ${item['name']}?',
              style: GoogleFonts.nunito(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('当前积分: ', style: GoogleFonts.nunito(fontSize: 12)),
                Text('1,250', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('兑换后: ', style: GoogleFonts.nunito(fontSize: 12)),
                Text('${1250 - item['points']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processExchange(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('确认兑换', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _processExchange(Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('兑换成功！${item['name']} 已加入您的账户'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }



  void _showShoppingCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 购物车标题栏
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 24,
                      color: Colors.blue[600],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '购物车',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_cartItems.length}件商品',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 清空购物车按钮
                    if (_cartItems.isNotEmpty)
                      GestureDetector(
                        onTap: _clearCart,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 14,
                                color: Colors.red[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '清空',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // 购物车商品列表
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildCartItem({
                      'name': 'iPhone 15 Pro',
                      'points': 8888,
                      'icon': Icons.phone_iphone,
                      'color': Colors.blue,
                      'quantity': 1,
                    }),
                    const SizedBox(height: 12),
                    _buildCartItem({
                      'name': '蓝牙耳机',
                      'points': 299,
                      'icon': Icons.headphones,
                      'color': Colors.purple,
                      'quantity': 2,
                    }),
                    const SizedBox(height: 12),
                    _buildCartItem({
                      'name': '运动手环',
                      'points': 199,
                      'icon': Icons.watch,
                      'color': Colors.green,
                      'quantity': 1,
                    }),
                  ],
                ),
              ),
              // 购物车底部结算区
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Column(
                  children: [
                    // 积分余额显示
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 20,
                            color: Colors.blue[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '当前积分余额: ',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            '1,250',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '合计积分:',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.stars,
                              size: 20,
                              color: Colors.orange[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_calculateTotalPoints()} 积分',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 积分余额检查
                    if (_calculateTotalPoints() > 1250)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              size: 16,
                              color: Colors.red[600],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '积分余额不足，请先移除部分商品',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.red[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _calculateTotalPoints() <= 1250 ? () {
                          Navigator.pop(context);
                          _checkoutCart();
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '立即结算',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 商品图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'],
              size: 28,
              color: item['color'],
            ),
          ),
          const SizedBox(width: 12),
          // 商品信息
          Expanded(
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
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['points']} 积分',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 数量控制
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // 减少数量
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${item['quantity']}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // 增加数量
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  // 获取指定分类的商品列表
  List<Map<String, dynamic>> _getItemsForCategory(int categoryIndex) {
    final categories = [
      // 热门商品
      [
        {'name': 'iPhone 15 Pro', 'points': 8888, 'icon': Icons.phone_iphone, 'color': Colors.blue},
        {'name': 'MacBook Air', 'points': 12888, 'icon': Icons.laptop_mac, 'color': Colors.grey},
        {'name': 'AirPods Pro', 'points': 1888, 'icon': Icons.headphones, 'color': Colors.white},
        {'name': 'iPad Air', 'points': 4888, 'icon': Icons.tablet_mac, 'color': Colors.purple},
        {'name': 'Apple Watch', 'points': 2888, 'icon': Icons.watch, 'color': Colors.red},
        {'name': '蓝牙音箱', 'points': 599, 'icon': Icons.speaker, 'color': Colors.orange},
        {'name': '无线充电器', 'points': 299, 'icon': Icons.battery_charging_full, 'color': Colors.green},
        {'name': '手机壳', 'points': 99, 'icon': Icons.phone_android, 'color': Colors.brown},
        {'name': '数据线', 'points': 59, 'icon': Icons.cable, 'color': Colors.black},
        {'name': '移动电源', 'points': 199, 'icon': Icons.battery_charging_full, 'color': Colors.blue},
      ],
      // 数码产品
      [
        {'name': '智能手表', 'points': 1299, 'icon': Icons.watch_later, 'color': Colors.blue},
        {'name': '蓝牙耳机', 'points': 299, 'icon': Icons.headphones, 'color': Colors.purple},
        {'name': '平板电脑', 'points': 2599, 'icon': Icons.tablet, 'color': Colors.grey},
        {'name': '游戏手柄', 'points': 199, 'icon': Icons.gamepad, 'color': Colors.red},
        {'name': '键盘鼠标', 'points': 399, 'icon': Icons.keyboard, 'color': Colors.black},
        {'name': '显示器', 'points': 1899, 'icon': Icons.monitor, 'color': Colors.blue},
        {'name': '摄像头', 'points': 799, 'icon': Icons.camera_alt, 'color': Colors.orange},
        {'name': 'U盘', 'points': 89, 'icon': Icons.usb, 'color': Colors.green},
        {'name': '路由器', 'points': 299, 'icon': Icons.router, 'color': Colors.blue},
        {'name': '硬盘', 'points': 599, 'icon': Icons.storage, 'color': Colors.grey},
      ],
      // 生活用品
      [
        {'name': '保温杯', 'points': 199, 'icon': Icons.local_drink, 'color': Colors.blue},
        {'name': '台灯', 'points': 299, 'icon': Icons.lightbulb, 'color': Colors.yellow},
        {'name': '毛巾', 'points': 89, 'icon': Icons.dry_cleaning, 'color': Colors.pink},
        {'name': '枕头', 'points': 199, 'icon': Icons.bed, 'color': Colors.purple},
        {'name': '雨伞', 'points': 99, 'icon': Icons.beach_access, 'color': Colors.blue},
        {'name': '背包', 'points': 299, 'icon': Icons.backpack, 'color': Colors.brown},
        {'name': '水杯', 'points': 59, 'icon': Icons.local_cafe, 'color': Colors.blue},
        {'name': '餐具', 'points': 129, 'icon': Icons.restaurant, 'color': Colors.grey},
        {'name': '洗漱用品', 'points': 99, 'icon': Icons.cleaning_services, 'color': Colors.green},
        {'name': '收纳盒', 'points': 79, 'icon': Icons.inventory_2, 'color': Colors.orange},
      ],
      // 美妆护肤
      [
        {'name': '面膜', 'points': 199, 'icon': Icons.face, 'color': Colors.pink},
        {'name': '口红', 'points': 299, 'icon': Icons.colorize, 'color': Colors.red},
        {'name': '护肤品', 'points': 399, 'icon': Icons.spa, 'color': Colors.green},
        {'name': '香水', 'points': 599, 'icon': Icons.local_florist, 'color': Colors.purple},
        {'name': '化妆刷', 'points': 159, 'icon': Icons.brush, 'color': Colors.brown},
        {'name': '洗面奶', 'points': 129, 'icon': Icons.wash, 'color': Colors.blue},
        {'name': '眼霜', 'points': 299, 'icon': Icons.remove_red_eye, 'color': Colors.orange},
        {'name': '精华液', 'points': 499, 'icon': Icons.water_drop, 'color': Colors.blue},
        {'name': '防晒霜', 'points': 199, 'icon': Icons.wb_sunny, 'color': Colors.yellow},
        {'name': '卸妆水', 'points': 159, 'icon': Icons.cleaning_services, 'color': Colors.pink},
      ],
      // 运动健身
      [
        {'name': '运动鞋', 'points': 599, 'icon': Icons.directions_run, 'color': Colors.orange},
        {'name': '瑜伽垫', 'points': 199, 'icon': Icons.fitness_center, 'color': Colors.green},
        {'name': '哑铃', 'points': 299, 'icon': Icons.fitness_center, 'color': Colors.grey},
        {'name': '运动服', 'points': 299, 'icon': Icons.checkroom, 'color': Colors.blue},
        {'name': '跳绳', 'points': 59, 'icon': Icons.sports, 'color': Colors.red},
        {'name': '运动手环', 'points': 399, 'icon': Icons.watch, 'color': Colors.black},
        {'name': '运动水壶', 'points': 99, 'icon': Icons.sports_bar, 'color': Colors.blue},
        {'name': '护膝', 'points': 79, 'icon': Icons.healing, 'color': Colors.grey},
        {'name': '运动毛巾', 'points': 49, 'icon': Icons.dry_cleaning, 'color': Colors.white},
        {'name': '健身手套', 'points': 89, 'icon': Icons.back_hand, 'color': Colors.black},
      ],
    ];
    
    if (categoryIndex >= 0 && categoryIndex < categories.length) {
      return categories[categoryIndex];
    }
    return [];
  }

  // 显示商品详情弹窗
  void _showProductDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 商品详情内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 商品基本信息
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: item['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            item['icon'],
                            size: 40,
                            color: item['color'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.stars,
                                    size: 20,
                                    color: Colors.orange[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['points']} 积分',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // 商品描述
                    Text(
                      '商品描述',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '这是一款优质的${item['name']}，品质保证，积分兑换超值优惠。适合日常使用，性价比极高。',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // 双按钮布局：加入购物车 + 立即兑换
                    Row(
                      children: [
                        // 加入购物车按钮
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[600]!, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _addToCart(item);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 18,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '加入购物车',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 立即兑换按钮
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[400]!, Colors.blue[600]!],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _confirmExchange(item);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                '立即兑换',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildPublishImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品图片',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('图片上传功能开发中...')),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击上传图片',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishTextField(String label, String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(icon, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品分类',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: _publishCategories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[600] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.blue[600]! : Colors.blue[200]!,
                  ),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPublishDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '商品描述',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _publishDescriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '请详细描述商品的情况、新旧程度等...',
              hintStyle: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }


  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '此功能正在开发中，敬请期待！',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showServiceTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '服务条款页面正在开发中，敬请期待！',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _submitFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '反馈已提交，感谢您的建议！',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showUserAgreement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '用户协议页面正在开发中，敬请期待！',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '隐私政策页面正在开发中，敬请期待！',
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildLegalItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[600],
      ),
      onTap: onTap,
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue[600],
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      onTap: () => _showComingSoon(),
    );
  }

  Widget _buildSecurityItem(String title, IconData icon, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red[600] : Colors.blue[600],
        size: 24,
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red[600] : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[600],
      ),
      onTap: onTap,
    );
  }

  void _showChangePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('修改密码功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showChangePhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('手机绑定功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showChangeEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('邮箱绑定功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showTwoFactorAuth() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('双因子认证功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showLoginHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('登录记录功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeviceManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('设备管理功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDataDownload() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('数据下载功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showExportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导出积分记录', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('将为您导出以下数据：', style: GoogleFonts.nunito()),
            const SizedBox(height: 12),
            Text('• 积分获取和消费记录', style: GoogleFonts.nunito(fontSize: 14)),
            Text('• 商品兑换历史', style: GoogleFonts.nunito(fontSize: 14)),
            Text('• 信用评级变化', style: GoogleFonts.nunito(fontSize: 14)),
            Text('• 账户基本信息', style: GoogleFonts.nunito(fontSize: 14)),
            const SizedBox(height: 12),
            Text('数据将以Excel格式发送到您的邮箱', style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('积分记录导出功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Text('确认导出', style: GoogleFonts.nunito(color: Colors.blue[600])),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除账户', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
        content: Text('您确定要永久删除您的账户吗？此操作不可恢复！', style: GoogleFonts.nunito()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('账户删除功能正在开发中，敬请期待！', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white)),
                  backgroundColor: Colors.red[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Text('确认删除', style: GoogleFonts.nunito(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyItem(String title, String subtitle, bool value) {
    return SwitchListTile(
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: (bool newValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '设置已${newValue ? "开启" : "关闭"}，功能正在开发中！',
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.white),
            ),
            backgroundColor: Colors.blue[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      activeColor: Colors.blue[600],
    );
  }
  
  void _showAccountSecurity() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      '账户安全',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // 安全设置列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSecurityItem('修改密码', Icons.lock, '更新您的登录密码', () => _showChangePassword()),
                  _buildSecurityItem('手机绑定', Icons.phone, '已绑定 138****8888', () => _showChangePhone()),
                  _buildSecurityItem('邮箱绑定', Icons.email, '已绑定 user@example.com', () => _showChangeEmail()),
                  _buildSecurityItem('双因子认证', Icons.security, '已开启，提高账户安全性', () => _showTwoFactorAuth()),
                  _buildSecurityItem('登录记录', Icons.history, '查看最近登录记录', () => _showLoginHistory()),
                  _buildSecurityItem('设备管理', Icons.devices, '管理已登录设备', () => _showDeviceManagement()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      '隐私设置',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // 隐私设置列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // 核心隐私设置 - 只保留对积分兑换应用有用的功能
                  _buildPrivacyItem('接收推送通知', '积分变动、兑换成功等重要通知', true),
                  _buildPrivacyItem('商品推荐', '根据兑换记录推荐相关商品', true),
                  _buildPrivacyItem('交易记录公开', '允许其他用户查看我的信用评级', false),
                  
                  const SizedBox(height: 20),
                  Text(
                    '账户管理',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSecurityItem('导出积分记录', Icons.file_download, '下载我的积分和兑换记录', () => _showExportData()),
                  _buildSecurityItem('注销账户', Icons.delete_forever, '永久删除账户和所有数据', () => _showDeleteAccount(), isDestructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutUs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      '关于我们',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // 关于内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo 和品牌信息
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue[600]!, Colors.blue[400]!],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.swap_horiz,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '点点换',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '版本 1.2',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 产品介绍
                    Text(
                      '产品介绍',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '点点换是一个创新的积分易货平台，隶属于点点够总公司。我们致力于打造一个纯积分交易的生态系统，让用户可以通过积分进行商品易货，实现真正的无现金交易。',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 联系信息
                    Text(
                      '联系我们',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(Icons.email, '客服邮箱', 'leiggfans@gmail.com'),
                    _buildContactItem(Icons.phone, '客服热线', '400-662-5818'),
                    _buildContactItem(Icons.language, '官方网站', 'https://a.ddg.org.cn'),
                    const SizedBox(height: 24),
                    // 法律信息
                    Text(
                      '法律信息',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLegalItem('用户协议', () => _showUserAgreement()),
                    _buildLegalItem('隐私政策', () => _showPrivacyPolicy()),
                    _buildLegalItem('服务条款', () => _showServiceTerms()),
                    const SizedBox(height: 32),
                    // 版权信息
                    Center(
                      child: Text(
                        '© 2024 点点够科技有限公司\n京 ICP 备 12345678 号',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFeedback() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  Expanded(
                    child: Text(
                      '意见反馈',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _submitFeedback(),
                    child: Text(
                      '提交',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 反馈表单
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 反馈类型
                    Text(
                      '反馈类型',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: ['功能建议', '错误报告', '体验问题', '其他'].map((type) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFeedbackType = type;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedFeedbackType == type ? Colors.blue[600] : Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedFeedbackType == type ? Colors.blue[600]! : Colors.blue[200]!,
                              ),
                            ),
                            child: Text(
                              type,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: _selectedFeedbackType == type ? Colors.white : Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    // 反馈内容
                    Text(
                      '反馈内容',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _feedbackController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: '请详细描述您的意见或建议...',
                          hintStyle: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 联系方式
                    Text(
                      '联系方式（可选）',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _feedbackContactController,
                        decoration: InputDecoration(
                          hintText: '请输入您的邮箱或手机号，便于我们联系您',
                          hintStyle: GoogleFonts.nunito(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          prefixIcon: Icon(Icons.contact_phone, color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showPublishConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            Text(
              '发布成功',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确认发布以下商品吗？',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('商品名称：${_publishNameController.text}', 
                    style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('积分价格：${_publishPointsController.text} 积分', 
                    style: GoogleFonts.nunito(fontSize: 14, color: Colors.orange[600])),
                  const SizedBox(height: 4),
                  Text('商品分类：$_selectedCategory', 
                    style: GoogleFonts.nunito(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('联系方式：${_publishContactController.text}', 
                    style: GoogleFonts.nunito(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.poppins(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performPublish();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('确认发布', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
  
  void _performPublish() async {
    setState(() {
      _isPublishing = true;
    });
    
    // 模拟发布过程
    await Future.delayed(const Duration(seconds: 2));
    
    // 显示发布成功对话框
    _showPublishSuccessDialog();
    
    // 清空表单
    _clearPublishForm();
    
    setState(() {
      _isPublishing = false;
    });
  }
  
  void _showPublishSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            Text(
              '发布成功',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '您的商品已成功发布！',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Colors.orange[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '发布奖励 +10 积分',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• 其他用户可以在兑换页面看到您的商品\n• 有人对您的商品感兴趣时会通知您\n• 您可以在"我的"页面管理已发布的商品',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // 关闭发布弹窗
            },
            child: Text('知道了', style: GoogleFonts.poppins(color: Colors.blue[600])),
          ),
        ],
      ),
    );
  }
  
  void _clearPublishForm() {
    _publishNameController.clear();
    _publishPointsController.clear();
    _publishDescriptionController.clear();
    _publishContactController.clear();
    setState(() {
      _selectedCategory = '';
    });
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[500]!,
            Colors.indigo[600]!,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 头像 - 增强设计
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      Colors.blue[50]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  child: _buildUserAvatar(),
                ),
              ),
              const SizedBox(width: 20),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '点点用户',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        // VIP图标
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber[400]!, Colors.orange[500]!],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'VIP',
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber[300], size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Lv.3 黄金会员',
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.verified, color: Colors.green[300], size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: 1001 • 加入时间: 2024年1月',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 快捷操作按钮
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  '编辑资料',
                  Icons.edit_outlined,
                  () => _showComingSoon(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '我的二维码',
                  Icons.qr_code,
                  () => _showComingSoon(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  '分享邀请',
                  Icons.share_outlined,
                  () => _showComingSoon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange[400]!, Colors.orange[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '积分统计',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue[200]!, width: 1),
                ),
                child: GestureDetector(
                  onTap: () => _showComingSoon(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看明细',
                        style: GoogleFonts.nunito(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue[600],
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedStatItem('当前积分', '1,250', Icons.stars, Colors.orange, '可用余额'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatItem('累计获得', '3,680', Icons.trending_up, Colors.green, '总收入'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatItem('累计消费', '2,430', Icons.shopping_cart, Colors.blue, '总支出'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 增强版统计项组件
  Widget _buildEnhancedStatItem(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMyItemsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '我的商品',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () => _showComingSoon(),
                child: Text(
                  '管理全部',
                  style: GoogleFonts.nunito(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMyItemCard('已发布', '3', Icons.inventory, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMyItemCard('已兑换', '8', Icons.check_circle, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMyItemCard('进行中', '1', Icons.hourglass_empty, Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyItemCard(String title, String count, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _showComingSoon(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建用户头像 - 优先显示微信头像
  // 快捷操作按钮组件
  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    // TODO: 这里应该从用户状态管理中获取微信头像URL
    // 目前使用模拟数据，实际应该从AuthService或UserService中获取
    String? userAvatarUrl; // 从用户登录状态获取
    
    // 目前userAvatarUrl为null，直接显示默认头像
    // 后续集成真实用户状态时，可以恢复此逻辑
    if (false) { // userAvatarUrl != null && userAvatarUrl.isNotEmpty
      // 显示微信用户头像
      return Image.network(
        userAvatarUrl!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 网络头像加载失败时显示默认头像
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // 显示加载中的占位符
          return Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        },
      );
    } else {
      // 未登录或没有头像时显示默认头像
      return _buildDefaultAvatar();
    }
  }

  // 构建默认头像
  Widget _buildDefaultAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.blue[600]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFunctionMenu() {
    final menuItems = [
      {'title': '积分明细', 'icon': Icons.receipt_long, 'color': Colors.blue, 'subtitle': '查看积分流水'},
      {'title': '易货订单', 'icon': Icons.swap_horiz, 'color': Colors.green, 'subtitle': '交易记录'},
      {'title': '信用评价', 'icon': Icons.star_rate, 'color': Colors.orange, 'subtitle': '信用等级'},
      {'title': '收藏夹', 'icon': Icons.favorite, 'color': Colors.red, 'subtitle': '心仪商品'},
      {'title': '消息通知', 'icon': Icons.notifications, 'color': Colors.purple, 'subtitle': '系统消息'},
      {'title': '客服帮助', 'icon': Icons.support_agent, 'color': Colors.teal, 'subtitle': '在线客服'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.apps,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '常用功能',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              final color = item['color'] as Color;
              return GestureDetector(
                onTap: () => _showComingSoon(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.08),
                        color.withOpacity(0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settingsItems = [
      {'title': '账户安全', 'icon': Icons.security, 'color': Colors.green, 'subtitle': '密码与安全设置', 'action': () => _showAccountSecurity()},
      {'title': '隐私设置', 'icon': Icons.privacy_tip, 'color': Colors.blue, 'subtitle': '隐私保护设置', 'action': () => _showPrivacySettings()},
      {'title': '关于我们', 'icon': Icons.info, 'color': Colors.purple, 'subtitle': '应用信息', 'action': () => _showAboutUs()},
      {'title': '意见反馈', 'icon': Icons.feedback, 'color': Colors.orange, 'subtitle': '反馈建议', 'action': () => _showFeedback()},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[400]!, Colors.grey[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '设置与帮助',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...settingsItems.map((item) {
            final color = item['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: item['action'] as VoidCallback,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.05),
                        color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.15), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle'] as String,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: color,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.grey[300]!, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showLogoutDialog(),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.withOpacity(0.05),
                    Colors.red.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.15), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '退出登录',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '安全退出账户',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.red[400],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red[600] : Colors.grey[600],
      ),
      title: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: isDestructive ? Colors.red[600] : Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[600]),
            const SizedBox(width: 12),
            Text(
              '退出登录',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Text(
          '确定要退出当前账户吗？',
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: GoogleFonts.nunito(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('退出登录功能开发中...')),
              );
            },
            child: Text('退出', style: GoogleFonts.poppins(color: Colors.red[600])),
          ),
        ],
      ),
    );
  }

  // 购物车状态管理
  List<Map<String, dynamic>> _cartItems = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      // 查找是否已存在相同商品
      final existingIndex = _cartItems.indexWhere(
        (cartItem) => cartItem['name'] == item['name'],
      );
      
      if (existingIndex != -1) {
        // 如果已存在，增加数量
        _cartItems[existingIndex]['quantity'] = 
            (_cartItems[existingIndex]['quantity'] as int) + 1;
      } else {
        // 如果不存在，添加新商品
        final cartItem = Map<String, dynamic>.from(item);
        cartItem['quantity'] = 1;
        cartItem['addedTime'] = DateTime.now(); // 添加时间戳
        _cartItems.add(cartItem);
      }
    });
    
    // 显示增强的成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '已添加到购物车',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${item['name']} x 1',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  _showExchangeCart();
                },
                child: Text(
                  '查看',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
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



  int get _totalCartPoints {
    return _cartItems.fold(0, (sum, item) => sum + (item['points'] as int) * (item['quantity'] as int));
  }

  Widget _buildCartContent() {
    if (_cartItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '购物车还是空的',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '去挑选一些心仪的商品吧',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                '去选购',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 购物车商品列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              final quantity = item['quantity'] as int;
        
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
                    // 商品图标
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: item['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 商品信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.stars, color: Colors.orange[600], size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${item['points']} 积分',
                                style: GoogleFonts.nunito(
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 数量控制
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _updateCartItemQuantity(index, quantity - 1),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.remove,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          quantity.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _updateCartItemQuantity(index, quantity + 1),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // 删除按钮
                    GestureDetector(
                      onTap: () => _removeFromCart(index),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 推荐商品区域
        if (_cartItems.isNotEmpty) _buildCartRecommendations(),
      ],
    );
  }

  // 构建购物车推荐商品区域
  Widget _buildCartRecommendations() {
    // 获取推荐商品（排除已在购物车中的商品）
    final List<Map<String, dynamic>> recommendations = [];
    final cartItemNames = _cartItems.map((item) => item['name']).toSet();
    
    // 从各个分类中选择推荐商品
    for (int categoryIndex = 0; categoryIndex < 3; categoryIndex++) {
      final categoryItems = _getItemsForCategory(categoryIndex);
      for (final item in categoryItems) {
        if (!cartItemNames.contains(item['name']) && recommendations.length < 4) {
          recommendations.add(item);
        }
      }
    }
    
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '为你推荐',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                final item = recommendations[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['name'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.stars, color: Colors.orange[600], size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  '${item['points']}',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    color: Colors.orange[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addToCart(item),
                        child: Container(
                          padding: const EdgeInsets.all(6),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '合计',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.orange[600], size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$_totalCartPoints 积分',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCartCheckout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              '立即兑换',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }





}
