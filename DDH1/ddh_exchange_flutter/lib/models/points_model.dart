import 'package:json_annotation/json_annotation.dart';

part 'points_model.g.dart';

/// 积分账户模型
@JsonSerializable()
class PointsAccount {
  final String id;
  final String userId;
  final int balance;
  final int totalEarned;
  final int totalSpent;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const PointsAccount({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.createdAt,
    required this.lastUpdated,
  });

  factory PointsAccount.fromJson(Map<String, dynamic> json) =>
      _$PointsAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PointsAccountToJson(this);
}

/// 积分交易记录模型
@JsonSerializable()
class PointsTransaction {
  final String id;
  final String accountId;
  final PointsTransactionType type;
  final int amount;
  final String description;
  final DateTime createdAt;
  final String? referenceId;

  const PointsTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
    this.referenceId,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) =>
      _$PointsTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$PointsTransactionToJson(this);
}

/// 积分交易类型枚举
enum PointsTransactionType {
  @JsonValue('earn')
  earn,
  @JsonValue('spend')
  spend,
  @JsonValue('refund')
  refund,
  @JsonValue('bonus')
  bonus,
}

/// 积分等级模型
@JsonSerializable()
class CreditLevel {
  final String id;
  final String name;
  final int minPoints;
  final int maxPoints;
  final double discountRate;
  final List<String> benefits;

  const CreditLevel({
    required this.id,
    required this.name,
    required this.minPoints,
    required this.maxPoints,
    required this.discountRate,
    required this.benefits,
  });

  factory CreditLevel.fromJson(Map<String, dynamic> json) =>
      _$CreditLevelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditLevelToJson(this);
}
