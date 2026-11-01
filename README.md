# RoamChina · 出行，不必慌张

原生 SwiftUI 旅行助手（iOS 18+），以及它的安装分发页。

**分发页：** https://wangwangbobo.github.io/lucia-travel/
**安装包：** https://github.com/wangwangbobo/lucia-travel/releases/tag/v1.1.0
**网页版试玩：** https://wangwangbobo.github.io/ios-app-demo/
**源码：** [ios/](ios/)

## 目录

```
index.html    分发页 + 26 个界面预览（单文件，无构建依赖）
shots/        界面截图 + 应用图标
ios/          完整的 Xcode 工程（Lucia/、Lucia.xcodeproj、build-ipa.sh）
```

## 关于 GitHub Pages

GitHub Pages 只能托管静态文件，不能运行 iOS 原生应用。所以这里不是一个“能在网页里跑”的 App：

- 真正的应用是 `ios/` 里的 SwiftUI 工程，以及 Releases 里挂的 `.ipa`
- 网页负责下载入口、安装步骤和界面预览
- 想免安装直接点着玩，可以打开网页版：https://wangwangbobo.github.io/ios-app-demo/

## 这一版有什么

- 首次进入：Pico 用三个问题（几天 / 怎么玩 / 什么主题）生成第一份北京计划
- 行程：Pico 规划摘要、逐日路线、日期可平移，行中模式可看下一站并导航
- 计划：6 站中轴线地图，可拖动站点、调整顺序、套用相似路线
- 社区：信息流 + 美食 / 景点 / 伴手礼 / 城市漫步 / 本地活动频道，可发布活动
- 翻译：实时对话、离线应急语句、拍照翻译（菜单与路牌）
- 我的：旅行档案、景点预约与凭证、旅程总结海报
- 全局：Pico 悬浮助手，中英界面切换

## 安装

1. Mac / Windows 装 [Sideloadly](https://sideloadly.io/)
2. 连上 iPhone，把 `.ipa` 拖进 Sideloadly，用免费 Apple ID 重新签名
3. 设置 → 通用 → VPN 与设备管理，信任证书

免费账号签名 7 天有效，到期重签一次；付费开发者账号可以签一年。
