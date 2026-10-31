# Lucia · iOS App 源码

这是 Lucia 的原生 iOS 应用：SwiftUI，iOS 18+，无第三方依赖。

## 用 Xcode 跑起来

```bash
open Lucia.xcodeproj
```

选择 `Lucia` scheme 和一个 iPhone 模拟器，⌘R 运行。

要装到真机：在 Xcode → Settings → Accounts 登录自己的 Apple ID，然后在
Signing & Capabilities 里把 Team 改成自己的账号（免费账号即可，签名 7 天有效）。

## 打包 IPA

```bash
./build-ipa.sh
```

产物是 `distribution/Lucia-1.0.0-unsigned.ipa`，未签名。安装到 iPhone 需要
用 Sideloadly / AltStore 用自己的 Apple ID 重新签名（免费账号同样 7 天有效）。

## 目录

```
Lucia/                  SwiftUI 源码（5 个 Tab、计划编辑、社区频道、拍照翻译）
Lucia.xcodeproj         工程文件，scheme Lucia
AppIcon.png             1024 应用图标，build-ipa.sh 会按尺寸注入
build-ipa.sh            真机构建 + 图标注入 + 打 IPA
```

## 说明

- 地图点位、社区内容、活动、餐厅热度、翻译结果为本地演示数据，不连接真实服务。
- 拍照翻译为本地模拟演示：用预置的菜单 / 路牌样本走完整扫描与识别流程，不调用相机和 OCR。
- AI 助手回复为本地脚本化内容。
