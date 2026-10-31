import SwiftUI
import UIKit

struct TranslateView: View {
    @EnvironmentObject private var model: AppModel
    @State private var bigType: Phrase? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 13) {
                header
                SegmentedControl(
                    options: TranslateMode.allCases,
                    title: { $0.title },
                    selection: $model.translateMode
                )
                switch model.translateMode {
                case .live:
                    liveSection
                case .offline:
                    offlineSection
                case .photo:
                    photoSection
                }
                aiCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 130)
        }
        .fullScreenCover(item: $bigType) { phrase in
            BigTypeView(phrase: phrase)
                .preferredColorScheme(.dark)
        }
        #if DEBUG
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-bigtype"), let phrase = model.phrases.first {
                bigType = phrase
            }
        }
        #endif
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Eyebrow(text: "翻译 / TRANSLATE")
                    StickerLabel(text: "SAY IT", fill: Palette.lime, rotation: -3)
                }
                (Text("说清楚，\n") + Text("就不慌了").foregroundColor(Palette.accent))
                    .font(.system(size: 35, weight: .black))
                    .tracking(-0.6)
                    .lineSpacing(1)
                Text("实时对话 · 离线语句 · 拍照即译")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 8, weight: .bold))
                    Text("离线可用")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Capsule().fill(Palette.mint))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                Text("86 句 · 4.2 MB")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            .padding(.top, 2)
        }
    }

    // MARK: Live

    private var liveSection: some View {
        VStack(spacing: 10) {
            languageCard

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Eyebrow(text: "实时对话", color: Palette.ink2)
                    Spacer()
                    Text("\(model.liveMessages.count) 条")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                ForEach(model.liveMessages) { message in
                    messageBubble(message)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 23, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 23, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)

            micArea
            quickPhrases
        }
    }

    private var languageCard: some View {
        let flipped = model.languageFlipped
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(flipped ? "English" : "中文")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Palette.ink)
                Text(flipped ? "English (US)" : "自动识别")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    model.languageFlipped.toggle()
                }
                Haptics.tap()
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(flipped ? "中文" : "English")
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(Palette.ink)
                Text(flipped ? "自动识别" : "English (US)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.periwinkleSoft))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    private func messageBubble(_ message: LiveMessage) -> some View {
        VStack(alignment: message.isMine ? .trailing : .leading, spacing: 3) {
            VStack(alignment: .leading, spacing: 3) {
                Text(message.zh)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(message.isMine ? Palette.paper : Palette.ink)
                Text(message.en)
                    .font(.system(size: 9.5))
                    .foregroundStyle(message.isMine ? Palette.paper.opacity(0.65) : Palette.ink3)
            }
            .padding(9)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(message.isMine ? Palette.ink : Palette.paperWarm)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(message.isMine ? Palette.ink : Palette.ink.opacity(0.35), lineWidth: 1)
            )

            HStack(spacing: 5) {
                Text(message.isMine ? "我说" : "对方")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                Button {
                    SpeechService.shared.speak(message.zh)
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(Palette.ink2)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isMine ? .trailing : .leading)
    }

    private var micArea: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Palette.accent.opacity(model.listening ? 0.5 : 0.18), style: StrokeStyle(lineWidth: 1.4, dash: [5, 5]))
                    .frame(width: 96, height: 96)
                    .scaleEffect(model.listening ? 1.08 : 0.94)
                    .animation(
                        model.listening
                            ? .easeInOut(duration: 1.1).repeatForever(autoreverses: true)
                            : .easeOut(duration: 0.3),
                        value: model.listening
                    )

                Button {
                    model.simulateListening()
                } label: {
                    ZStack {
                        Circle().fill(Palette.coral)
                            .frame(width: 76, height: 76)
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.4))
                            .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 3)
                        if model.listening {
                            Waveform(active: true, color: Palette.ink, barCount: 9)
                        } else {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                        }
                    }
                }
                .buttonStyle(PressableButtonStyle(scale: 0.94))
            }
            .frame(height: 96)

            Text(model.listening ? "正在听… 说完点一下结束" : "点一下开始说话")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(model.listening ? Palette.accent : Palette.ink2)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickPhrases: some View {
        HStack(spacing: 6) {
            ForEach(["地铁站怎么走？", "我对花生过敏", "请帮我叫车"], id: \.self) { phrase in
                Button {
                    SpeechService.shared.speak(phrase)
                    model.toast("正在播放 · \(phrase)", icon: "speaker.wave.2.fill")
                } label: {
                    Text(phrase)
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 27)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.96))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Offline

    private var offlineSection: some View {
        VStack(spacing: 13) {
            offlineBanner
            scenarioGrid
            phraseList
            if model.scenario == .medical || model.scenario == .emergency {
                emergencyCard
            }
        }
    }

    private var offlineBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Palette.mint))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
            VStack(alignment: .leading, spacing: 2) {
                Text("离线语句库 · 已下载")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("没有网络也能用，出门前不用再准备。")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer()
            TagView(text: "86 句", style: .ok)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.limeSoft))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    private var scenarioFills: [Color] {
        [Palette.mustardSoft, Palette.skySoft, Palette.mintSoft, Palette.pinkSoft, Palette.periwinkleSoft, Palette.limeSoft]
    }

    private var scenarioGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
            spacing: 8
        ) {
            ForEach(Array(Scenario.allCases.enumerated()), id: \.element) { offset, scenario in
                let active = model.scenario == scenario
                let total = model.phrases.filter { $0.scenario == scenario }.count
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                        model.scenario = scenario
                    }
                    Haptics.tap()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: scenario.icon)
                            .font(.system(size: 16, weight: .bold))
                        Text(scenario.title)
                            .font(.system(size: 10.5, weight: .bold))
                        Text("\(total) 句")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .opacity(0.6)
                    }
                    .foregroundStyle(active ? Palette.paper : Palette.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(active ? Palette.ink : scenarioFills[offset % scenarioFills.count])
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Palette.ink, lineWidth: 1.2)
                    )
                    .compositingGroup()
                    .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2)
                }
                .buttonStyle(PressableButtonStyle(scale: 0.97))
            }
        }
    }

    private var phraseList: some View {
        let list = model.phrases.filter { $0.scenario == model.scenario }
        return VStack(spacing: 0) {
            HStack {
                Text("\(model.scenario.title) · \(list.count) 句")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("点 Aa 放大给店员看")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
            .padding(.bottom, 8)

            ForEach(list) { phrase in
                HStack(alignment: .top, spacing: 9) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(phrase.zh)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Text(phrase.en)
                            .font(.system(size: 9.5))
                            .foregroundStyle(Palette.ink3)
                    }
                    Spacer(minLength: 4)
                    Button {
                        SpeechService.shared.speak(phrase.zh)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 31, height: 31)
                            .background(Circle().fill(Palette.paperWarm))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                    Button {
                        bigType = phrase
                    } label: {
                        Text("Aa")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 31, height: 31)
                            .background(Circle().fill(Palette.lime))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.vertical, 9)

                if phrase.id != list.last?.id {
                    SoftDivider()
                }
            }
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    private var emergencyCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Image(systemName: "exclamationmark.shield.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette.warn)
                Text("紧急情况")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Spacer()
                TagView(text: "全国通用", style: .warn)
            }
            Text("急救 120 · 报警 110 · 国际 SOS 010-6462-9100")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Palette.ink2)

            HStack(spacing: 8) {
                Button {
                    model.toast("正在拨打 120（演示）", icon: "phone.fill")
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("拨打 120")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(Capsule().fill(Palette.warn))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    model.toast("已准备酒店地址 · 出示给司机", icon: "location.fill")
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("给司机看地址")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 35)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.accentSoft))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
    }


    // MARK: Photo

    private var menuItems: [(zh: String, en: String, price: String)] {
        [
            ("炸酱面", "Zhajiang noodles", "¥28"),
            ("卤煮火烧", "Pork offal stew", "¥35"),
            ("豆汁儿", "Fermented bean drink", "¥8"),
            ("焦圈", "Fried dough ring", "¥3")
        ]
    }

    private var signItems: [(zh: String, en: String, price: String)] {
        [
            ("南锣鼓巷", "Nanluoguxiang Alley", "北"),
            ("什刹海", "Shichahai Lake", "800m"),
            ("地铁 6 号线", "Metro Line 6", "→")
        ]
    }

    private var photoRows: [(zh: String, en: String, price: String)] {
        model.photoSample == .menu ? menuItems : signItems
    }

    private var photoSection: some View {
        VStack(spacing: 12) {
            photoCameraCard
            photoControls
            if model.photoScanned {
                photoResultCard
            } else {
                photoHintCard
            }
            photoPrivacy
        }
    }

    private var photoCameraCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Palette.coral)
                    .frame(width: 6, height: 6)
                Text("相机 · 自动识别中文")
                    .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.paper)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: model.photoScanning ? "text.viewfinder" : "viewfinder")
                        .font(.system(size: 8, weight: .bold))
                    Text(model.photoScanning ? "识别中…" : "1×")
                        .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(model.photoScanning ? Palette.lime : Palette.paper.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Palette.ink)

            ZStack {
                if model.photoSample == .menu {
                    menuScene
                } else {
                    signScene
                }
                viewfinderCorners
                if model.photoScanning {
                    ScanBeam()
                }
            }
            .frame(height: 232)
            .clipped()
        }
        .background(Palette.ink)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
    }

    private var menuScene: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.mustardSoft, Palette.accentSoft],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Palette.paper.opacity(0.45))
                .frame(width: 130, height: 130)
                .offset(x: -120, y: 100)
            Circle()
                .fill(Palette.paper.opacity(0.3))
                .frame(width: 86, height: 86)
                .offset(x: 128, y: -92)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("南锣小馆")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(Palette.ink)
                        Text("NANLUO BISTRO · 菜单")
                            .font(.system(size: 6.5, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }
                    Spacer()
                    Text("中 / EN")
                        .font(.system(size: 6, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 0.8))
                }
                Rectangle()
                    .fill(Palette.ink.opacity(0.18))
                    .frame(height: 1)
                VStack(spacing: 4) {
                    ForEach(Array(photoRows.enumerated()), id: \.offset) { index, row in
                        menuRow(index: index, row: row)
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Palette.paper))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Palette.ink, lineWidth: 1.1)
            )
            .rotationEffect(.degrees(-1.6))
            .padding(.horizontal, 26)
            .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 4)
        }
    }

    private func menuRow(index: Int, row: (zh: String, en: String, price: String)) -> some View {
        HStack(spacing: 6) {
            if model.photoScanned {
                photoIndexBadge(index)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(row.zh)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text(row.en)
                    .font(.system(size: 6.5, weight: .medium))
                    .foregroundStyle(Palette.ink3)
            }
            Spacer(minLength: 4)
            Text(row.price)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Palette.ink)
        }
        .padding(.horizontal, 6)
        .frame(height: 27)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(model.photoScanned ? Palette.lime.opacity(0.55) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(
                    model.photoScanned ? Palette.olive : Color.clear,
                    lineWidth: 1
                )
        )
    }

    private var signScene: some View {
        ZStack {
            LinearGradient(colors: [Palette.sky, Palette.skySoft], startPoint: .top, endPoint: .bottom)
            Circle()
                .fill(Palette.paper.opacity(0.85))
                .frame(width: 66, height: 66)
                .offset(x: -108, y: -84)
            Circle()
                .fill(Palette.paper.opacity(0.7))
                .frame(width: 44, height: 44)
                .offset(x: -84, y: -92)
            Capsule()
                .fill(Palette.mint)
                .frame(width: 280, height: 90)
                .offset(y: 118)
            Rectangle()
                .fill(Palette.ink.opacity(0.8))
                .frame(width: 5, height: 132)
                .offset(y: 62)

            VStack(spacing: 8) {
                ForEach(Array(photoRows.enumerated()), id: \.offset) { index, row in
                    signBoard(index: index, row: row)
                }
            }
            .offset(y: -20)
        }
    }

    private func signBoard(index: Int, row: (zh: String, en: String, price: String)) -> some View {
        HStack(spacing: 6) {
            if model.photoScanned {
                photoIndexBadge(index)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(row.zh)
                    .font(.system(size: index == 0 ? 12 : 10, weight: .bold))
                    .foregroundStyle(Palette.paper)
                Text(row.en)
                    .font(.system(size: 6, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.paper.opacity(0.72))
            }
            Spacer(minLength: 4)
            Text(row.price)
                .font(.system(size: 8.5, weight: .black, design: .monospaced))
                .foregroundStyle(Palette.paper)
        }
        .padding(.horizontal, 9)
        .frame(
            width: index == 0 ? 200 : (index == 1 ? 176 : 148),
            height: index == 0 ? 48 : 38
        )
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Palette.olive))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(
                    model.photoScanned ? Palette.lime : Palette.paper.opacity(0.85),
                    lineWidth: model.photoScanned ? 1.8 : 1
                )
        )
        .rotationEffect(.degrees(index == 0 ? -1 : 0))
    }

    private func photoIndexBadge(_ index: Int) -> some View {
        Text("\(index + 1)")
            .font(.system(size: 7, weight: .black, design: .monospaced))
            .foregroundStyle(Palette.ink)
            .frame(width: 14, height: 14)
            .background(Circle().fill(Palette.lime))
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
    }

    private var viewfinderCorners: some View {
        GeometryReader { geo in
            let length: CGFloat = 18
            let inset: CGFloat = 14
            Path { path in
                path.move(to: CGPoint(x: inset, y: inset + length))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset + length, y: inset))

                path.move(to: CGPoint(x: geo.size.width - inset - length, y: inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: inset + length))

                path.move(to: CGPoint(x: inset, y: geo.size.height - inset - length))
                path.addLine(to: CGPoint(x: inset, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: inset + length, y: geo.size.height - inset))

                path.move(to: CGPoint(x: geo.size.width - inset - length, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset))
                path.addLine(to: CGPoint(x: geo.size.width - inset, y: geo.size.height - inset - length))
            }
            .stroke(Palette.lime, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .allowsHitTesting(false)
    }

    private var photoControls: some View {
        HStack(spacing: 8) {
            ForEach(PhotoSample.allCases) { sample in
                let active = model.photoSample == sample
                Button {
                    model.setPhotoSample(sample)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: sample.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(sample.title)
                            .font(.system(size: 9.5, weight: .bold))
                    }
                    .foregroundStyle(active ? Palette.paper : Palette.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(Capsule().fill(active ? Palette.ink : Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.96))
            }

            Spacer(minLength: 0)

            Text(model.photoScanned ? "已译 \(photoRows.count) 段" : "放进取景框")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)

            Button {
                if model.photoScanning { return }
                if model.photoScanned {
                    model.clearPhoto()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        model.scanPhoto()
                    }
                } else {
                    model.scanPhoto()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Palette.paper)
                        .frame(width: 48, height: 48)
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.4))
                    Circle()
                        .fill(model.photoScanning ? Palette.mustard : Palette.coral)
                        .frame(width: 35, height: 35)
                    Image(systemName: model.photoScanned ? "arrow.clockwise" : "camera.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.14), radius: 0, x: 0, y: 2.5)
            }
            .buttonStyle(PressableButtonStyle(scale: 0.94))
        }
    }

    private var photoHintCard: some View {
        HStack(spacing: 10) {
            IconBadge(icon: "text.viewfinder", tint: Palette.ink, background: Palette.mustard, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("拍菜单、路牌、手写纸条都可以")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("按下快门，Lucia 会圈出文字并给出中英对照。")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.limeSoft))
        .overlay(
            RoundedRectangle(cornerRadius: 19, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.1)
        )
    }

    private var photoResultCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Text("识别结果")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                TagView(text: "中文 → EN", style: .ok)
                Spacer()
                Text("本地识别 · 0.8s")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            ForEach(Array(photoRows.enumerated()), id: \.offset) { index, row in
                HStack(spacing: 8) {
                    photoIndexBadge(index)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(row.zh)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                        Text(row.en)
                            .font(.system(size: 9.5))
                            .foregroundStyle(Palette.ink3)
                    }
                    Spacer(minLength: 4)
                    Button {
                        SpeechService.shared.speak(row.en)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Palette.paperWarm))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.vertical, 5)

                if index != photoRows.count - 1 {
                    SoftDivider()
                }
            }

            HStack(spacing: 8) {
                Button {
                    let text = photoRows.map { "\($0.zh)  \($0.en)" }.joined(separator: "\n")
                    UIPasteboard.general.string = text
                    model.toast("已复制中英对照", icon: "doc.on.doc.fill")
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 9, weight: .bold))
                        Text("复制全部")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.paperWarm))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    let text = photoRows.map { $0.en }.joined(separator: ", ")
                    SpeechService.shared.speak(text)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("念给我听")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.top, 2)
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 21, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.2)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    private var photoPrivacy: some View {
        HStack(spacing: 5) {
            Image(systemName: "lock.fill")
                .font(.system(size: 8, weight: .semibold))
            Text("照片只在手机本地识别，不上传；返回即自动删除。")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
        }
        .foregroundStyle(Palette.ink3)
        .frame(maxWidth: .infinity)
    }

    // MARK: AI

    private var aiCard: some View {
        HStack(spacing: 10) {
            IconBadge(icon: "sparkles", tint: Palette.ink, background: Palette.lime, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("表达不出来？让 Lucia 替你组织句子")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("说明场景，她会给出中英对照和发音。")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(Palette.ink)
                .frame(width: 28, height: 28)
                .background(Circle().fill(Palette.paper))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.limeSoft))
        .dashedBorder(color: Palette.ink.opacity(0.5), radius: 19)
        .contentShape(Rectangle())
        .onTapGesture {
            model.openAssistant("翻译 · 帮我组织一句话")
        }
    }
}

private struct ScanBeam: View {
    @State private var travel: CGFloat = -56

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                colors: [
                    Palette.lime.opacity(0),
                    Palette.lime.opacity(0.45),
                    Palette.lime.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 58)
            .offset(y: travel)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
                    travel = geo.size.height - 12
                }
            }
        }
        .allowsHitTesting(false)
    }
}
