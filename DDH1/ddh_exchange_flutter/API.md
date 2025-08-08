# 🔌 API接口文档

## 📋 概述

点点换 (DDH Exchange) 后端API接口文档，定义了前端Flutter应用与后端服务的通信协议。

## 🌐 基础信息

- **Base URL**: `https://api.ddhexchange.com/v1`
- **Content-Type**: `application/json`
- **认证方式**: Bearer Token
- **API版本**: v1.0

## 🔐 认证接口

### 用户注册

```http
POST /auth/register
```

**请求参数**:
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "phone": "string",
  "verification_code": "string"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345",
    "username": "testuser",
    "email": "test@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_here",
    "expires_in": 3600
  },
  "message": "注册成功"
}
```

### 用户登录

```http
POST /auth/login
```

**请求参数**:
```json
{
  "email": "string",
  "password": "string"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345",
    "username": "testuser",
    "email": "test@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "refresh_token_here",
    "expires_in": 3600,
    "user_type": "premium",
    "points": 1250
  },
  "message": "登录成功"
}
```

### 刷新Token

```http
POST /auth/refresh
```

**请求头**:
```
Authorization: Bearer {refresh_token}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "token": "new_access_token",
    "expires_in": 3600
  }
}
```

## 👤 用户接口

### 获取用户信息

```http
GET /user/profile
```

**请求头**:
```
Authorization: Bearer {access_token}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345",
    "username": "点点用户",
    "email": "user@example.com",
    "phone": "138****8888",
    "avatar": "https://cdn.ddhexchange.com/avatars/12345.jpg",
    "user_type": "vip",
    "points": 1250,
    "level": 5,
    "created_at": "2024-01-01T00:00:00Z",
    "last_login": "2025-08-07T10:58:45Z"
  }
}
```

### 更新用户信息

```http
PUT /user/profile
```

**请求参数**:
```json
{
  "username": "string",
  "phone": "string",
  "avatar": "string"
}
```

## 🎯 广告接口

### 获取横幅广告

```http
GET /advertisements/banners
```

**查询参数**:
- `position`: 广告位置 (home, exchange, profile)
- `limit`: 返回数量限制 (默认10)

**响应示例**:
```json
{
  "success": true,
  "data": [
    {
      "id": "ad001",
      "title": "新用户福利",
      "subtitle": "注册送500积分，立即开始兑换之旅",
      "image_url": "https://cdn.ddhexchange.com/ads/welcome.jpg",
      "action_type": "navigate",
      "action_url": "/exchange",
      "priority": 1,
      "start_time": "2025-08-01T00:00:00Z",
      "end_time": "2025-08-31T23:59:59Z",
      "is_active": true
    }
  ],
  "total": 3,
  "message": "获取成功"
}
```

### 广告点击统计

```http
POST /advertisements/{ad_id}/click
```

**请求参数**:
```json
{
  "user_id": "12345",
  "click_time": "2025-08-07T10:58:45Z",
  "source": "home_banner"
}
```

## 🛒 商品接口

### 获取商品列表

```http
GET /products
```

**查询参数**:
- `category`: 商品分类 (数码产品, 生活用品, 美妆护肤, 运动健身)
- `sort`: 排序方式 (price_asc, price_desc, popular, latest)
- `page`: 页码 (默认1)
- `limit`: 每页数量 (默认20)

**响应示例**:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "prod001",
        "name": "iPhone 15 Pro",
        "description": "苹果最新旗舰手机，性能卓越",
        "image_url": "https://cdn.ddhexchange.com/products/iphone15.jpg",
        "category": "数码产品",
        "points_required": 15000,
        "stock": 10,
        "is_available": true,
        "created_at": "2025-08-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "per_page": 20
    }
  }
}
```

### 获取商品详情

```http
GET /products/{product_id}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": "prod001",
    "name": "iPhone 15 Pro",
    "description": "苹果最新旗舰手机，性能卓越，拍照效果出色",
    "images": [
      "https://cdn.ddhexchange.com/products/iphone15_1.jpg",
      "https://cdn.ddhexchange.com/products/iphone15_2.jpg"
    ],
    "category": "数码产品",
    "points_required": 15000,
    "stock": 10,
    "is_available": true,
    "specifications": {
      "brand": "Apple",
      "model": "iPhone 15 Pro",
      "color": "深空黑色",
      "storage": "256GB"
    },
    "created_at": "2025-08-01T00:00:00Z"
  }
}
```

## 💰 积分接口

### 获取积分余额

```http
GET /points/balance
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user_id": "12345",
    "current_points": 1250,
    "total_earned": 5000,
    "total_spent": 3750,
    "level": 5,
    "next_level_points": 2000
  }
}
```

### 获取积分记录

```http
GET /points/history
```

**查询参数**:
- `type`: 记录类型 (earn, spend, all)
- `page`: 页码
- `limit`: 每页数量

**响应示例**:
```json
{
  "success": true,
  "data": {
    "records": [
      {
        "id": "point001",
        "type": "earn",
        "amount": 100,
        "description": "每日签到奖励",
        "created_at": "2025-08-07T10:00:00Z"
      },
      {
        "id": "point002",
        "type": "spend",
        "amount": -500,
        "description": "兑换商品：蓝牙耳机",
        "related_order_id": "order001",
        "created_at": "2025-08-06T15:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 200
    }
  }
}
```

## 🔄 兑换接口

### 创建兑换订单

```http
POST /exchange/orders
```

**请求参数**:
```json
{
  "product_id": "prod001",
  "quantity": 1,
  "delivery_address": {
    "name": "张三",
    "phone": "138****8888",
    "address": "北京市朝阳区xxx街道xxx号",
    "postal_code": "100000"
  }
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "order_id": "order001",
    "product_id": "prod001",
    "product_name": "iPhone 15 Pro",
    "quantity": 1,
    "points_cost": 15000,
    "status": "pending",
    "delivery_address": {
      "name": "张三",
      "phone": "138****8888",
      "address": "北京市朝阳区xxx街道xxx号",
      "postal_code": "100000"
    },
    "created_at": "2025-08-07T10:58:45Z",
    "estimated_delivery": "2025-08-14T00:00:00Z"
  },
  "message": "兑换订单创建成功"
}
```

### 获取兑换记录

```http
GET /exchange/orders
```

**查询参数**:
- `status`: 订单状态 (pending, processing, shipped, delivered, cancelled)
- `page`: 页码
- `limit`: 每页数量

**响应示例**:
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "order_id": "order001",
        "product_name": "iPhone 15 Pro",
        "product_image": "https://cdn.ddhexchange.com/products/iphone15.jpg",
        "quantity": 1,
        "points_cost": 15000,
        "status": "shipped",
        "tracking_number": "SF1234567890",
        "created_at": "2025-08-07T10:58:45Z",
        "updated_at": "2025-08-08T14:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 25
    }
  }
}
```

## 📊 统计接口

### 获取用户统计

```http
GET /stats/user
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "total_points_earned": 5000,
    "total_points_spent": 3750,
    "total_orders": 25,
    "successful_exchanges": 23,
    "user_level": 5,
    "days_active": 180,
    "favorite_category": "数码产品"
  }
}
```

## 🔔 通知接口

### 获取通知列表

```http
GET /notifications
```

**查询参数**:
- `type`: 通知类型 (system, order, points, promotion)
- `is_read`: 是否已读 (true, false)
- `page`: 页码
- `limit`: 每页数量

**响应示例**:
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notif001",
        "type": "order",
        "title": "订单发货通知",
        "content": "您的订单 order001 已发货，预计3-5天到达",
        "is_read": false,
        "created_at": "2025-08-07T10:58:45Z"
      }
    ],
    "unread_count": 5,
    "pagination": {
      "current_page": 1,
      "total_pages": 2,
      "total_items": 30
    }
  }
}
```

### 标记通知已读

```http
PUT /notifications/{notification_id}/read
```

## 🔍 搜索接口

### 搜索商品

```http
GET /search/products
```

**查询参数**:
- `q`: 搜索关键词
- `category`: 商品分类
- `min_points`: 最低积分
- `max_points`: 最高积分
- `sort`: 排序方式
- `page`: 页码
- `limit`: 每页数量

**响应示例**:
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "prod001",
        "name": "iPhone 15 Pro",
        "description": "苹果最新旗舰手机",
        "image_url": "https://cdn.ddhexchange.com/products/iphone15.jpg",
        "points_required": 15000,
        "highlight": "iPhone 15 Pro"
      }
    ],
    "total_results": 15,
    "search_time": 0.05,
    "suggestions": ["iPhone", "苹果手机", "智能手机"]
  }
}
```

## 📝 反馈接口

### 提交用户反馈

```http
POST /feedback
```

**请求参数**:
```json
{
  "type": "bug_report",
  "title": "应用崩溃问题",
  "content": "在兑换页面点击商品时应用崩溃",
  "contact_info": "user@example.com",
  "device_info": {
    "platform": "web",
    "browser": "Chrome 118",
    "screen_resolution": "1920x1080"
  }
}
```

## ⚠️ 错误码说明

| 错误码 | 说明 | 处理建议 |
|--------|------|----------|
| 400 | 请求参数错误 | 检查请求参数格式和必填字段 |
| 401 | 未授权访问 | 检查Token是否有效 |
| 403 | 权限不足 | 检查用户权限 |
| 404 | 资源不存在 | 检查请求路径和资源ID |
| 429 | 请求频率过高 | 实施请求限流 |
| 500 | 服务器内部错误 | 联系技术支持 |

## 🔧 SDK集成示例

### Dart/Flutter集成

```dart
// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'https://api.ddhexchange.com/v1';
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(data),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(data['message'] ?? 'Unknown error', response.statusCode);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
```

---

**最后更新**: 2025年8月7日
**版本**: v1.0
**维护者**: DDH开发团队
