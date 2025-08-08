import 'package:json_annotation/json_annotation.dart';

part 'barter_model.g.dart';

/// 易货项目模型
@JsonSerializable()
class BarterItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double value;
  final String category;
  final String ownerId;
  final DateTime createdAt;
  final bool isActive;
  final List<String> tags;

  const BarterItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.value,
    required this.category,
    required this.ownerId,
    required this.createdAt,
    required this.isActive,
    required this.tags,
  });

  factory BarterItem.fromJson(Map<String, dynamic> json) =>
      _$BarterItemFromJson(json);

  Map<String, dynamic> toJson() => _$BarterItemToJson(this);
}

/// 易货交易模型
@JsonSerializable()
class BarterTransaction {
  final String id;
  final String itemId;
  final String buyerId;
  final String sellerId;
  final BarterTransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;

  const BarterTransaction({
    required this.id,
    required this.itemId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  factory BarterTransaction.fromJson(Map<String, dynamic> json) =>
      _$BarterTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$BarterTransactionToJson(this);
}

/// 易货交易状态枚举
enum BarterTransactionStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

/// 易货搜索条件模型
@JsonSerializable()
class BarterSearchCriteria {
  final String? category;
  final double? minValue;
  final double? maxValue;
  final List<String>? tags;
  final String? keyword;
  final bool? isActive;

  const BarterSearchCriteria({
    this.category,
    this.minValue,
    this.maxValue,
    this.tags,
    this.keyword,
    this.isActive,
  });

  factory BarterSearchCriteria.fromJson(Map<String, dynamic> json) =>
      _$BarterSearchCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$BarterSearchCriteriaToJson(this);
}
