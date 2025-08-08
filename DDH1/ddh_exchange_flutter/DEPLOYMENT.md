# 🚀 部署指南

## 📋 概述

本文档详细说明了点点换 (DDH Exchange) Flutter应用在不同平台的部署流程和最佳实践。

## 🌐 Web部署

### 构建Web版本

```bash
# 构建生产版本
flutter build web --release

# 构建输出目录
# build/web/
```

### 部署到静态托管服务

#### 1. Netlify部署

```bash
# 安装Netlify CLI
npm install -g netlify-cli

# 部署到Netlify
netlify deploy --dir=build/web --prod
```

#### 2. Vercel部署

```bash
# 安装Vercel CLI
npm install -g vercel

# 部署到Vercel
vercel --prod
```

#### 3. Firebase Hosting

```bash
# 安装Firebase CLI
npm install -g firebase-tools

# 初始化Firebase项目
firebase init hosting

# 部署到Firebase
firebase deploy
```

### Web配置优化

#### `web/index.html` 优化

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="点点换 - 智能易货交易平台">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="点点换">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>点点换 - 智能易货交易平台</title>
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <script>
    window.addEventListener('load', function(ev) {
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: serviceWorkerVersion,
        }
      }).then(function(engineInitializer) {
        return engineInitializer.initializeEngine();
      }).then(function(appRunner) {
        return appRunner.runApp();
      });
    });
  </script>
</body>
</html>
```

## 📱 移动端部署

### iOS部署

#### 前置条件

```bash
# 安装CocoaPods
sudo gem install cocoapods

# 安装iOS依赖
cd ios && pod install
```

#### App Store部署

1. **配置签名**
   ```bash
   # 在Xcode中配置开发者账号和证书
   open ios/Runner.xcworkspace
   ```

2. **构建发布版本**
   ```bash
   flutter build ios --release
   ```

3. **上传到App Store Connect**
   ```bash
   # 使用Xcode Archive功能
   # Product -> Archive -> Upload to App Store
   ```

#### TestFlight测试部署

```bash
# 构建测试版本
flutter build ios --release --flavor staging

# 上传到TestFlight
# 通过Xcode Organizer上传
```

### Android部署

#### 前置条件

```bash
# 生成签名密钥
keytool -genkey -v -keystore ~/ddh-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias ddh

# 配置gradle签名
# android/app/build.gradle
```

#### Google Play部署

1. **配置签名**
   ```gradle
   // android/app/build.gradle
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

2. **构建发布版本**
   ```bash
   flutter build appbundle --release
   ```

3. **上传到Google Play Console**
   ```bash
   # 上传build/app/outputs/bundle/release/app-release.aab
   ```

## 🖥️ 桌面端部署

### macOS部署

```bash
# 构建macOS版本
flutter build macos --release

# 创建DMG安装包
# 使用create-dmg工具
npm install -g create-dmg
create-dmg build/macos/Build/Products/Release/DDH\ Exchange.app
```

### Windows部署

```bash
# 构建Windows版本
flutter build windows --release

# 创建安装包
# 使用Inno Setup或NSIS
```

### Linux部署

```bash
# 构建Linux版本
flutter build linux --release

# 创建AppImage
# 使用linuxdeploy工具
```

## 🔧 CI/CD配置

### GitHub Actions

创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy DDH Exchange

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      - run: flutter pub get
      - run: flutter test
      - run: flutter analyze

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v1.2
        with:
          publish-dir: './build/web'
          production-branch: main
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}

  deploy-ios:
    needs: test
    runs-on: macos-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      - run: flutter pub get
      - run: cd ios && pod install
      - run: flutter build ios --release --no-codesign
      # 添加代码签名和上传步骤

  deploy-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v2
        with:
          distribution: 'zulu'
          java-version: '11'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      - run: flutter pub get
      - run: flutter build appbundle --release
      # 添加Google Play上传步骤
```

## 🔒 安全配置

### API密钥管理

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.ddhexchange.com',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );
}
```

### 环境变量配置

```bash
# .env.production
API_BASE_URL=https://api.ddhexchange.com
API_KEY=your_production_api_key

# .env.staging
API_BASE_URL=https://staging-api.ddhexchange.com
API_KEY=your_staging_api_key
```

## 📊 监控和分析

### Firebase Analytics

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, Object> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
```

### Crashlytics集成

```dart
// lib/main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(MyApp());
}
```

## 🚀 性能优化

### Web性能优化

1. **代码分割**
   ```bash
   flutter build web --split-debug-info=build/web/debug_info
   ```

2. **Tree Shaking**
   ```bash
   flutter build web --tree-shake-icons
   ```

3. **压缩优化**
   ```bash
   flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true
   ```

### 移动端性能优化

1. **混淆配置**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/debug_info
   ```

2. **资源优化**
   ```yaml
   # pubspec.yaml
   flutter:
     assets:
       - assets/images/
     fonts:
       - family: Poppins
         fonts:
           - asset: fonts/Poppins-Regular.ttf
   ```

## 📋 部署检查清单

### 部署前检查

- [ ] 所有测试通过
- [ ] 代码审查完成
- [ ] 性能测试通过
- [ ] 安全扫描通过
- [ ] 文档更新完成

### Web部署检查

- [ ] 构建成功无错误
- [ ] 静态资源正确加载
- [ ] 路由配置正确
- [ ] SEO标签完整
- [ ] PWA配置正确

### 移动端部署检查

- [ ] 签名配置正确
- [ ] 权限配置完整
- [ ] 图标和启动页正确
- [ ] 应用商店信息完整
- [ ] 版本号更新

## 🆘 故障排除

### 常见部署问题

1. **Web部署404错误**
   - 检查base href配置
   - 确认路由配置正确

2. **iOS构建失败**
   - 更新CocoaPods
   - 清理Xcode缓存

3. **Android签名问题**
   - 检查keystore文件路径
   - 确认签名配置正确

### 回滚策略

```bash
# Web回滚
netlify rollback

# 移动端回滚
# 通过应用商店管理后台回滚版本
```

---

**最后更新**: 2025年8月7日
**版本**: v1.0.0
**维护者**: DDH开发团队
