import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/color_scheme_manager.dart';
import 'ui/screens/business/main_tab_screen_clean.dart';

void main() {
  runApp(const DDHExchangeApp());
}

class DDHExchangeApp extends StatelessWidget {
  const DDHExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '点点换 - 积分易货平台',
      debugShowCheckedModeBanner: false,
      theme: ColorSchemeManager.getLightTheme(),
      darkTheme: ColorSchemeManager.getDarkTheme(),
      home: const MainTabScreenClean(),
    );
  }
}

/// 简化的主标签屏幕
class MainTabScreenClean extends StatefulWidget {
  const MainTabScreenClean({super.key});

  @override
  State<MainTabScreenClean> createState() => _MainTabScreenCleanState();
}

class _MainTabScreenCleanState extends State<MainTabScreenClean> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExchangeScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: '易货',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '钱包',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

/// 简化的首页
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('点点换'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home,
              size: 64,
              color: BrandColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '欢迎来到点点换',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '积分兑换与用户易货平台',
              style: TextStyle(
                fontSize: 16,
                color: TextColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简化的易货页面
class ExchangeScreen extends StatelessWidget {
  const ExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('易货市场'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 64,
              color: BrandColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '易货市场',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '发现更多易货机会',
              style: TextStyle(
                fontSize: 16,
                color: TextColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简化的钱包页面
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的钱包'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: BrandColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '我的钱包',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '管理您的积分和余额',
              style: TextStyle(
                fontSize: 16,
                color: TextColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 简化的个人页面
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              size: 64,
              color: BrandColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              '个人中心',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '管理您的账户信息',
              style: TextStyle(
                fontSize: 16,
                color: TextColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
