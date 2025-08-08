import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const DDHMinimalApp());
}

class DDHMinimalApp extends StatelessWidget {
  const DDHMinimalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '点点换 - 最小版',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final PageController _adPageController = PageController();
  int _currentAdIndex = 0;
  Timer? _adTimer;
  List<Map<String, dynamic>> _cartItems = [];

  // 增强的广告数据 - 恢复原有数据结构
  final List<Map<String, String>> _adBanners = [
    {
      'title': '新用户福利',
      'subtitle': '注册即送500积分，立即开始兑换之旅',
      'color': 'purple',
      'buttonText': '立即体验',
      'targetPage': 'exchange',
    },
    {
      'title': '热门推荐',
      'subtitle': '精选好物限时兑换，数量有限先到先得',
      'color': 'red',
      'buttonText': '立即抢购',
      'targetPage': 'exchange',
    },
    {
      'title': '积分翻倍',
      'subtitle': '完成任务获得双倍积分奖励',
      'color': 'green',
      'buttonText': '去完成',
      'targetPage': 'tasks',
    },
  ];

  // 搜索功能相关状态 - 恢复原有搜索功能
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _searchHistory = [];
  
  // 热门搜索标签 - 恢复原有标签
  final List<String> _hotSearchTags = [
    'iPhone', 'AirPods', '保温杯', '蓝牙耳机', '运动手环', 
    '面膜', '口红', '瑜伽垫', '智能手表', '香水'
  ];

  // 推荐商品数据 - 恢复原有商品数据
  final List<Map<String, dynamic>> _recommendedItems = [
    {
      'id': 1,
      'name': 'iPhone 15 Pro',
      'description': '全新苹果手机，256GB存储',
      'points': 8000,
      'category': '数码产品',
      'stock': 5,
      'image': 'iphone.jpg',
    },
    {
      'id': 2,
      'name': 'AirPods Pro',
      'description': '苹果无线降噪耳机',
      'points': 1500,
      'category': '数码产品', 
      'stock': 10,
      'image': 'airpods.jpg',
    },
    {
      'id': 3,
      'name': '保温杯',
      'description': '304不锈钢保温杯，500ml',
      'points': 200,
      'category': '生活用品',
      'stock': 20,
      'image': 'cup.jpg',
    },
    {
      'id': 4,
      'name': '蓝牙耳机',
      'description': '高品质蓝牙耳机，续航20小时',
      'points': 300,
      'category': '数码产品',
      'stock': 15,
      'image': 'headphones.jpg',
    },
    {
      'id': 5,
      'name': '面膜套装',
      'description': '补水保湿面膜，10片装',
      'points': 150,
      'category': '美妆护肤',
      'stock': 30,
      'image': 'mask.jpg',
    },
  ];

  // 交易记录数据 - 恢复原有交易记录
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
    {
      'id': 4,
      'type': 'earn',
      'title': '完成任务奖励',
      'points': 100,
      'date': '2024-01-12',
      'status': '已到账',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAdTimer();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _pageController.dispose();
    _adPageController.dispose();
    super.dispose();
  }

  void _startAdTimer() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_adBanners.isNotEmpty && _adPageController.hasClients) {
        final nextIndex = (_currentAdIndex + 1) % _adBanners.length;
        setState(() {
          _currentAdIndex = nextIndex;
        });
        _adPageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cartItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} 已添加到购物车'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomePage(),
          _buildExchangePage(),
          _buildProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
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
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部安全区域
          const SizedBox(height: 50),
          
          // 品牌标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '点点换',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 广告轮播
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
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
                    Color bgColor;
                    switch (ad['color']) {
                      case 'purple':
                        bgColor = Colors.purple[400]!;
                        break;
                      case 'blue':
                        bgColor = Colors.blue[400]!;
                        break;
                      case 'green':
                        bgColor = Colors.green[400]!;
                        break;
                      default:
                        bgColor = Colors.blue[400]!;
                    }
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [bgColor, bgColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ad['title']!,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ad['subtitle']!,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                // 指示器
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _adBanners.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentAdIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 积分统计
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.orange[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的积分',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '2,580',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.stars,
                  size: 48,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 推荐商品
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '推荐商品',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: 40,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '商品 ${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                                  '${(index + 1) * 100}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
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
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExchangePage() {
    return Column(
      children: [
        // 顶部安全区域和标题
        Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
          child: Row(
            children: [
              Text(
                '积分兑换',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Stack(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 28,
                    color: Colors.blue[600],
                  ),
                  if (_cartItems.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${_cartItems.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // 分类标签
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCategoryChip('🔥 全部', true),
              _buildCategoryChip('📱 数码产品', false),
              _buildCategoryChip('🏠 生活用品', false),
              _buildCategoryChip('💄 美妆护肤', false),
              _buildCategoryChip('⚽ 运动健身', false),
            ],
          ),
        ),
        
        // 商品网格
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildEnhancedProductCard(
                '商品 ${index + 1}',
                '精选好物，限时兑换',
                (index + 1) * 100 + (index % 3) * 50,
                index,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // 个人信息卡片
          Container(
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
                  '用户名',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'user@example.com',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 功能菜单
          _buildMenuItem(Icons.edit, '编辑资料', '修改个人信息'),
          _buildMenuItem(Icons.security, '隐私安全', '账户安全设置'),
          _buildMenuItem(Icons.help, '帮助中心', '常见问题解答'),
          _buildMenuItem(Icons.info, '关于我们', '了解更多信息'),
          
          const SizedBox(height: 24),
          
          // 退出登录
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('退出登录功能')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[500],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '退出登录',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600]),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了 $title')),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.blue[600],
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('选择分类: $label')),
          );
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[600],
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedProductCard(String name, String description, int points, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    final color = colors[index % colors.length];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 商品图片区域
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color[100]!, color[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.shopping_bag,
                    color: color[600],
                    size: 48,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[500],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '热门',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 商品信息
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
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
                    description,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  
                  // 积分和按钮
                  Row(
                    children: [
                      Icon(Icons.stars, color: Colors.orange[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$points',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[600],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _addToCart({
                          'id': index + 1,
                          'name': name,
                          'description': description,
                          'points': points,
                          'category': '数码产品',
                          'stock': 10,
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color[600],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
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
    );
  }

  Widget _buildHomePage() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          _currentAdIndex = 0;
        });
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 广告轮播
            _buildAdCarousel(),
            SizedBox(height: 16),
            // 积分统计
            _buildPointsCard(),
            SizedBox(height: 16),
            // 快捷功能
            _buildQuickActions(),
            SizedBox(height: 16),
            // 购物车预览
            _buildCartPreview(),
          ],
        ),
      ),
    );
  }
}
