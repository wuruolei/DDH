/// 广告数据模型
class Advertisement {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? targetUrl;
  final String backgroundColor;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? iconName;
  final String? actionType;
  final String? actionUrl;

  const Advertisement({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.targetUrl,
    required this.backgroundColor,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.iconName,
    this.actionType,
    this.actionUrl,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['imageUrl'],
      targetUrl: json['targetUrl'],
      backgroundColor: json['backgroundColor'] ?? '#667eea',
      isActive: json['isActive'] ?? true,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      iconName: json['iconName'],
      actionType: json['actionType'],
      actionUrl: json['actionUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
      'backgroundColor': backgroundColor,
      'isActive': isActive,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'iconName': iconName,
      'actionType': actionType,
      'actionUrl': actionUrl,
    };
  }

  /// 默认广告数据
  static List<Advertisement> getDefaultAds() {
    return [
      Advertisement(
        id: 'default_1',
        title: '新用户福利',
        subtitle: '注册即送1000积分，快来体验吧！',
        backgroundColor: '#667eea',
        targetUrl: '/register',
      ),
      Advertisement(
        id: 'default_2',
        title: '积分翻倍',
        subtitle: '本周签到积分翻倍，不要错过！',
        backgroundColor: '#4CAF50',
        targetUrl: '/checkin',
      ),
      Advertisement(
        id: 'default_3',
        title: '热门推荐',
        subtitle: '精选商品限时兑换，数量有限！',
        backgroundColor: '#FF5722',
        targetUrl: '/exchange',
      ),
    ];
  }
}
