# Lucia · 出行，不必慌张

原生 SwiftUI 旅行助手（iOS 18+），以及它的安装分发页。

**分发页：** https://wangwangbobo.github.io/lucia-travel/
**安装包：** https://github.com/wangwangbobo/lucia-travel/releases/tag/v1.0.0
**源码：** [ios/](ios/)

## 目录

```
index.html    分发页 + 22 个界面预览（单文件，无构建依赖）
shots/        模拟器实拍截图 + 应用图标
ios/          完整的 Xcode 工程（Lucia/、Lucia.xcodeproj、build-ipa.sh）
```

## 关于 GitHub Pages

GitHub Pages 只能托管静态文件，不能运行 iOS 原生应用。所以这里不是一个"能在网页里跑"的 App：

- 真正的应用是 `ios/` 里的 SwiftUI 工程，以及 Releases 里挂的 `.ipa`
- 网页负责下载入口、安装步骤和界面预览
- 想免安装直接体验，需要 TestFlight / App Store（需要付费开发者账号），或用 Appetize.io 之类把模拟器嵌进网页（需要 API key）

## 安装

1. Mac / Windows 装 [Sideloadly](https://sideloadly.io/)
2. 连上 iPhone，把 `.ipa` 拖进 Sideloadly，用免费 Apple ID 重新签名
3. 设置 → 通用 → VPN 与设备管理，信任证书

或者用 Xcode 打开 `ios/Lucia.xcodeproj`，选自己的 Team，⌘R。

## 本地查看

```bash
python3 -m http.server 8765
# 打开 http://localhost:8765/
```

## 说明

- 地图、社区、活动、餐厅热度、翻译结果为本地演示数据，不连接真实服务。
- 拍照翻译是本地模拟流程（预置菜单 / 路牌样本），不调用相机与 OCR。
- AI 助手回复为本地脚本化内容。
