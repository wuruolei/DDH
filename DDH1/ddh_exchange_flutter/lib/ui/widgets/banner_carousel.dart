import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/advertisement.dart';
import '../../services/advertisement_service.dart';
import '../../services/logger.dart';

/// 广告轮播组件
class BannerCarousel extends StatefulWidget {
  final double height;
  final Duration autoPlayInterval;
  final bool enableAutoPlay;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;

  const BannerCarousel({
    super.key,
    this.height = 180,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.enableAutoPlay = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AdvertisementService _bannerService = AdvertisementService();
  
  List<Advertisement> _banners = [];
  int _currentIndex = 0;
  Timer? _autoPlayTimer;
  bool _isLoading = true;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadBanners();
    if (widget.enableAutoPlay) {
      _startAutoPlay();
    }
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await _bannerService.getBanners();
      if (mounted) {
        setState(() {
          _banners = banners;
          _isLoading = false;
        });
        _fadeController.forward();
        _scaleController.forward();
        
        // 记录第一个广告的展示
        if (_banners.isNotEmpty) {
          _bannerService.trackBannerView(_banners[0].id);
        }
      }
    } catch (e) {
      Logger.error('加载广告失败', e);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (_banners.isNotEmpty && mounted) {
        _nextPage();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _nextPage() {
    if (_banners.isEmpty) return;
    
    final nextIndex = (_currentIndex + 1) % _banners.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_banners.isEmpty) return;
    
    final previousIndex = (_currentIndex - 1 + _banners.length) % _banners.length;
    _pageController.animateToPage(
      previousIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    
    // 记录广告展示
    if (index < _banners.length) {
      _bannerService.trackBannerView(_banners[index].id);
    }
  }

  void _onBannerTap(Advertisement banner) async {
    // 记录点击事件
    await _bannerService.recordAdClick(banner);

    if (!mounted) return;

    // 处理跳转
    if (banner.targetUrl != null && banner.targetUrl!.isNotEmpty) {
      // 外部链接跳转（这里可以集成url_launcher）
      Logger.info('跳转到外部链接: ${banner.targetUrl}');
      // 可以显示一个对话框或使用url_launcher
      _showExternalLinkDialog(banner.targetUrl!);
    }
  }

  void _showExternalLinkDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('跳转确认', style: GoogleFonts.poppins()),
        content: Text('即将跳转到外部链接：\n$url'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 这里可以使用url_launcher打开链接
              Logger.info('用户确认跳转到: $url');
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_banners.isEmpty) {
      return _buildEmptyWidget();
    }

    return Container(
      height: widget.height,
      margin: widget.margin,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) => FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildCarousel(),
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Stack(
      children: [
        // 主轮播区域
        ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _banners.length,
            itemBuilder: (context, index) => _buildBannerItem(_banners[index]),
          ),
        ),
        
        // 左右切换按钮
        if (_banners.length > 1) ...[
          _buildNavigationButton(
            alignment: Alignment.centerLeft,
            icon: Icons.chevron_left,
            onTap: _previousPage,
          ),
          _buildNavigationButton(
            alignment: Alignment.centerRight,
            icon: Icons.chevron_right,
            onTap: _nextPage,
          ),
        ],
        
        // 指示器
        if (_banners.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: _buildIndicators(),
          ),
      ],
    );
  }

  Widget _buildBannerItem(Advertisement banner) {
    final backgroundColor = _parseColor(banner.backgroundColor);
    const List<Color> gradientColors = [Colors.white];

    return GestureDetector(
      onTap: () => _onBannerTap(banner),
      onTapDown: (_) => _stopAutoPlay(),
      onTapUp: (_) => widget.enableAutoPlay ? _startAutoPlay() : null,
      onTapCancel: () => widget.enableAutoPlay ? _startAutoPlay() : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.8),
              backgroundColor.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景图片（如果有）
            if (banner.imageUrl != null && banner.imageUrl!.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  banner.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            
            // 渐变遮罩
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      backgroundColor.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            
            // 内容区域
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和副标题
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              banner.title,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner.subtitle,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 统计数据展示区域
                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatLabel('热门'),
                        _buildStatLabel('推荐'),
                        _buildStatLabel('新品'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatLabel(String label) {
    return Container(
      width: 50,
      height: 35,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required Alignment alignment,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                child: Icon(
                  icon,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _banners.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: index == _currentIndex ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? Colors.white
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      height: widget.height,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey[400], size: 48),
            const SizedBox(height: 8),
            Text(
              '暂无广告内容',
              style: GoogleFonts.nunito(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart': return Icons.shopping_cart;
      case 'star': return Icons.star;
      case 'schedule': return Icons.schedule;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'inventory': return Icons.inventory;
      case 'thumb_up': return Icons.thumb_up;
      case 'trending_up': return Icons.trending_up;
      case 'people': return Icons.people;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'devices': return Icons.devices;
      case 'local_offer': return Icons.local_offer;
      case 'verified': return Icons.verified;
      default: return Icons.star;
    }
  }

  @override
  void dispose() {
    _stopAutoPlay();
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
