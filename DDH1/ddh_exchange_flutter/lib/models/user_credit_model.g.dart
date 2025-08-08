// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_credit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCredit _$UserCreditFromJson(Map<String, dynamic> json) => UserCredit(
      id: json['id'] as String,
      userId: json['userId'] as String,
      creditScore: (json['creditScore'] as num).toInt(),
      level: CreditLevel.fromJson(json['level'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      history: (json['history'] as List<dynamic>)
          .map((e) => CreditHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserCreditToJson(UserCredit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'creditScore': instance.creditScore,
      'level': instance.level,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'history': instance.history,
    };

CreditHistory _$CreditHistoryFromJson(Map<String, dynamic> json) =>
    CreditHistory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$CreditChangeTypeEnumMap, json['type']),
      changeAmount: (json['changeAmount'] as num).toInt(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$CreditHistoryToJson(CreditHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$CreditChangeTypeEnumMap[instance.type]!,
      'changeAmount': instance.changeAmount,
      'reason': instance.reason,
      'createdAt': instance.createdAt.toIso8601String(),
      'referenceId': instance.referenceId,
    };

const _$CreditChangeTypeEnumMap = {
  CreditChangeType.increase: 'increase',
  CreditChangeType.decrease: 'decrease',
  CreditChangeType.bonus: 'bonus',
  CreditChangeType.penalty: 'penalty',
};

UserWallet _$UserWalletFromJson(Map<String, dynamic> json) => UserWallet(
      id: json['id'] as String,
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserWalletToJson(UserWallet instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'balance': instance.balance,
      'currency': instance.currency,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'transactions': instance.transactions,
    };

WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    WalletTransaction(
      id: json['id'] as String,
      walletId: json['walletId'] as String,
      type: $enumDecode(_$WalletTransactionTypeEnumMap, json['type']),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      referenceId: json['referenceId'] as String?,
    );

Map<String, dynamic> _$WalletTransactionToJson(WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletId': instance.walletId,
      'type': _$WalletTransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'referenceId': instance.referenceId,
    };

const _$WalletTransactionTypeEnumMap = {
  WalletTransactionType.deposit: 'deposit',
  WalletTransactionType.withdrawal: 'withdrawal',
  WalletTransactionType.transfer: 'transfer',
  WalletTransactionType.refund: 'refund',
  WalletTransactionType.bonus: 'bonus',
};
