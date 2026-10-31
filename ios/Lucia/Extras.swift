import SwiftUI
import UIKit

// MARK: - Visual notes

struct NotesPoster: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false

    private var cleanName: String {
        model.routeName.replacingOccurrences(of: " · 草稿", with: "")
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                topBar
                poster
                ShareLink(item: model.routeSummary) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 11, weight: .bold))
                        Text("分享这篇笔记")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                    .compositingGroup()
                    .shadow(color: Palette.ink.opacity(0.15), radius: 0, x: 0, y: 3)
                }

                Button {
                    UIPasteboard.general.string = model.routeSummary
                    withAnimation { copied = true }
                    Haptics.success()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 10, weight: .semibold))
                        Text(copied ? "文案已复制" : "复制文案")
                            .font(.system(size: 11.5, weight: .medium))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 43)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())

                Text("笔记会包含路线顺序、时间与距离，适合发到社交平台。")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Palette.ink3)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
            Text("可视化笔记")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(Palette.ink)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 33, height: 33)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private var poster: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Eyebrow(text: "LUCIA · CITYWALK")
                Spacer()
                StickerLabel(text: "NO. 014", fill: Palette.mustard, rotation: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(cleanName)
                    .font(.system(size: 30, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                Text("2026.10.15 · 北京 · 与林、周同行")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            MiniRouteMap(points: model.stops.map { CGPoint(x: $0.x, y: $0.y) })
                .frame(height: 178)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .strokeBorder(Palette.ink, lineWidth: 1.2)
                )

            VStack(spacing: 7) {
                ForEach(model.stops.indices, id: \.self) { index in
                    HStack(spacing: 8) {
                        Text("\(index + 1)")
                            .font(.system(size: 8, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 17, height: 17)
                            .background(
                                Circle().fill([Palette.mustard, Palette.pink, Palette.mint, Palette.periwinkle][index % 4])
                            )
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.9))
                        Text(model.stops[index].name)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text(model.stops[index].time)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                        Text(model.stops[index].duration)
                            .font(.system(size: 9))
                            .foregroundStyle(Palette.ink3)
                            .frame(width: 54, alignment: .trailing)
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.paperWarm.opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.ink.opacity(0.25), lineWidth: 1))

            HStack(spacing: 10) {
                Label("6 站", systemImage: "mappin.and.ellipse")
                Label("4.2 km", systemImage: "figure.walk")
                Label("约 5 小时", systemImage: "clock")
                Spacer()
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(Palette.accent)
                    .font(.system(size: 12))
            }
            .font(.system(size: 9))
            .foregroundStyle(Palette.ink3)

            Rectangle()
                .fill(Palette.line)
                .frame(height: 0.8)

            HStack {
                Text("慢一点，才看得见北京。")
                    .font(.system(size: 10.5, design: .serif))
                    .foregroundStyle(Palette.ink3)
                Spacer()
                Text("lucia.travel")
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
        }
        .padding(18)
        .background(
            ZStack(alignment: .topTrailing) {
                Palette.paper
                Circle()
                    .fill(Palette.accent.opacity(0.14))
                    .frame(width: 180, height: 180)
                    .offset(x: 62, y: -62)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .overlay(alignment: .top) {
            TapeStrip(color: Palette.mustard.opacity(0.7), rotation: 3)
                .offset(y: -7)
        }
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.06), radius: 20, x: 0, y: 12)
    }
}

// MARK: - Big type

struct BigTypeView: View {
    var phrase: Phrase
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: 0x121110).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Eyebrow(text: "给店员看", color: Palette.paper.opacity(0.45))
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.paper)
                            .frame(width: 36, height: 36)
                            .background(Circle().strokeBorder(Palette.paper.opacity(0.25), lineWidth: 0.8))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.top, 10)

                Spacer()

                VStack(spacing: 20) {
                    Text(phrase.zh)
                        .font(.system(size: zhSize, weight: .black))
                        .foregroundStyle(Palette.paper)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .lineLimit(phrase.zh.count <= 12 ? 1 : 3)
                        .minimumScaleFactor(0.82)
                        .padding(.horizontal, 6)

                    Rectangle()
                        .fill(Palette.lime)
                        .frame(width: 38, height: 2.5)

                    Text(phrase.en)
                        .font(.system(size: 16))
                        .foregroundStyle(Palette.paper.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        SpeechService.shared.speak(phrase.zh)
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 12, weight: .bold))
                            Text("播放中文")
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 22)
                        .frame(height: 45)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.9), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Text("无需网络 · 已保存在离线语句库")
                        .font(.system(size: 9.5))
                        .foregroundStyle(Palette.paper.opacity(0.35))
                }
                .padding(.bottom, 26)
            }
        }
        .statusBarHidden(true)
    }

    private var zhSize: CGFloat {
        let count = max(phrase.zh.count, 1)
        return count <= 12 ? min(37, 330 / CGFloat(count)) : 30
    }
}

// MARK: - Reorder

struct ReorderSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("调整顺序")
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(Palette.ink)
                    Text("拖动右侧手柄，时间会自动重算")
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("完成")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 16)
                        .frame(height: 33)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 12)

            List {
                ForEach(model.stops) { stop in
                    HStack(spacing: 10) {
                        Text(stop.time)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                            .frame(width: 42, alignment: .leading)
                        Text(stop.name)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text(stop.duration)
                            .font(.system(size: 9.5))
                            .foregroundStyle(Palette.ink3)
                    }
                    .listRowBackground(Palette.paper)
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(Palette.lineSoft)
                }
                .onMove { source, destination in
                    model.moveStops(from: source, to: destination)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Palette.paper)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Palette.ink.opacity(0.1))
                    .frame(height: 1)
            }
            .environment(\.editMode, .constant(.active))
        }
        .background(Palette.bg)
    }
}

// MARK: - Legal

struct LegalSheet: View {
    var kind: LegalKind
    @Environment(\.dismiss) private var dismiss

    private var sections: [(String, String)] {
        if kind == .privacy {
            return [
                ("我们保存什么", "你的行程、清单勾选状态和离线语句包只保存在本机。社区浏览记录不会关联到你的身份。"),
                ("不会上传什么", "护照号、手机号、支付信息不经过 Lucia。需要预约门票时，会跳转到官方渠道完成。"),
                ("离线使用", "地图、翻译与应急语句支持离线。离线状态不会上传位置，只有你主动分享时才会生成链接。"),
                ("你的选择", "你可以在「我的」里关闭通知，或长按清单条目删除自定义内容。")
            ]
        }
        return [
            ("服务范围", "Lucia 提供行程规划、行前准备、翻译与社区内容浏览。门票、酒店与交通由第三方官方渠道提供。"),
            ("内容与建议", "AI 建议基于公开信息与你的偏好生成，实际开放时间、票价与天气请以官方信息为准。"),
            ("社区规范", "请分享真实的体验，不发布侵权、广告或不友善内容。违规内容会被隐藏。"),
            ("费用", "基础功能免费。部分离线包与增值服务可能会收费，购买前会明确提示。")
        ]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow(text: "LUCIA · LEGAL")
                        Text(kind.title)
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.4)
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 33, height: 33)
                            .background(Circle().fill(Palette.paper))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                Text("更新于 2026 年 10 月 · 适用于 Lucia iOS v1.0")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Palette.ink3)

                ForEach(sections.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(sections[index].0)
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Text(sections[index].1)
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.ink2)
                            .lineSpacing(4)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
                }

                Text("如有疑问：hello@lucia.travel")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Palette.ink3)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
        }
        .background(Palette.bg.ignoresSafeArea())
    }
}

// MARK: - Place detail

struct PlaceSheet: View {
    var place: ForumPlace
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var added = false
    @State private var saved = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                ZStack(alignment: .topTrailing) {
                    PhotoTile(symbol: place.symbol, tint: place.tint, height: 206)
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 33, height: 33)
                            .background(Circle().fill(Palette.paper))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(place.title)
                            .font(.system(size: 25, weight: .black))
                            .tracking(-0.4)
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text(place.price)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(Palette.accent)
                    }
                    Text(place.subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                    HStack(spacing: 5) {
                        ForEach(place.tags, id: \.self) { tag in
                            TagView(text: tag, style: .soft)
                        }
                        TagView(text: "♥ \(place.likes)", style: .neutral)
                    }
                    .padding(.top, 2)
                }

                VStack(alignment: .leading, spacing: 9) {
                    Eyebrow(text: "为什么推荐")
                    Text("本地人也常去，避开旅行团的高峰时段体验更好。建议在开门前 20 分钟到，或者错峰到下午 15:00 之后。")
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.ink2)
                        .lineSpacing(4)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.mustardSoft))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                VStack(alignment: .leading, spacing: 0) {
                    infoRow(icon: "clock", title: "营业时间", value: "10:00 – 22:00")
                    SoftDivider().padding(.leading, 38)
                    infoRow(icon: "location", title: "距离", value: "距酒店 2.4 km · 地铁 2 站")
                    SoftDivider().padding(.leading, 38)
                    infoRow(icon: "figure.walk", title: "建议停留", value: "45 分钟 – 1 小时")
                }
                .padding(.horizontal, 13)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                Button {
                    model.openAssistant("论坛 · \(place.title)")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        Text("问问 Lucia：这里适合我第几天去？")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Palette.ink2)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.limeSoft))
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 7) {
                        Text("“")
                            .font(LuciaType.serif(30, italic: true))
                            .foregroundStyle(Palette.accent)
                            .frame(height: 20, alignment: .top)
                        Text("下午三点以后去几乎不用等位，鸭皮还是脆的。")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundStyle(Palette.ink2)
                            .lineSpacing(3)
                    }
                    HStack(spacing: 6) {
                        Text("L")
                            .font(.system(size: 8.5, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 17, height: 17)
                            .background(Circle().fill(Palette.periwinkle))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.9))
                        Text("Lina · 社区笔记 · 3 天前")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                        Spacer(minLength: 0)
                        TagView(text: "86 人收藏", style: .neutral)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
                .overlay(alignment: .topLeading) {
                    StickerLabel(text: "社区原话", fill: Palette.pink, rotation: -4, icon: "quote.bubble.fill")
                        .offset(x: 10, y: -11)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                Button {
                    if !added {
                        model.addToChecklist(
                            title: place.title,
                            meta: "\(place.subtitle) · \(place.price)",
                            category: .tickets,
                            phase: .before
                        )
                        withAnimation { added = true }
                        Haptics.success()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: added ? "checkmark" : "text.badge.plus")
                            .font(.system(size: 10, weight: .bold))
                        Text(added ? "已加入清单" : "加入清单")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 43)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    model.toggleSaved(place)
                    saved.toggle()
                    Haptics.tap()
                } label: {
                    Image(systemName: (saved || model.savedPlaces.contains(place.id)) ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.accent)
                        .frame(width: 48, height: 43)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Palette.bg)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Palette.ink3)
                .frame(width: 22)
            Text(title)
                .font(.system(size: 10.5))
                .foregroundStyle(Palette.ink3)
            Spacer()
            Text(value)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Compose

struct ComposePost: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var bodyText = ""
    @State private var tag: String
    @State private var photos: [Int] = []
    @State private var attachRoute: Bool

    private let tags = ["餐厅", "景点", "路线", "伴手礼", "活动"]

    init(initialTag: String = "餐厅", initialAttachRoute: Bool = false) {
        _tag = State(initialValue: initialTag)
        _attachRoute = State(initialValue: initialAttachRoute)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow(text: "社区 · 发布")
                        Text("分享你在北京")
                            .font(.system(size: 26, weight: .black))
                            .tracking(-0.4)
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 33, height: 33)
                            .background(Circle().fill(Palette.paper))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                TextField("给它一个标题，比如「东四胡同的咖啡地图」", text: $title)
                    .font(.system(size: 13, weight: .semibold))
                    .textFieldStyle(.plain)
                    .padding(13)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                ZStack(alignment: .topLeading) {
                    if bodyText.isEmpty {
                        Text("说说具体体验：点了什么、多少钱、什么时候去最合适…")
                            .font(.system(size: 11.5))
                            .foregroundStyle(Palette.ink3)
                            .padding(.horizontal, 17)
                            .padding(.top, 15)
                    }
                    TextEditor(text: $bodyText)
                        .font(.system(size: 11.5))
                        .foregroundStyle(Palette.ink2)
                        .scrollContentBackground(.hidden)
                        .frame(height: 186)
                        .padding(10)
                }
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                VStack(alignment: .leading, spacing: 7) {
                    Eyebrow(text: "照片")
                    HStack(spacing: 8) {
                        ForEach(photos.indices, id: \.self) { index in
                            PhotoTile(symbol: index == 0 ? "fork.knife" : "building.columns", tint: index + 1, height: 76)
                                .frame(width: 76, height: 76)
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                        }
                        if photos.count < 9 {
                            Button {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    photos.append(photos.count)
                                }
                            } label: {
                                VStack(spacing: 5) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 15, weight: .medium))
                                    Text(photos.isEmpty ? "添加照片" : "再加一张")
                                        .font(.system(size: 9, weight: .medium))
                                }
                                .foregroundStyle(Palette.ink2)
                                .frame(width: 76, height: 76)
                                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Palette.paperWarm))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                                        .strokeBorder(Palette.ink.opacity(0.7), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3]))
                                )
                            }
                            .buttonStyle(PressableButtonStyle())
                        }
                        Spacer(minLength: 0)
                    }
                    Text("真实照片更容易被收藏 · 最多 9 张")
                        .font(.system(size: 9))
                        .foregroundStyle(Palette.ink3)
                }

                VStack(alignment: .leading, spacing: 7) {
                    Eyebrow(text: "分类")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 7) {
                            ForEach(tags, id: \.self) { option in
                                Chip(title: option, selected: tag == option) {
                                    withAnimation { tag = option }
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 9) {
                    Image(systemName: "lightbulb")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Text("真实、具体、带上价格，更容易被收藏。")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                }
                .padding(11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Palette.mustardSoft))
                .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(Palette.ink.opacity(0.35), lineWidth: 1))

                Button {
                    withAnimation(.easeOut(duration: 0.2)) { attachRoute.toggle() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "map")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 34, height: 34)
                            .background(Circle().fill(Palette.lime))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("关联我的路线")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                            Text("\(model.routeName) · \(model.stops.count) 站 · 4.2 km")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundStyle(Palette.ink3)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: attachRoute ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 17))
                            .foregroundStyle(attachRoute ? Palette.accent : Palette.ink3.opacity(0.5))
                    }
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(attachRoute ? Palette.ink : Palette.ink.opacity(0.55), lineWidth: 1.1)
                    )
                }
                .buttonStyle(PressableButtonStyle())

                HStack(spacing: 7) {
                    DoodleView(kind: .squiggle, color: Palette.ink3.opacity(0.55), lineWidth: 1.2)
                        .frame(width: 24, height: 7)
                    Text("发布后会出现在「社区 · 北京」，可随时编辑或删除。")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                }
                .padding(.top, 1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 26)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                model.toast("已发布 · 感谢你的分享", icon: "paperplane.fill")
                dismiss()
            } label: {
                Text("发布到社区")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(title.isEmpty ? Palette.ink3 : Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Capsule().fill(title.isEmpty ? Palette.cream.opacity(0.7) : Palette.lime))
                    .overlay(Capsule().strokeBorder(title.isEmpty ? Palette.ink.opacity(0.3) : Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(title.isEmpty)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 8)
            .background(Palette.bg)
        }
        .background(Palette.bg.ignoresSafeArea())
    }
}
