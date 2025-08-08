// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BarterItem _$BarterItemFromJson(Map<String, dynamic> json) => BarterItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      value: (json['value'] as num).toDouble(),
      category: json['category'] as String,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BarterItemToJson(BarterItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'value': instance.value,
      'category': instance.category,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'tags': instance.tags,
    };

BarterTransaction _$BarterTransactionFromJson(Map<String, dynamic> json) =>
    BarterTransaction(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      status: $enumDecode(_$BarterTransactionStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$BarterTransactionToJson(BarterTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'buyerId': instance.buyerId,
      'sellerId': instance.sellerId,
      'status': _$BarterTransactionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$BarterTransactionStatusEnumMap = {
  BarterTransactionStatus.pending: 'pending',
  BarterTransactionStatus.accepted: 'accepted',
  BarterTransactionStatus.rejected: 'rejected',
  BarterTransactionStatus.completed: 'completed',
  BarterTransactionStatus.cancelled: 'cancelled',
};

BarterSearchCriteria _$BarterSearchCriteriaFromJson(
        Map<String, dynamic> json) =>
    BarterSearchCriteria(
      category: json['category'] as String?,
      minValue: (json['minValue'] as num?)?.toDouble(),
      maxValue: (json['maxValue'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      keyword: json['keyword'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$BarterSearchCriteriaToJson(
        BarterSearchCriteria instance) =>
    <String, dynamic>{
      'category': instance.category,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
      'tags': instance.tags,
      'keyword': instance.keyword,
      'isActive': instance.isActive,
    };
