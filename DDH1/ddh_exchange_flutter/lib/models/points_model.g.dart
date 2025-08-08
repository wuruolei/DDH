// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PointsAccount _$PointsAccountFromJson(Map<String, dynamic> json) =>
    PointsAccount(
      id: json['id'] as String,
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toInt(),
      totalEarned: (json['totalEarned'] as num).toInt(),
      totalSpent: (json['totalSpent'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$PointsAccountToJson(PointsAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'balance': instance.balance,
      'totalEarned': instance.totalEarned,
      'totalSpent': instance.totalSpent,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };

PointsTransaction _$PointsTransactionFromJson(Map<String, dynamic> json) =>
    PointsTransaction(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      type: $enumDecode(_$PointsTransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toInt(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$PointsTransactionToJson(PointsTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'accountId': instance.accountId,
      'type': _$PointsTransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'referenceId': instance.referenceId,
    };

const _$PointsTransactionTypeEnumMap = {
  PointsTransactionType.earn: 'earn',
  PointsTransactionType.spend: 'spend',
  PointsTransactionType.refund: 'refund',
  PointsTransactionType.bonus: 'bonus',
};

CreditLevel _$CreditLevelFromJson(Map<String, dynamic> json) => CreditLevel(
      id: json['id'] as String,
      name: json['name'] as String,
      minPoints: (json['minPoints'] as num).toInt(),
      maxPoints: (json['maxPoints'] as num).toInt(),
      discountRate: (json['discountRate'] as num).toDouble(),
      benefits:
          (json['benefits'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$CreditLevelToJson(CreditLevel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'minPoints': instance.minPoints,
      'maxPoints': instance.maxPoints,
      'discountRate': instance.discountRate,
      'benefits': instance.benefits,
    };
