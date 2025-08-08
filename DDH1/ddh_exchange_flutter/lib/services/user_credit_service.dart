import '../models/user_credit_model.dart';
import '../models/points_model.dart';
import '../models/api_response.dart';
import 'network_service.dart';
import 'logger.dart';

/// 用户信用服务类
class UserCreditService {
  final NetworkService _networkService;
  final Logger _logger;

  UserCreditService({
    NetworkService? networkService,
    Logger? logger,
  })  : _networkService = networkService ?? NetworkService(),
        _logger = logger ?? Logger();

  /// 获取用户信用信息
  Future<ApiResponse<UserCredit>> getUserCredit(String userId) async {
    try {
      Logger.info('获取用户信用信息: $userId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockCredit = UserCredit(
        id: 'credit_$userId',
        userId: userId,
        creditScore: 750,
        level: CreditLevel(
          id: 'level_2',
          name: '银牌',
          minPoints: 1000,
          maxPoints: 4999,
          discountRate: 0.05,
          benefits: ['基础功能', '5%折扣'],
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastUpdated: DateTime.now(),
        history: [
          CreditHistory(
            id: 'history_1',
            userId: userId,
            type: CreditChangeType.increase,
            changeAmount: 50,
            reason: '完成易货交易',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          CreditHistory(
            id: 'history_2',
            userId: userId,
            type: CreditChangeType.bonus,
            changeAmount: 20,
            reason: '新用户奖励',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
      );

      return ApiResponse.success(mockCredit);
    } catch (e) {
      Logger.error('获取用户信用信息失败: $e', e);
      return ApiResponse.error('获取用户信用信息失败');
    }
  }

  /// 获取用户钱包信息
  Future<ApiResponse<UserWallet>> getUserWallet(String userId) async {
    try {
      Logger.info('获取用户钱包信息: $userId');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockWallet = UserWallet(
        id: 'wallet_$userId',
        userId: userId,
        balance: 1250.50,
        currency: 'CNY',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        lastUpdated: DateTime.now(),
        transactions: [
          WalletTransaction(
            id: 'tx_1',
            walletId: 'wallet_$userId',
            type: WalletTransactionType.deposit,
            amount: 1000.0,
            description: '充值',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          WalletTransaction(
            id: 'tx_2',
            walletId: 'wallet_$userId',
            type: WalletTransactionType.transfer,
            amount: -200.0,
            description: '易货交易',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          WalletTransaction(
            id: 'tx_3',
            walletId: 'wallet_$userId',
            type: WalletTransactionType.bonus,
            amount: 50.0,
            description: '推荐奖励',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );

      return ApiResponse.success(mockWallet);
    } catch (e) {
      Logger.error('获取用户钱包信息失败: $e');
      return ApiResponse.error('获取用户钱包信息失败');
    }
  }

  /// 更新用户信用分数
  Future<ApiResponse<bool>> updateCreditScore(
    String userId,
    int changeAmount,
    String reason,
  ) async {
    try {
      Logger.info('更新用户信用分数: $userId, 变化: $changeAmount, 原因: $reason');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 600));
      
      return ApiResponse.success(true);
    } catch (e) {
      Logger.error('更新用户信用分数失败: $e');
      return ApiResponse.error('更新用户信用分数失败');
    }
  }

  /// 获取用户信用历史
  Future<ApiResponse<List<CreditHistory>>> getCreditHistory(
    String userId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('获取用户信用历史: $userId, 页码: $page');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockHistory = [
        CreditHistory(
          id: 'history_1',
          userId: userId,
          type: CreditChangeType.increase,
          changeAmount: 50,
          reason: '完成易货交易',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        CreditHistory(
          id: 'history_2',
          userId: userId,
          type: CreditChangeType.bonus,
          changeAmount: 20,
          reason: '新用户奖励',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        CreditHistory(
          id: 'history_3',
          userId: userId,
          type: CreditChangeType.increase,
          changeAmount: 30,
          reason: '好评奖励',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      return ApiResponse.success(mockHistory);
    } catch (e) {
      Logger.error('获取用户信用历史失败: $e');
      return ApiResponse.error('获取用户信用历史失败');
    }
  }

  /// 获取钱包交易记录
  Future<ApiResponse<List<WalletTransaction>>> getWalletTransactions(
    String walletId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Logger.info('获取钱包交易记录: $walletId, 页码: $page');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 400));
      
      final mockTransactions = [
        WalletTransaction(
          id: 'tx_1',
          walletId: walletId,
          type: WalletTransactionType.deposit,
          amount: 1000.0,
          description: '充值',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        WalletTransaction(
          id: 'tx_2',
          walletId: walletId,
          type: WalletTransactionType.transfer,
          amount: -200.0,
          description: '易货交易',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        WalletTransaction(
          id: 'tx_3',
          walletId: walletId,
          type: WalletTransactionType.bonus,
          amount: 50.0,
          description: '推荐奖励',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      return ApiResponse.success(mockTransactions);
    } catch (e) {
      Logger.error('获取钱包交易记录失败: $e');
      return ApiResponse.error('获取钱包交易记录失败');
    }
  }

  /// 充值钱包
  Future<ApiResponse<bool>> depositWallet(
    String walletId,
    double amount,
    String paymentMethod,
  ) async {
    try {
      Logger.info('充值钱包: $walletId, 金额: $amount, 支付方式: $paymentMethod');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 800));
      
      return ApiResponse.success(true);
    } catch (e) {
      Logger.error('充值钱包失败: $e');
      return ApiResponse.error('充值钱包失败');
    }
  }

  /// 提现钱包
  Future<ApiResponse<bool>> withdrawWallet(
    String walletId,
    double amount,
    String bankAccount,
  ) async {
    try {
      Logger.info('提现钱包: $walletId, 金额: $amount, 银行账户: $bankAccount');
      
      // 模拟API调用
      await Future.delayed(const Duration(milliseconds: 1000));
      
      return ApiResponse.success(true);
    } catch (e) {
      Logger.error('提现钱包失败: $e');
      return ApiResponse.error('提现钱包失败');
    }
  }
}
