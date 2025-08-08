/// 用户数据模型
class User {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int points;
  final String userType;
  final DateTime? joinDate;
  final bool isVerified;
  final Map<String, dynamic>? wallet; // 钱包信息

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    required this.points,
    required this.userType,
    this.joinDate,
    this.isVerified = false,
    this.wallet,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      points: json['points'] ?? 0,
      userType: json['userType'] ?? 'normal',
      joinDate: json['joinDate'] != null 
          ? DateTime.parse(json['joinDate']) 
          : null,
      isVerified: json['isVerified'] ?? false,
      wallet: json['wallet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'points': points,
      'userType': userType,
      'joinDate': joinDate?.toIso8601String(),
      'isVerified': isVerified,
      'wallet': wallet,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? points,
    String? userType,
    DateTime? joinDate,
    bool? isVerified,
    Map<String, dynamic>? wallet,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      points: points ?? this.points,
      userType: userType ?? this.userType,
      joinDate: joinDate ?? this.joinDate,
      isVerified: isVerified ?? this.isVerified,
      wallet: wallet ?? this.wallet,
    );
  }
}
