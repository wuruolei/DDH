import 'package:flutter/material.dart';
import '../models/advertisement.dart';
import 'logger.dart';

/// 广告服务类
/// 负责管理广告数据的加载、缓存和配置
class AdvertisementService {
  static final AdvertisementService _instance = AdvertisementService._internal();
  factory AdvertisementService() => _instance;
  AdvertisementService._internal();

  // Logger是静态类，不需要实例化

  /// 获取横幅广告列表
  Future<List<Advertisement>> getBannerAds() async {
    return getBanners();
  }

  /// 获取广告横幅列表（别名方法）
  Future<List<Advertisement>> getBanners() async {
    try {
      Logger.info('获取横幅广告数据');
      
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 返回默认广告数据
      return Advertisement.getDefaultAds();
    } catch (e) {
      Logger.error('获取横幅广告失败', e);
      return [];
    }
  }

  /// 获取欢迎页广告列表
  Future<List<Advertisement>> getWelcomeAds() async {
    try {
      Logger.info('获取欢迎页广告数据');
      
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 返回默认广告数据的子集
      final allAds = Advertisement.getDefaultAds();
      return allAds.take(3).toList();
    } catch (e) {
      Logger.error('获取欢迎页广告失败', e);
      return [];
    }
  }

  /// 获取广告配置
  Future<Map<String, dynamic>?> getAdConfig() async {
    try {
      Logger.info('获取广告配置');
      
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 200));
      
      return {
        'autoPlay': true,
        'interval': 4000, // 4秒切换
        'showIndicators': true,
        'enableManualControl': true,
        'animationDuration': 300,
      };
    } catch (e) {
      Logger.error('获取广告配置失败', e);
      return null;
    }
  }

  /// 记录广告点击事件
  Future<void> recordAdClick(Advertisement ad) async {
    try {
      Logger.info('记录广告点击: ${ad.title}');
      
      // 这里可以添加统计分析代码
      // 例如发送到分析服务器
      
      Logger.info('广告点击记录成功');
    } catch (e) {
      Logger.error('记录广告点击失败', e);
    }
  }

  /// 记录广告展示事件
  Future<void> recordAdImpression(Advertisement ad) async {
    return trackBannerView(ad.id);
  }

  /// 记录广告横幅查看统计
  Future<void> trackBannerView(String bannerId) async {
    try {
      Logger.info('记录广告查看: $bannerId');
      
      // 这里可以添加统计分析代码
      
      Logger.info('广告查看记录成功');
    } catch (e) {
      Logger.error('记录广告查看失败', e);
    }
  }

  /// 记录广告展示事件（原方法）
  Future<void> recordAdImpressionOriginal(Advertisement ad) async {
    try {
      Logger.info('记录广告展示: ${ad.title}');
      
      // 这里可以添加统计分析代码
      
      Logger.info('广告展示记录成功');
    } catch (e) {
      Logger.error('记录广告展示失败', e);
    }
  }

  /// 刷新广告数据
  Future<void> refreshAds() async {
    try {
      Logger.info('刷新广告数据');
      
      // 模拟刷新操作
      await Future.delayed(const Duration(milliseconds: 800));
      
      Logger.info('广告数据刷新完成');
    } catch (e) {
      Logger.error('刷新广告数据失败', e);
    }
  }

  /// 预加载广告资源
  Future<void> preloadAdResources(List<Advertisement> ads) async {
    try {
      Logger.info('预加载广告资源，数量: ${ads.length}');
      
      for (final ad in ads) {
        // 这里可以添加图片预加载逻辑
        Logger.debug('预加载广告资源: ${ad.title}');
      }
      
      Logger.info('广告资源预加载完成');
    } catch (e) {
      Logger.error('预加载广告资源失败', e);
    }
  }

  /// 获取所有广告列表
  Future<List<Advertisement>> getAdvertisements() async {
    try {
      Logger.info('获取广告列表');
      
      // 模拟网络延迟
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 返回默认广告数据
      return [
        Advertisement(
          id: 'ad_1',
          title: '新年特惠',
          subtitle: '积分兑换大优惠',
          backgroundColor: '0xFF667eea',
          iconName: 'celebration',
          actionType: 'exchange',
          actionUrl: '/exchange',
        ),
        Advertisement(
          id: 'ad_2', 
          title: '会员专享',
          subtitle: '更多权益等你来',
          backgroundColor: '0xFF764ba2',
          iconName: 'workspace_premium',
          actionType: 'profile',
          actionUrl: '/profile',
        ),
        Advertisement(
          id: 'ad_3',
          title: '每日签到',
          subtitle: '连续签到赢积分',
          backgroundColor: '0xFF6B73FF',
          iconName: 'auto_awesome',
          actionType: 'checkin',
          actionUrl: '/checkin',
        ),
      ];
    } catch (e) {
      Logger.error('获取广告列表失败', e);
      return [];
    }
  }

  /// 根据图标名称获取IconData
  IconData getIconData(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.star; // 默认图标
    }
    
    // 图标名称映射
    switch (iconName.toLowerCase()) {
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'local_offer':
        return Icons.local_offer;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'redeem':
        return Icons.redeem;
      case 'loyalty':
        return Icons.loyalty;
      case 'campaign':
        return Icons.campaign;
      case 'celebration':
        return Icons.celebration;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'diamond':
        return Icons.diamond;
      case 'workspace_premium':
        return Icons.workspace_premium;
      default:
        return Icons.star; // 默认图标
    }
  }
}
