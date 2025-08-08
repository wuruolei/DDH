/// 兑换商品数据模型
class ExchangeItem {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final int stock;
  final int exchangeCount;
  final DateTime? createdAt;

  const ExchangeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.stock = 0,
    this.exchangeCount = 0,
    this.createdAt,
  });

  factory ExchangeItem.fromJson(Map<String, dynamic> json) {
    return ExchangeItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pointsRequired: json['pointsRequired'] ?? 0,
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      stock: json['stock'] ?? 0,
      exchangeCount: json['exchangeCount'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pointsRequired': pointsRequired,
      'category': category,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'stock': stock,
      'exchangeCount': exchangeCount,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// 默认兑换商品数据
  static List<ExchangeItem> getDefaultItems() {
    return [
      ExchangeItem(
        id: 'item_1',
        name: '咖啡券',
        description: '星巴克中杯咖啡券',
        pointsRequired: 500,
        category: '优惠券',
        stock: 100,
        exchangeCount: 25,
      ),
      ExchangeItem(
        id: 'item_2',
        name: '电影票',
        description: '万达影城电影票',
        pointsRequired: 800,
        category: '优惠券',
        stock: 50,
        exchangeCount: 12,
      ),
      ExchangeItem(
        id: 'item_3',
        name: '购物卡',
        description: '京东购物卡50元',
        pointsRequired: 1000,
        category: '实物商品',
        stock: 30,
        exchangeCount: 8,
      ),
      ExchangeItem(
        id: 'item_4',
        name: 'VIP会员',
        description: '平台VIP会员1个月',
        pointsRequired: 1200,
        category: '会员权益',
        stock: 999,
        exchangeCount: 45,
      ),
      ExchangeItem(
        id: 'item_5',
        name: '游戏币',
        description: '手游充值100元',
        pointsRequired: 2000,
        category: '虚拟商品',
        stock: 20,
        exchangeCount: 5,
      ),
      ExchangeItem(
        id: 'item_6',
        name: '话费充值',
        description: '手机话费充值30元',
        pointsRequired: 600,
        category: '虚拟商品',
        stock: 200,
        exchangeCount: 67,
      ),
    ];
  }

  /// 根据分类获取商品
  static List<ExchangeItem> getItemsByCategory(String category) {
    return getDefaultItems()
        .where((item) => item.category == category)
        .toList();
  }

  /// 获取所有分类
  static List<String> getAllCategories() {
    return ['实物商品', '优惠券', '会员权益', '虚拟商品'];
  }
}
