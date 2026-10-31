import SwiftUI

struct TripView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                hero
                if !model.reminderDismissed {
                    reminder
                }
                quickStats
                routeSection
                intelSection
                communitySection
                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 130)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Eyebrow(text: "我的旅行 / BEIJING")
                    DoodleView(kind: .sparkle, color: Palette.accent)
                        .frame(width: 9, height: 9)
                }
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Text("北京")
                        .font(.system(size: 44, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(Palette.ink)
                    TagView(text: "4 天 3 晚", style: .accent)
                }
                Text("10/15 – 10/18 · 2 人同行")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 7) {
                    IconCircleButton(icon: "bell", size: 36) {
                        model.openAssistant("行程 · 通知与提醒")
                    }
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Palette.accent)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().strokeBorder(Palette.paper, lineWidth: 1))
                            .offset(x: -3, y: 2)
                    }
                    AvatarView(name: "W", size: 36, fill: Palette.lime)
                }
                Text("3 天后出发")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
        }
    }

    // MARK: Hero

    private var hero: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                CityScape()
                    .frame(height: 212)
                HStack(alignment: .top) {
                    HStack(spacing: 5) {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Palette.accent)
                        Text("22°")
                            .font(.system(size: 12, weight: .black))
                        Text("多云转晴")
                            .font(.system(size: 9.5, weight: .medium))
                            .opacity(0.7)
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))

                    Spacer()

                    TagView(text: "第 2 天 / 4", style: .dark)
                }
                .padding(12)
            }
            .frame(height: 212)
            .clipped()

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("中轴线 · 故宫与胡同")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                    HStack(spacing: 12) {
                        Label("6 站", systemImage: "mappin.and.ellipse")
                        Label("4.2 km", systemImage: "figure.walk")
                        Label("约 5 小时", systemImage: "clock")
                    }
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                }
                Spacer()
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        model.tab = .plan
                    }
                } label: {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.3))
                        .compositingGroup()
                        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 2)
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 14)
            .background(Palette.paper)
        }
        .background(Palette.paper)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.15), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.06), radius: 18, x: 0, y: 12)
    }

    // MARK: Reminder

    private var reminder: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle().fill(Palette.paper)
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.ink)
            }
            .frame(width: 31, height: 31)
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("LUCIA 提醒")
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            model.reminderDismissed = true
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Palette.ink2)
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)
                }
                Text("10/15–17 白天 22℃，早晚 11℃。故宫周一闭馆，建议改到 15 号上午。")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(2.5)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    TagView(text: "已排进清单", style: .neutral)
                    TagView(text: "温差 11℃", style: .accent)
                    Spacer()
                    Button {
                        Haptics.tap()
                        model.tab = .plan
                        model.applyRouteSuggestion()
                    } label: {
                        HStack(spacing: 3) {
                            Text("调整路线")
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8, weight: .black))
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 9)
                        .frame(height: 25)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 1)
            }
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Palette.limeSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.2)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 3)
    }

    // MARK: Quick stats

    private var quickStats: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            PressableCardButton(action: {
                model.checklistOpen = true
            }) {
                HStack(spacing: 10) {
                    ProgressRingView(
                        progress: model.progress,
                        label: "\(Int(model.progress * 100))%",
                        size: 42,
                        lineWidth: 3.6,
                        track: Palette.paper.opacity(0.7),
                        tint: Palette.ink
                    )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("行前清单")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink2)
                        Text("\(model.doneCount) / \(model.totalCount)")
                            .font(.system(size: 21, weight: .black).width(.condensed))
                            .foregroundStyle(Palette.ink)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.mustardSoft))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 2.5)
            }

            statCard(icon: "map.fill", value: "6", unit: "站", label: "今日路线", tint: Palette.periwinkle, fill: Palette.periwinkleSoft) {
                model.tab = .plan
            }

            statCard(icon: "ticket.fill", value: "2", unit: "/ 4", label: "门票已约", tint: Palette.pink, fill: Palette.pinkSoft) {
                model.openAssistant("行程 · 门票预约")
            }

            statCard(icon: "figure.walk", value: "4.2", unit: "km", label: "步行距离", tint: Palette.mint, fill: Palette.mintSoft) {
                model.tab = .plan
            }
        }
    }

    private func statCard(icon: String, value: String, unit: String, label: String, tint: Color, fill: Color, action: @escaping () -> Void) -> some View {
        PressableCardButton(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(tint))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Palette.ink)
                }
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(value)
                        .font(.system(size: 24, weight: .black).width(.condensed))
                        .foregroundStyle(Palette.ink)
                    Text(unit)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Palette.ink2)
                }
                Text(label)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 2.5)
        }
    }

    // MARK: Route

    private var routeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "今天的路线", index: "01", trailing: "打开地图") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    model.tab = .plan
                }
            }

            PressableCardButton(action: {
                model.tab = .plan
            }) {
                HStack(spacing: 13) {
                    MiniRouteMap(points: model.stops.map { CGPoint(x: $0.x, y: $0.y) })
                        .frame(width: 94, height: 94)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 5) {
                            TagView(text: "草稿", style: .neutral)
                            TagView(text: "3 人协作", style: .blue)
                        }
                        Text("天安门 → 故宫 → 什刹海")
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        Text("09:00 出发 · 日落前到钟鼓楼")
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                        HStack(spacing: 6) {
                            AvatarStack(names: ["林", "周"], size: 21)
                            Text("+1 正在编辑")
                                .font(.system(size: 8.5, weight: .semibold))
                                .foregroundStyle(Palette.ink3)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
            }
        }
    }

    // MARK: Intel

    private var intelSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "行前情报", index: "02", trailing: "问 Lucia") {
                model.openAssistant("行程 · 行前情报")
            }

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                InfoTile(icon: "cloud.sun", eyebrow: "天气", value: "11° – 22°", detail: "昼夜温差大，带薄外套", accent: Palette.sky) {
                    model.openAssistant("天气 · 北京 10/15–18")
                }
                InfoTile(icon: "person.2", eyebrow: "客流", value: "上午 · 低", detail: "故宫 14 点后明显变挤", accent: Palette.mint) {
                    model.openAssistant("客流 · 故宫上午")
                }
                InfoTile(icon: "ticket", eyebrow: "余票", value: "812 张", detail: "故宫 10/15 09:00", accent: Palette.pink) {
                    model.openAssistant("门票 · 故宫余票")
                }
                InfoTile(icon: "bed.double", eyebrow: "住宿", value: "王府井", detail: "步行 12 分到故宫", accent: Palette.mustard) {
                    model.openAssistant("住宿 · 王府井")
                }
            }
        }
    }

    // MARK: Community

    private var communitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "社区灵感", index: "03", trailing: "去论坛") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                    model.tab = .forum
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    communityCard(
                        art: AnyView(MiniRouteMap(points: [CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.4, y: 0.6), CGPoint(x: 0.6, y: 0.4), CGPoint(x: 0.8, y: 0.2)], tint: Palette.blue)),
                        tag: "路线 · Lina",
                        title: "2 天胡同慢走 · 8 站",
                        meta: "4.8 分 · 收藏 1.2k",
                        fill: Palette.skySoft,
                        sticker: "WALK 08"
                    )
                    communityCard(
                        art: AnyView(PhotoTile(symbol: "fork.knife", tint: 0, height: 106)),
                        tag: "餐厅 · 本地人常去",
                        title: "四季民福 · 故宫店",
                        meta: "11:00 前到不排队",
                        fill: Palette.pinkSoft,
                        sticker: "EAT"
                    )
                    communityCard(
                        art: AnyView(PhotoTile(symbol: "sun.horizon", tint: 3, height: 106)),
                        tag: "景点 · 日落",
                        title: "景山看日落",
                        meta: "17:00 前上山 · 万春亭",
                        fill: Palette.mustardSoft,
                        sticker: "GOLDEN"
                    )
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func communityCard(art: AnyView, tag: String, title: String, meta: String, fill: Color, sticker: String) -> some View {
        PressableCardButton(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                model.tab = .forum
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topLeading) {
                    art
                        .frame(height: 106)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    StickerLabel(text: sticker, fill: Palette.paper, rotation: -4)
                        .padding(7)
                }
                Text(tag)
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text(meta)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            .padding(10)
            .frame(width: 190, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 3)
        }
    }

    // MARK: Footer

    private var footer: some View {
        VStack(spacing: 8) {
            DoodleView(kind: .squiggle, color: Palette.ink.opacity(0.3), lineWidth: 1.3)
                .frame(width: 48, height: 10)
            Text("慢一点，才看得见北京。")
                .font(.system(size: 12.5, weight: .medium, design: .serif).italic())
                .foregroundStyle(Palette.ink2)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 12)
    }
}
