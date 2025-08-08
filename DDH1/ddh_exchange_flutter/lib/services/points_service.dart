import '../models/points_model.dart';
import '../models/api_response.dart';
import 'network_service.dart';
import 'logger.dart';

/// 积分服务类
class PointsService {
  final NetworkService _networkService;
  final Logger _logger;

  PointsService({
    NetworkService? networkService,
    Logger? logger,
  })  : _networkService = networkService ?? NetworkService(),
        _logger = logger ?? Logger();

  /// 获取用户积分账户
  Future<ApiResponse<PointsAccount>> getPointsAccount(String userId) async {
    try {
      Logger.info('获取用户积分账户: $userId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockAccount = PointsAccount(
        id: 'account_$userId',
        userId: userId,
        balance: 1000,
        totalEarned: 2000,
        totalSpent: 1000,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastUpdated: DateTime.now(),
      );

      return ApiResponse.success(mockAccount);
    } catch (e) {
      Logger.error('获取积分账户失败: $e', e);
      return ApiResponse.error('获取积分账户失败');
    }
  }

  /// 获取积分交易记录
  Future<ApiResponse<List<PointsTransaction>>> getPointsTransactions(
    String accountId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('获取积分交易记录: $accountId, 页码: $page');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockTransactions = [
        PointsTransaction(
          id: 'tx_1',
          accountId: accountId,
          type: PointsTransactionType.earn,
          amount: 100,
          description: '完成易货交易',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PointsTransaction(
          id: 'tx_2',
          accountId: accountId,
          type: PointsTransactionType.spend,
          amount: -50,
          description: '兑换商品',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];

      return ApiResponse.success(mockTransactions);
    } catch (e) {
      Logger.error('获取积分交易记录失败: $e', e);
      return ApiResponse.error('获取积分交易记录失败');
    }
  }

  /// 添加积分
  Future<ApiResponse<bool>> addPoints(
    String accountId,
    int amount,
    String reason,
  ) async {
    try {
      Logger.info('添加积分: $accountId, 数量: $amount, 原因: $reason');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      return ApiResponse.success(true);
    } catch (e) {
      Logger.error('添加积分失败: $e', e);
      return ApiResponse.error('添加积分失败');
    }
  }

  /// 消费积分
  Future<ApiResponse<bool>> spendPoints(
    String accountId,
    int amount,
    String reason,
  ) async {
    try {
      Logger.info('消费积分: $accountId, 数量: $amount, 原因: $reason');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      return ApiResponse.success(true);
    } catch (e) {
      Logger.error('消费积分失败: $e', e);
      return ApiResponse.error('消费积分失败');
    }
  }

  /// 获取积分等级
  Future<ApiResponse<List<CreditLevel>>> getCreditLevels() async {
    try {
      Logger.info('获取积分等级列表');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 300));
      
      final mockLevels = [
        CreditLevel(
          id: 'level_1',
          name: '新手',
          minPoints: 0,
          maxPoints: 999,
          discountRate: 0.0,
          benefits: ['基础功能'],
        ),
        CreditLevel(
          id: 'level_2',
          name: '银牌',
          minPoints: 1000,
          maxPoints: 4999,
          discountRate: 0.05,
          benefits: ['基础功能', '5%折扣'],
        ),
        CreditLevel(
          id: 'level_3',
          name: '金牌',
          minPoints: 5000,
          maxPoints: 9999,
          discountRate: 0.10,
          benefits: ['基础功能', '10%折扣', '优先客服'],
        ),
      ];

      return ApiResponse.success(mockLevels);
    } catch (e) {
      Logger.error('获取积分等级失败: $e', e);
      return ApiResponse.error('获取积分等级失败');
    }
  }
}
