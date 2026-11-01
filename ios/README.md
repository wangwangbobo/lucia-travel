# RoamChina · iOS App 源码

这是 RoamChina 的原生 iOS 应用：SwiftUI，iOS 18+，无第三方依赖。
5 个 Tab（Trip / Plan / Community / Translate / Me）＋ 一个常驻的 Pico 助手。

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

产物是 `distribution/RoamChina-1.1.0-unsigned.ipa`，未签名。安装到 iPhone 需要
用 Sideloadly / AltStore 用自己的 Apple ID 重新签名（免费账号同样 7 天有效）。

## 目录

```
Lucia/
  LuciaApp.swift        入口
  RootView.swift        5 个 Tab 的容器 + 底部悬浮栏
  TripView.swift        Trip：地图、站点、聊天式行程
  PlanView.swift        Plan：日视图、编辑、相似路线
  ForumView.swift       Community：信息流
  ForumChannels.swift   社区频道：餐厅 / 景点 / 伴手礼 / 路线 / 活动
  TranslateView.swift   Translate：实时、拍照、离线
  MeView.swift          Me：档案、旅程报告、预订
  TripRecapView.swift   行程回顾（8 屏）
  ChecklistView.swift   出发清单
  AssistantView.swift   Pico 助手面板
  PicoService.swift     Pico 远端接口
  Store.swift           状态、规划、路线重算
  Models.swift          数据模型
  Components.swift      共用组件
  Theme.swift           颜色、字体、动效
  Extras.swift          笔记海报、浮层等补充界面
  Assets.xcassets       hero / 社区配图
  zh-Hans.lproj         中文字符串
Lucia.xcodeproj         工程文件，scheme Lucia，显示名 RoamChina
AppIcon.png             1024 应用图标，build-ipa.sh 会按尺寸注入
build-ipa.sh            真机构建 + 图标注入 + 打 IPA
```

## 功能

- **首次规划**：不问城市先问怎么玩。几天、什么节奏、想不想定主题，三题答完
  Pico 直接排出顺序、时间与步行量，落到行程页。
- **Trip**：地图上拖站点可以改顺序，松手后路线和时间重算；点「开始」进入
  进行中的行程状态。
- **Plan**：日视图、编辑行程、相似路线推荐。
- **Community**：信息流（含我们的北京这类专题）＋ 餐厅、景点、伴手礼、路线、
  活动五个频道，可发布活动、看笔记详情。
- **Translate**：实时对话翻译、拍菜单和路牌、离线包。
- **Me**：个人档案、旅程报告、景点预订。
- 另有行程回顾、出发清单、手账海报、调整站点等浮层与流程页。

## 数据说明

- 行程、地图点位、社区内容、活动、餐厅热度、预订、回顾均为本地演示数据，
  不连接真实服务。
- 拍照翻译为本地模拟演示：用预置的菜单 / 路牌样本走完整的扫描与识别流程，
  不调用相机和 OCR。
- 语音朗读使用系统 `AVSpeechSynthesizer`。
- Pico 对话是唯一联网能力，请求发往 `PicoService.swift` 里配置的接口，API Key
  只存在服务端，不打进 App。端点可以用 UserDefaults 的 `pico.endpoint` 覆盖；
  连不上时界面会提示稍后重试。
