import '../models/barter_model.dart';
import '../models/api_response.dart';
import 'network_service.dart';
import 'logger.dart';

/// 易货服务类
class BarterService {
  final NetworkService _networkService;
  final Logger _logger;

  BarterService({
    NetworkService? networkService,
    Logger? logger,
  })  : _networkService = networkService ?? NetworkService(),
        _logger = logger ?? Logger();

  /// 获取易货项目列表
  Future<ApiResponse<List<BarterItem>>> getBarterItems({
    BarterSearchCriteria? criteria,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('获取易货项目列表: 页码 $page');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 600));
      
      final mockItems = [
        BarterItem(
          id: 'item_1',
          title: 'iPhone 12',
          description: '九成新iPhone 12，128GB，黑色',
          imageUrl: 'https://example.com/iphone12.jpg',
          value: 3000.0,
          category: '电子产品',
          ownerId: 'user_1',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isActive: true,
          tags: ['手机', '苹果', '九成新'],
        ),
        BarterItem(
          id: 'item_2',
          title: 'MacBook Pro',
          description: 'MacBook Pro 13寸，M1芯片，256GB',
          imageUrl: 'https://example.com/macbook.jpg',
          value: 8000.0,
          category: '电子产品',
          ownerId: 'user_2',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isActive: true,
          tags: ['笔记本', '苹果', 'M1'],
        ),
        BarterItem(
          id: 'item_3',
          title: '自行车',
          description: '山地自行车，21速，适合户外运动',
          imageUrl: 'https://example.com/bike.jpg',
          value: 800.0,
          category: '运动器材',
          ownerId: 'user_3',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
          isActive: true,
          tags: ['自行车', '山地车', '运动'],
        ),
      ];

      return ApiResponse.success(data: mockItems);
    } catch (e) {
      Logger.error('获取易货项目列表失败: $e', e);
      return ApiResponse.error(message: '获取易货项目列表失败');
    }
  }

  /// 获取易货项目详情
  Future<ApiResponse<BarterItem>> getBarterItem(String itemId) async {
    try {
      Logger.info('获取易货项目详情: $itemId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockItem = BarterItem(
        id: itemId,
        title: 'iPhone 12',
        description: '九成新iPhone 12，128GB，黑色，无划痕，配件齐全',
        imageUrl: 'https://example.com/iphone12.jpg',
        value: 3000.0,
        category: '电子产品',
        ownerId: 'user_1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
        tags: ['手机', '苹果', '九成新'],
      );

      return ApiResponse.success(data: mockItem);
    } catch (e) {
      Logger.error('获取易货项目详情失败: $e');
      return ApiResponse.error(message: '获取易货项目详情失败');
    }
  }

  /// 创建易货项目
  Future<ApiResponse<BarterItem>> createBarterItem(BarterItem item) async {
    try {
      Logger.info('创建易货项目: ${item.title}');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 800));
      
      return ApiResponse.success(item);
    } catch (e) {
      Logger.error('创建易货项目失败: $e');
      return ApiResponse.error(message: '创建易货项目失败');
    }
  }

  /// 更新易货项目
  Future<ApiResponse<BarterItem>> updateBarterItem(BarterItem item) async {
    try {
      Logger.info('更新易货项目: ${item.id}');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 600));
      
      return ApiResponse.success(item);
    } catch (e) {
      Logger.error('更新易货项目失败: $e');
      return ApiResponse.error(message: '更新易货项目失败');
    }
  }

  /// 删除易货项目
  Future<ApiResponse<bool>> deleteBarterItem(String itemId) async {
    try {
      Logger.info('删除易货项目: $itemId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));
      
      return ApiResponse.success(data: true);
    } catch (e) {
      Logger.error('删除易货项目失败: $e');
      return ApiResponse.error(message: '删除易货项目失败');
    }
  }

  /// 创建易货交易
  Future<ApiResponse<BarterTransaction>> createBarterTransaction(
    String itemId,
    String buyerId,
    String sellerId,
  ) async {
    try {
      Logger.info('创建易货交易: 项目 $itemId, 买家 $buyerId, 卖家 $sellerId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 700));
      
      final transaction = BarterTransaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        itemId: itemId,
        buyerId: buyerId,
        sellerId: sellerId,
        status: BarterTransactionStatus.pending,
        createdAt: DateTime.now(),
      );

      return ApiResponse.success(transaction);
    } catch (e) {
      Logger.error('创建易货交易失败: $e');
      return ApiResponse.error(message: '创建易货交易失败');
    }
  }

  /// 获取用户易货交易列表
  Future<ApiResponse<List<BarterTransaction>>> getUserBarterTransactions(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('获取用户易货交易: $userId, 页码 $page');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockTransactions = [
        BarterTransaction(
          id: 'tx_1',
          itemId: 'item_1',
          buyerId: userId,
          sellerId: 'user_2',
          status: BarterTransactionStatus.accepted,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          completedAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        BarterTransaction(
          id: 'tx_2',
          itemId: 'item_2',
          buyerId: 'user_3',
          sellerId: userId,
          status: BarterTransactionStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ];

      return ApiResponse.success(data: mockTransactions);
    } catch (e) {
      Logger.error('获取用户易货交易失败: $e');
      return ApiResponse.error(message: '获取用户易货交易失败');
    }
  }

  /// 更新交易状态
  Future<ApiResponse<BarterTransaction>> updateTransactionStatus(
    String transactionId,
    BarterTransactionStatus status,
  ) async {
    try {
      Logger.info('更新交易状态: $transactionId -> $status');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 600));
      
      final transaction = BarterTransaction(
        id: transactionId,
        itemId: 'item_1',
        buyerId: 'user_1',
        sellerId: 'user_2',
        status: status,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        completedAt: status == BarterTransactionStatus.completed 
            ? DateTime.now() 
            : null,
      );

      return ApiResponse.success(transaction);
    } catch (e) {
      Logger.error('更新交易状态失败: $e');
      return ApiResponse.error(message: '更新交易状态失败');
    }
  }
}
