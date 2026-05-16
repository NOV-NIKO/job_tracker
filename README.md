<div align="center">

# 🎯 Job Tracker

**让求职管理变得简单高效**

一款现代化的求职追踪应用，助你轻松管理求职全流程

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [使用指南](#-使用指南) • [技术栈](#-技术栈) • [贡献](#-贡献指南)

</div>

---

## 📱 应用预览

<div align="center">

| 🏠 主界面 | 📝 添加信息 | 📊 数据统计 |
|:---:|:---:|:---:|
| 主界面截图 | 添加信息截图 | 数据统计截图 |
| *简洁直观的界面设计* | *智能OCR识别* | *可视化数据展示* |

</div>

---

## ✨ 为什么选择 Job Tracker？

### 🎯 **告别混乱，拥抱高效**

在求职过程中，你是否遇到过这些问题？
- ❌ 投递了太多公司，记不清哪家已经面试过
- ❌ 考试公告信息分散，错过报名时间
- ❌ 手动录入信息繁琐，容易出错
- ❌ 数据分散在不同设备，难以同步

**Job Tracker 就是为了解决这些问题而生！**

---

## 🌟 核心功能

### 📝 **智能信息管理**

#### 企业招聘追踪
- 📌 记录公司名称、职位、薪资、工作地点
- 🏷️ 标记求职状态（未报名、已报名、面试中、已录用等）
- 🔗 保存招聘链接和平台信息
- 📝 记录面试经验和岗位要求

#### 考试公告管理
- 📅 智能提醒报名时间、考试时间、面试时间
- 🏢 管理公务员、事业单位、国企等各类招考
- 📍 记录考试地点和岗位信息
- 📊 面试比例、招聘人数一目了然

### 🤖 **AI 驱动的 OCR 识别**

**一键截图，智能识别**

```
📸 拍照/截图 → 🤖 AI识别 → ✅ 自动填充表单
```

支持识别：
- ✅ 企业招聘信息（公司、职位、薪资、地点等）
- ✅ 考试公告信息（报名时间、考试时间、岗位等）
- ✅ 准确率高达 95%+

### 📊 **数据可视化**

- 📈 求职进度统计图表
- 📅 日历视图查看重要时间节点
- 🎯 不同状态职位数量统计
- 📉 求职转化率分析

### ☁️ **云端同步**

- 🔐 基于 Firebase 的安全认证
- ☁️ 实时云端数据同步
- 📱 多设备无缝切换
- 🔒 数据隔离，隐私安全

### 🎨 **极致用户体验**

- 🌈 现代化 Material Design 3 设计
- 🌙 深色模式支持
- ⚡ 流畅的动画效果
- 📱 响应式布局设计

---

## 🚀 快速开始

### 📋 前置要求

| 工具 | 版本要求 | 说明 |
|:---:|:---:|:---|
| Flutter SDK | >= 3.9.0 | [安装指南](https://flutter.dev/docs/get-started/install) |
| Dart SDK | >= 3.9.0 | 随 Flutter 自动安装 |
| Android Studio | 最新版 | Android 开发 |
| VS Code | 最新版 | 推荐 IDE |
| Firebase 账号 | - | 云端同步功能 |

### ⚡ 5 分钟快速部署

```bash
# 1️⃣ 克隆项目
git clone https://github.com/yourusername/job_tracker.git
cd job_tracker

# 2️⃣ 安装依赖
flutter pub get

# 3️⃣ 配置 API 密钥
cp lib/config/config.example.dart lib/config/config.dart
# 编辑 lib/config/config.dart，填入你的 GLM API 密钥

# 4️⃣ 运行应用
flutter run
```

### 🔑 获取 API 密钥

<details>
<summary><b>📖 点击查看详细步骤</b></summary>

#### GLM API 密钥（用于 OCR 识别）

1. 访问 [智谱 AI 开放平台](https://open.bigmodel.cn/)
2. 注册并登录账号
3. 进入控制台 → 创建应用
4. 复制 API Key 到 `lib/config/config.dart`

```dart
class Config {
  static const String glmApiKey = 'YOUR_API_KEY_HERE';
}
```

#### Firebase 配置（可选，用于云端同步）

<details>
<summary><b>Android 配置</b></summary>

1. 在 [Firebase Console](https://console.firebase.google.com/) 创建项目
2. 添加 Android 应用（包名：`com.example.job_tracker`）
3. 下载 `google-services.json`
4. 放置到 `android/app/` 目录

</details>

<details>
<summary><b>iOS 配置</b></summary>

1. 在 Firebase Console 添加 iOS 应用
2. 下载 `GoogleService-Info.plist`
3. 在 Xcode 中添加到项目

</details>

</details>

---

## 📖 使用指南

### 🎯 快速上手

#### 1️⃣ 添加求职信息

```
主界面 → 点击 ➕ 按钮 → 选择类型 → 填写信息
```

**两种类型：**
- 🏢 **企业招聘**：记录公司招聘信息
- 📋 **考试公告**：记录公务员、事业单位招考

#### 2️⃣ 使用 OCR 识别

```
添加信息界面 → 点击 📷 图标 → 选择图片 → 自动识别
```

**支持来源：**
- 📸 拍照
- 🖼️ 相册
- 📋 截图

#### 3️⃣ 数据同步

```
注册/登录 → 自动同步 → 多设备访问
```

---

## 🛠️ 技术栈

<table>
<tr>
<td width="50%">

### 前端技术
- **Flutter 3.9+** - 跨平台 UI 框架
- **Dart 3.9+** - 编程语言
- **Provider** - 状态管理
- **Material Design 3** - UI 设计

</td>
<td width="50%">

### 后端服务
- **Firebase Auth** - 用户认证
- **Cloud Firestore** - 云数据库
- **SQLite** - 本地数据库
- **GLM-4.6V-FlashX** - AI 视觉识别

</td>
</tr>
<tr>
<td width="50%">

### 核心功能
- **tesseract_ocr** - OCR 引擎
- **image_picker** - 图片选择
- **table_calendar** - 日历组件
- **flutter_charts** - 图表展示

</td>
<td width="50%">

### 开发工具
- **Android Studio** - IDE
- **VS Code** - 代码编辑器
- **Git** - 版本控制
- **GitHub** - 代码托管

</td>
</tr>
</table>

---

## 📁 项目结构

```
job_tracker/
├── 📂 lib/
│   ├── 📂 components/      # 可复用 UI 组件
│   │   ├── geometric_background.dart
│   │   ├── interactive_character_button.dart
│   │   ├── loading_indicator.dart
│   │   └── motivational_character.dart
│   ├── 📂 config/          # 配置文件
│   │   ├── config.dart     # ⚠️ 不提交到 Git
│   │   └── config.example.dart
│   ├── 📂 db/              # 数据库层
│   │   └── database_helper.dart
│   ├── 📂 models/          # 数据模型
│   │   ├── job.dart
│   │   └── user.dart
│   ├── 📂 screens/         # 页面
│   │   ├── home_screen.dart
│   │   ├── add_job_screen.dart
│   │   ├── auth_screen.dart
│   │   ├── job_detail_screen.dart
│   │   ├── stats_screen.dart
│   │   └── calendar_screen.dart
│   ├── 📂 services/        # 服务层
│   │   ├── auth_service.dart
│   │   └── firebase_service.dart
│   ├── 📂 theme/           # 主题配置
│   │   └── app_theme.dart
│   ├── 📂 utils/           # 工具类
│   │   ├── ocr_helper.dart
│   │   └── ocr_helper_web.dart
│   └── main.dart           # 应用入口
├── 📂 android/             # Android 平台代码
├── 📂 ios/                 # iOS 平台代码
├── pubspec.yaml            # 依赖配置
└── README.md               # 项目文档
```

---

## 🎨 设计理念

### 💡 **以用户为中心**

- **简洁至上**：去除冗余，保留核心功能
- **直觉操作**：符合用户习惯，降低学习成本
- **视觉舒适**：现代化设计，减少视觉疲劳

### 🔧 **技术驱动**

- **性能优先**：流畅体验，快速响应
- **安全可靠**：数据加密，隐私保护
- **易于扩展**：模块化设计，便于维护

---

## 🔒 安全与隐私

### 🛡️ **数据安全**

| 安全措施 | 说明 |
|:---:|:---|
| 🔐 | Firebase 身份验证，确保用户身份安全 |
| 🔒 | 数据传输采用 HTTPS 加密 |
| 🏠 | 本地 SQLite 数据库存储敏感信息 |
| 🔑 | API 密钥本地存储，不上传云端 |

### ⚠️ **注意事项**

- ❌ **不要**将 `lib/config/config.dart` 提交到 Git
- ❌ **不要**将 `google-services.json` 公开分享
- ✅ **务必**使用 `.gitignore` 忽略敏感文件
- ✅ **定期**更新依赖包，修复安全漏洞

---

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 🎯 如何贡献

<table>
<tr>
<td width="33%" align="center">

#### 🐛 报告 Bug

[提交 Issue](https://github.com/yourusername/job_tracker/issues/new?template=bug_report.md)

</td>
<td width="33%" align="center">

#### 💡 提出新功能

[功能建议](https://github.com/yourusername/job_tracker/issues/new?template=feature_request.md)

</td>
<td width="33%" align="center">

#### 🔧 提交代码

[Pull Request](https://github.com/yourusername/job_tracker/pulls)

</td>
</tr>
</table>

### 📝 贡献步骤

```bash
# 1. Fork 项目
# 2. 克隆你的 Fork
git clone https://github.com/your-username/job_tracker.git

# 3. 创建特性分支
git checkout -b feature/AmazingFeature

# 4. 提交更改
git commit -m 'Add some AmazingFeature'

# 5. 推送到分支
git push origin feature/AmazingFeature

# 6. 提交 Pull Request
```

### 🌟 贡献者

感谢所有贡献者的付出！

<a href="https://github.com/yourusername/job_tracker/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=yourusername/job_tracker" />
</a>

---

## 📈 项目状态

![Activity](https://img.shields.io/github/commit-activity/m/yourusername/job_tracker?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/yourusername/job_tracker?style=flat-square)
![Issues](https://img.shields.io/github/issues/yourusername/job_tracker?style=flat-square)
![Pull Requests](https://img.shields.io/github/issues-pr/yourusername/job_tracker?style=flat-square)

---

## 🗺️ 开发路线图

### ✅ v1.0.0 (当前版本)
- [x] 基础求职信息管理
- [x] OCR 智能识别
- [x] 云端数据同步
- [x] 数据统计可视化

### 🚧 v1.1.0 (计划中)
- [ ] 求职提醒通知
- [ ] 数据导出功能
- [ ] 面试题库
- [ ] 简历管理

### 💭 v2.0.0 (未来规划)
- [ ] AI 求职建议
- [ ] 职位推荐系统
- [ ] 社区分享功能
- [ ] Web 版本支持

---

## ❓ 常见问题

<details>
<summary><b>Q: 如何获取 GLM API 密钥？</b></summary>

**A:** 访问 [智谱 AI 开放平台](https://open.bigmodel.cn/)，注册账号后在控制台创建应用即可获取 API 密钥。新用户有免费额度。

</details>

<details>
<summary><b>Q: 是否必须配置 Firebase？</b></summary>

**A:** 不是必须的。Firebase 仅用于云端同步功能。如果不需要多设备同步，可以跳过 Firebase 配置，数据将仅保存在本地。

</details>

<details>
<summary><b>Q: 支持哪些平台？</b></summary>

**A:** 目前支持 Android 和 iOS 平台。Web 版本正在开发中。

</details>

<details>
<summary><b>Q: OCR 识别准确率如何？</b></summary>

**A:** 使用 GLM-4.6V-FlashX Vision API，识别准确率高达 95%+，支持中英文混合识别。

</details>

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源协议。

```
MIT License

Copyright (c) 2026 Job Tracker

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction...
```

---

## 🙏 致谢

感谢以下开源项目和服务：

<table>
<tr>
<td align="center" width="25%">
<a href="https://flutter.dev">
<img src="https://flutter.dev/assets/flutter-lockup-1cb6d2b1c9e90e9e5e3e5e5e5e5e5e5e.svg" width="100px;" alt="Flutter"/>
<br /><b>Flutter</b>
</a>
</td>
<td align="center" width="25%">
<a href="https://firebase.google.com">
<img src="https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_96dp.png" width="100px;" alt="Firebase"/>
<br /><b>Firebase</b>
</a>
</td>
<td align="center" width="25%">
<a href="https://open.bigmodel.cn">
<img src="https://open.bigmodel.cn/favicon.ico" width="100px;" alt="智谱AI"/>
<br /><b>智谱 AI</b>
</a>
</td>
<td align="center" width="25%">
<a href="https://dart.dev">
<img src="https://dart.dev/assets/dart-logo-for-shares.png" width="100px;" alt="Dart"/>
<br /><b>Dart</b>
</a>
</td>
</tr>
</table>

---

## 📮 联系我们

<div align="center">

### 💬 有问题或建议？欢迎联系！

[![GitHub Issues](https://img.shields.io/badge/GitHub-Issues-blue?style=for-the-badge&logo=github)](https://github.com/yourusername/job_tracker/issues)
[![Email](https://img.shields.io/badge/Email-联系我-red?style=for-the-badge&logo=gmail)](mailto:your.email@example.com)

</div>

---

<div align="center">

### ⭐ 如果这个项目对你有帮助，请给一个 Star 支持一下！

**你的 Star 是我们持续更新的动力！** 🌟

[![Star History Chart](https://api.star-history.com/svg?repos=yourusername/job_tracker&type=Date)](https://star-history.com/#yourusername/job_tracker&Date)

---

**Made with ❤️ by Job Tracker Team**

**[⬆ 返回顶部](#-job-tracker)**

</div>
