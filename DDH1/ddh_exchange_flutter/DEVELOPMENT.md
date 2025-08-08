# 🛠️ 开发指南

## 📋 项目概述

点点换 (DDH Exchange) 是一个基于Flutter的跨平台易货交易应用，支持Web、iOS、Android和macOS平台。

## 🚀 快速开始

### 环境要求

- Flutter 3.32.8+
- Dart 3.5.0+
- Chrome浏览器 (Web开发)
- Xcode (iOS开发)
- Android Studio (Android开发)

### 本地开发

```bash
# 克隆项目
git clone [repository-url]
cd ddh_exchange_flutter

# 安装依赖
flutter pub get

# 启动Web版本 (推荐开发调试)
flutter run -d web-server --web-port 8110

# 访问应用
# http://localhost:8110
```

## 🏗️ 项目架构

### 目录结构

```
lib/
├── main.dart                    # 应用入口
├── models/                      # 数据模型层
│   ├── user.dart               # 用户数据模型
│   ├── advertisement.dart      # 广告数据模型
│   └── exchange_item.dart      # 兑换商品模型
├── services/                    # 业务服务层
│   ├── auth_service.dart       # 用户认证服务
│   ├── network_service.dart    # 网络请求服务
│   ├── storage_service.dart    # 本地存储服务
│   ├── advertisement_service.dart # 广告管理服务
│   └── logger.dart             # 日志服务
├── ui/                         # 用户界面层
│   ├── screens/                # 页面组件
│   │   └── business/           # 业务页面
│   │       └── main_tab_screen.dart # 主标签页
│   └── widgets/                # 可复用组件
│       └── banner_carousel.dart # 广告轮播组件
└── core/                       # 核心配置
    └── theme/                  # 主题配置
        └── app_theme.dart      # 应用主题
```

### 技术栈

- **UI框架**: Flutter + Material Design 3
- **状态管理**: StatefulWidget (计划升级到BLoC)
- **网络请求**: HTTP Client
- **本地存储**: SharedPreferences
- **字体系统**: Google Fonts (Poppins + Nunito)
- **路由管理**: Go Router
- **图标库**: Material Icons

## 🎨 设计系统

### 色彩方案

- **主色调**: 蓝紫色渐变 (#667eea → #764ba2)
- **辅助色**: 暖橙色渐变 (#FF6B6B → #FFE66D)
- **中性色**: 玻璃拟态白色系
- **强调色**: 橙色积分色 (#FF8E53)

### 字体系统

- **主字体**: Poppins (标题和重要文本)
- **辅助字体**: Nunito Sans (正文内容)
- **字体层级**: 12px - 32px，支持响应式

### 组件规范

- **圆角**: 8px, 12px, 16px, 20px, 24px
- **间距**: 4px, 8px, 12px, 16px, 20px, 24px
- **阴影**: 多层BoxShadow营造景深
- **动画**: 250ms-300ms缓动动画

## 🔧 开发工作流

### 代码规范

1. **文件命名**: 使用snake_case
2. **类命名**: 使用PascalCase
3. **变量命名**: 使用camelCase
4. **私有方法**: 使用下划线前缀 `_methodName`

### Git工作流

```bash
# 创建功能分支
git checkout -b feature/new-feature

# 提交代码
git add .
git commit -m "feat: 添加新功能"

# 推送分支
git push origin feature/new-feature

# 创建Pull Request
```

### 测试策略

1. **手动测试**: 在Web端验证功能
2. **自动化测试**: 使用Playwright MCP进行UI测试
3. **跨平台测试**: 在不同设备和浏览器测试

## 🚨 故障排除

### Flutter Web渲染问题

如果遇到页面无法正常显示的问题：

1. **清理缓存**: 
   ```bash
   flutter clean
   flutter pub get
   ```

2. **重启开发服务器**:
   ```bash
   flutter run -d web-server --web-port 8110
   ```

3. **激活渲染引擎**: 点击页面上的"Enable accessibility"按钮

### 常见编译错误

1. **依赖冲突**: 运行 `flutter pub deps` 检查依赖
2. **导入错误**: 检查文件路径和导入语句
3. **类型错误**: 确保变量类型声明正确

## 📈 性能优化

### Web端优化

1. **懒加载**: 大图片和组件使用懒加载
2. **缓存策略**: 合理使用Service Worker缓存
3. **代码分割**: 按页面分割代码包
4. **图片优化**: 使用WebP格式，适当压缩

### 移动端优化

1. **内存管理**: 及时释放不需要的资源
2. **网络优化**: 合并请求，使用缓存
3. **电池优化**: 减少后台任务和动画

## 🔮 未来规划

### 短期目标 (1-2周)

- [ ] 集成真实API接口
- [ ] 完善用户认证系统
- [ ] 添加单元测试和集成测试
- [ ] 优化移动端适配

### 中期目标 (1-2月)

- [ ] 升级到BLoC状态管理
- [ ] 添加国际化支持
- [ ] 实现离线功能
- [ ] 性能监控和分析

### 长期目标 (3-6月)

- [ ] 微服务架构后端
- [ ] 实时消息推送
- [ ] AI推荐算法
- [ ] 多平台原生优化

## 📞 支持与联系

- **技术支持**: [技术团队邮箱]
- **Bug报告**: [Issue链接]
- **功能建议**: [功能建议表单]

---

**最后更新**: 2025年8月7日
**版本**: v1.0.0
**维护者**: DDH开发团队
