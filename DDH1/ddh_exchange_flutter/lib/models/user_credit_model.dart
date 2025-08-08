import 'package:json_annotation/json_annotation.dart';
import 'points_model.dart';

part 'user_credit_model.g.dart';

/// 用户信用模型
@JsonSerializable()
class UserCredit {
  final String id;
  final String userId;
  final int creditScore;
  final CreditLevel level;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<CreditHistory> history;

  const UserCredit({
    required this.id,
    required this.userId,
    required this.creditScore,
    required this.level,
    required this.createdAt,
    required this.lastUpdated,
    required this.history,
  });

  factory UserCredit.fromJson(Map<String, dynamic> json) =>
      _$UserCreditFromJson(json);

  Map<String, dynamic> toJson() => _$UserCreditToJson(this);
}

/// 信用历史记录模型
@JsonSerializable()
class CreditHistory {
  final String id;
  final String userId;
  final CreditChangeType type;
  final int changeAmount;
  final String reason;
  final DateTime createdAt;
  final String? referenceId;

  const CreditHistory({
    required this.id,
    required this.userId,
    required this.type,
    required this.changeAmount,
    required this.reason,
    required this.createdAt,
    this.referenceId,
  });

  factory CreditHistory.fromJson(Map<String, dynamic> json) =>
      _$CreditHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$CreditHistoryToJson(this);
}

/// 信用变化类型枚举
enum CreditChangeType {
  @JsonValue('increase')
  increase,
  @JsonValue('decrease')
  decrease,
  @JsonValue('bonus')
  bonus,
  @JsonValue('penalty')
  penalty,
}

/// 用户钱包模型
@JsonSerializable()
class UserWallet {
  final String id;
  final String userId;
  final double balance;
  final String currency;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final List<WalletTransaction> transactions;

  const UserWallet({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.createdAt,
    required this.lastUpdated,
    required this.transactions,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) =>
      _$UserWalletFromJson(json);

  Map<String, dynamic> toJson() => _$UserWalletToJson(this);
}

/// 钱包交易记录模型
@JsonSerializable()
class WalletTransaction {
  final String id;
  final String walletId;
  final WalletTransactionType type;
  final double amount;
  final String description;
  final DateTime createdAt;
  final String? referenceId;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.referenceId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$WalletTransactionToJson(this);
}

/// 钱包交易类型枚举
enum WalletTransactionType {
  @JsonValue('deposit')
  deposit,
  @JsonValue('withdrawal')
  withdrawal,
  @JsonValue('transfer')
  transfer,
  @JsonValue('refund')
  refund,
  @JsonValue('bonus')
  bonus,
}
