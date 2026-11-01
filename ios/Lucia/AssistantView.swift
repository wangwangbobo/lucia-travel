import SwiftUI

struct AssistantView: View {
    @EnvironmentObject private var model: AppModel
    @FocusState private var composerFocused: Bool
    @State private var missingAnswer = false

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(model.chatMessages) { message in
                            messageRow(message)
                        }
                        if model.chatThinking {
                            thinkingRow
                        }
                        if model.showPlanBuilder {
                            planBuilder
                                .transition(.opacity)
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("chat-bottom")
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                    .padding(.bottom, 10)
                }
                .onAppear {
                    proxy.scrollTo("chat-bottom", anchor: .bottom)
                }
                .onChange(of: model.chatMessages.count) { _, _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo("chat-bottom", anchor: .bottom)
                    }
                }
                .onChange(of: model.chatThinking) { _, _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo("chat-bottom", anchor: .bottom)
                    }
                }
            }

            if !model.showPlanBuilder && !model.firstRunFlow {
                composer
            }
        }
        .background(Palette.bg.ignoresSafeArea())
        .interactiveDismissDisabled(model.showPlanBuilder || model.firstRunFlow)
        .onAppear {
            if model.chatMessages.isEmpty {
                model.seedAssistant()
            }
        }
    }


    private func chatText(_ raw: String) -> Text {
        if let attributed = try? AttributedString(
            markdown: raw,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) {
            return Text(attributed)
        }
        return Text(verbatim: raw)
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            if !model.showPlanBuilder {
                Capsule()
                    .fill(Palette.line)
                    .frame(width: 36, height: 4)
                    .padding(.top, 8)
            }

            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(Palette.lime)
                    Image(systemName: "sparkles")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                .frame(width: 39, height: 39)
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text("Pico")
                            .font(.system(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(Palette.ink)
                        HStack(spacing: 3) {
                            Circle().fill(Palette.ink).frame(width: 4, height: 4)
                            Text("Live AI")
                                .font(.system(size: 7, weight: .heavy, design: .monospaced))
                                .tracking(0.4)
                        }
                        .padding(.horizontal, 6)
                        .frame(height: 15)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                        .foregroundStyle(Palette.ink)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Palette.ok).frame(width: 5, height: 5)
                        Text(verbatim: "\(model.say("Looking at")) · \(model.chatDisplay(model.showPlanBuilder ? "New trip · Planning with Pico" : model.assistantContext))")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                Spacer()

                LanguagePill()

                if !model.showPlanBuilder && !model.firstRunFlow {
                    Button {
                        model.resetChat()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 33, height: 33)
                            .background(Circle().fill(Palette.paper))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        Haptics.tap()
                        model.assistantOpen = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Palette.ink)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Palette.paper))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                            .contentShape(Circle())
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, model.showPlanBuilder ? 8 : 0)
        .padding(.bottom, 10)
        .background(Palette.bg)
        .overlay(alignment: .bottom) {
            SoftDivider()
        }
    }

    // MARK: Messages

    private func messageRow(_ message: ChatMessage) -> some View {
        Group {
            if message.role == .assistant {
                HStack(alignment: .top, spacing: 8) {
                    ZStack {
                        Circle().fill(Palette.lime)
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Palette.ink)
                    }
                    .frame(width: 27, height: 27)
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 9) {
                        chatText(message.card == .plan ? model.planNarrativeText : model.chatDisplay(message.text))
                            .font(.system(size: 12))
                            .foregroundStyle(Palette.ink2)
                            .lineSpacing(3)
                            .fixedSize(horizontal: false, vertical: true)

                        if let card = message.card {
                            cardView(card)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink.opacity(0.7), lineWidth: 1.1))
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer(minLength: 18)
                }
            } else {
                HStack(alignment: .top, spacing: 8) {
                    Spacer(minLength: 46)
                    Text(verbatim: model.chatDisplay(message.text))
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.paper)
                        .lineSpacing(2)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.ink))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1))
                }
            }
        }
    }

    private var thinkingRow: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(Palette.lime)
                Image(systemName: "sparkles")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Palette.ink)
            }
            .frame(width: 27, height: 27)
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))

            HStack(spacing: 6) {
                ProgressView()
                    .tint(Palette.ink3)
                    .scaleEffect(0.7)
                Text("Thinking…")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Capsule().fill(Palette.paper))
            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.6), lineWidth: 1))

            Spacer()
        }
    }

    // MARK: Cards

    @ViewBuilder
    private func cardView(_ kind: AssistantCardKind) -> some View {
        switch kind {
        case .ticket:
            ticketCard
        case .hotels:
            hotelsCard
        case .checklist:
            checklistCard
        case .route:
            routeCard
        case .translate:
            translateCard
        case .plan:
            planCard
        }
    }

    private var ticketCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                IconBadge(icon: "building.columns", tint: Palette.accent, background: Palette.accentSoft.opacity(0.6), size: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Forbidden City")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                    Text("\(model.tripStamp(0).date) 09:00 · 2 adults")
                        .font(.system(size: 9.5))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer()
                Text("¥120")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.ink)
            }
            HStack(spacing: 5) {
                TagView(text: "812 left", style: .warn)
                TagView(text: "ID required", style: .neutral)
                TagView(text: "Scan ID to enter", style: .soft)
            }
            Button {
                model.bookForbiddenCity()
                confirm("Seats locked for \(model.tripStamp(0).date) 09:00 — 2 adults. Your QR code is in Me · Bookings.")
            } label: {
                Text("Lock seats")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.3), lineWidth: 1))
    }

    private var hotelsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            hotelRow(title: "Wangfujing", price: "From ¥680", note: "12 min walk to the Forbidden City", recommended: true)
            SoftDivider()
            hotelRow(title: "Nanluoguxiang", price: "From ¥520", note: "In the hutongs · quiet at night", recommended: false)
            SoftDivider()
            hotelRow(title: "Guomao", price: "From ¥760", note: "Direct metro · good for business", recommended: false)
            Button {
                model.addToChecklist(title: "Hotel · Wangfujing", meta: "\(model.tripDateRange(count: model.tripDayCount)) · \(max(0, model.tripDayCount - 1)) nights · Breakfast", category: .docs, phase: .before)
                confirm("Wangfujing, \(max(0, model.tripDayCount - 1)) nights, added to your prep list.")
            } label: {
                Text("Stay in Wangfujing")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.3), lineWidth: 1))
    }

    private func hotelRow(title: String, price: String, note: String, recommended: Bool) -> some View {
        HStack(spacing: 8) {
            Image(systemName: recommended ? "star.fill" : "circle")
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(recommended ? Palette.accent : Palette.ink3)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Text(note)
                    .font(.system(size: 9))
                    .foregroundStyle(Palette.ink3)
            }
            Spacer()
            Text(price)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
        }
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            checkRow(title: "eSIM / Chinese number", meta: "3 plans compared · From ¥29")
            SoftDivider()
            checkRow(title: "Install a VPN", meta: "Not on China's app stores")
            SoftDivider()
            checkRow(title: "Forbidden City tickets", meta: "\(model.tripStamp(0).date) 09:00 · 812 left")
            Button {
                model.addToChecklist(title: "eSIM / Chinese number", meta: "3 plans compared · From ¥29", category: .connectivity, phase: .arrival)
                model.addToChecklist(title: "Install a VPN", meta: "Set up before you fly · Works on arrival", category: .connectivity, phase: .arrival)
                model.addToChecklist(title: "Forbidden City tickets · \(model.tripStamp(0).date)", meta: "2 adults · ID booking", category: .tickets, phase: .before)
                confirm("3 items added to your prep list — tick them off under Trip.")
            } label: {
                Text("Add all to list")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.3), lineWidth: 1))
    }

    private func checkRow(title: String, meta: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Palette.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(Palette.ink)
                Text(meta)
                    .font(.system(size: 9))
                    .foregroundStyle(Palette.ink3)
            }
            Spacer()
        }
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            MiniRouteMap(points: model.stops.map { CGPoint(x: $0.x, y: $0.y) })
                .frame(height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 5) {
                TagView(text: "1.2 km less", style: .accent)
                TagView(text: "6 stops", style: .neutral)
                TagView(text: "~5 hr", style: .neutral)
            }
            Text("Tiananmen Square → Forbidden City → Shichahai → Jingshan → Nanluoguxiang → Drum & Bell Towers")
                .font(.system(size: 10))
                .foregroundStyle(Palette.ink2)
                .lineSpacing(2)

            Button {
                model.applyRouteSuggestion()
                model.tab = .plan
                confirm("New order applied — 1.2 km shorter. The map is updated.")
            } label: {
                Text("Apply changes")
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.3), lineWidth: 1))
    }

    private var translateCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("我食物过敏，需要去医院。")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Palette.ink)
            Text("I have a food allergy and need a hospital.")
                .font(.system(size: 9.5))
                .foregroundStyle(Palette.ink3)

            HStack(spacing: 8) {
                Button {
                    SpeechService.shared.speak("我食物过敏，需要去医院。")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 9, weight: .semibold))
                        Text("Play")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 31)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.line, lineWidth: 0.8))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    model.translateMode = .offline
                    model.scenario = .medical
                    model.tab = .translate
                    model.assistantOpen = false
                } label: {
                    Text("Open phrase pack")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Palette.paper)
                        .frame(maxWidth: .infinity)
                        .frame(height: 31)
                        .background(Capsule().fill(Palette.ink))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.3), lineWidth: 1))
    }

    // MARK: Plan builder

    private let planDayRows: [(day: String, text: String)] = [
        ("Day 1", "Central Axis · Forbidden City & Jingshan"),
        ("Day 2", "Great Wall · Badaling by private car"),
        ("Day 3", "Imperial gardens · Palace & museum"),
        ("Day 4", "Slow hutongs · departure")
    ]

    private var planBuilder: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 8, weight: .bold))
                    Text("TRIP MATCH")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(0.7)
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4.5)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))

                Spacer()

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(index < model.quizAnswered ? Palette.lime : Color.clear)
                            .frame(width: 6, height: 6)
                            .overlay(
                                Circle().strokeBorder(
                                    index < model.quizAnswered ? Palette.ink : Palette.ink.opacity(0.26),
                                    lineWidth: 1
                                )
                            )
                    }
                    Text("\(model.quizAnswered)/3")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                        .padding(.leading, 2)
                }
                .animation(.easeOut(duration: 0.18), value: model.quizAnswered)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Build your first Beijing trip")
                    .font(.system(size: 15.5, weight: .black))
                    .tracking(-0.3)
                    .foregroundStyle(Palette.ink)
                Text("Three answers and I'll set the order, the timing and the walking.")
                    .font(.system(size: 9.5))
                    .foregroundStyle(Palette.ink3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            planQuestion(
                1,
                "How many days do you like?",
                options: ["2–3 days", "4–5 days", "6+ days", "Surprise me"],
                current: model.quizDays
            ) { value in model.quizDays = value }

            planQuestion(
                2,
                "Your kind of holiday",
                options: ["Slow culture", "Food first", "Outdoors", "Night owl", "Family friendly", "Budget smart"],
                current: model.quizStyle
            ) { value in model.quizStyle = value }

            planQuestion(
                3,
                "A theme, or none?",
                options: ["Imperial history", "Hutongs & coffee", "Art & design", "Nature & parks", "Night markets", "No theme"],
                current: model.quizTheme
            ) { value in model.quizTheme = value }

            QuizNoteBox(text: $model.quizNote)

            Button {
                guard model.quizPersona != nil else {
                    Haptics.tap()
                    withAnimation(.easeOut(duration: 0.2)) { missingAnswer = true }
                    return
                }
                missingAnswer = false
                composerFocused = false
                model.buildPlan()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                    Text("Generate plan")
                        .font(.system(size: 12, weight: .black))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .black))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.9), radius: 0, x: 0, y: 3)
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Generate plan")

            HStack(alignment: .top, spacing: 5) {
                Image(systemName: missingAnswer ? "exclamationmark.circle" : "info.circle")
                    .font(.system(size: 9, weight: .bold))
                Text(missingAnswer
                     ? "Pick one per question to generate."
                     : (model.quizAnswered == 3 ? "All set — tap Generate plan." : "Pick one per question — you can change it later."))
                    .font(.system(size: 8.5, weight: .medium))
                    .lineSpacing(1.5)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(missingAnswer ? Palette.warn : Palette.ink3)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.2)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    private func planQuestion(
        _ number: Int,
        _ label: String,
        options: [String],
        current: String?,
        select: @escaping (String) -> Void
    ) -> some View {
        let done = current != nil
        return VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Text("\(number)")
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(done ? Palette.ink : Palette.ink3)
                    .frame(width: 17, height: 17)
                    .background(Circle().fill(done ? Palette.lime : Color.clear))
                    .overlay(
                        Circle().strokeBorder(
                            done ? Palette.ink : Palette.ink.opacity(0.24),
                            lineWidth: 1
                        )
                    )

                Text(LocalizedStringKey(label))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette.ink)

                Spacer(minLength: 0)

                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 15, height: 15)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 5),
                    count: options.count <= 4 ? 2 : 3
                ),
                spacing: 5
            ) {
                ForEach(options, id: \.self) { option in
                    let on = current == option
                    Button {
                        Haptics.tap()
                        withAnimation(.easeOut(duration: 0.16)) {
                            missingAnswer = false
                            select(option)
                        }
                    } label: {
                        Text(LocalizedStringKey(option))
                            .font(.system(size: 9.5, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.66)
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity)
                            .frame(height: 29)
                            .background(Capsule().fill(on ? Palette.ink : Palette.paper))
                            .foregroundStyle(on ? Palette.paper : Palette.ink2)
                            .overlay(
                                Capsule().strokeBorder(on ? Palette.ink : Palette.ink.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96))
                    .accessibilityLabel("\(label): \(option)")
                    .accessibilityAddTraits(on ? .isSelected : [])
                }
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Palette.paperWarm)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(done ? Palette.ink.opacity(0.4) : Palette.ink.opacity(0.13), lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.2), value: done)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 7, weight: .black))
                    Text("PLAN READY")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(0.7)
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 8)
                .padding(.vertical, 4.5)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))

                Spacer()

                Text(verbatim: "\(model.planLength) \(model.say("days"))")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            if let persona = model.quizPersona {
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(persona.title))
                        .font(.system(size: 15, weight: .black))
                        .tracking(-0.3)
                        .foregroundStyle(Palette.ink)
                    Text(verbatim: model.tripMeta(persona.meta))
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                if !persona.note.isEmpty {
                    HStack(alignment: .top, spacing: 5) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 8, weight: .bold))
                        Text(verbatim: "“\(persona.note)”")
                            .font(.system(size: 9, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Palette.ink2)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Palette.lime.opacity(0.22))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(Palette.ink.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                    )
                }
            }

            HStack(spacing: 0) {
                planStat("\(model.planLength)", "days")
                statDivider
                planStat("\(model.planLength * 4)", "stops")
                statDivider
                planStat(String(format: "%.1f", Double(model.planLength) * 4.6), "km walking")
            }
            .padding(.vertical, 7)
            .overlay(alignment: .top) {
                Rectangle().fill(Palette.ink.opacity(0.2)).frame(height: 1)
            }
            .overlay(alignment: .bottom) {
                Rectangle().fill(Palette.ink.opacity(0.2)).frame(height: 1)
            }

            VStack(spacing: 0) {
                ForEach(Array(planDayRows.prefix(min(model.planLength, 4)).enumerated()), id: \.offset) { index, row in
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text(verbatim: model.say(row.day))
                            .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                            .frame(width: 32, alignment: .leading)
                        Text(verbatim: model.say(row.text))
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 4)
                    .overlay(alignment: .top) {
                        if index > 0 {
                            Rectangle().fill(Palette.ink.opacity(0.1)).frame(height: 1)
                        }
                    }
                }
            }

            if model.planLength > 4 {
                Text(verbatim: model.lang == .zh
                     ? "还有 \(model.planLength - 4) 天，已存进行程"
                     : "+ \(model.planLength - 4) more days, saved to your trip")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .padding(.top, 3)
            }

            Button {
                Haptics.success()
                model.tab = .trip
                model.assistantOpen = false
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "map")
                        .font(.system(size: 9, weight: .bold))
                    Text("View my trip")
                        .font(.system(size: 10, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundStyle(Palette.paper)
                .frame(maxWidth: .infinity)
                .frame(height: 33)
                .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func planStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 13, weight: .black))
                .tracking(-0.3)
                .foregroundStyle(Palette.ink)
            Text(verbatim: model.say(label))
                .font(.system(size: 7, weight: .semibold))
                .foregroundStyle(Palette.ink3)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 8)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Palette.ink.opacity(0.18))
            .frame(width: 1, height: 26)
    }

    // MARK: Composer

    private var composer: some View {
        VStack(spacing: 9) {
            if !model.showPlanBuilder {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(model.quickPrompts, id: \.self) { prompt in
                            Button {
                                composerFocused = false
                                model.sendChat(prompt)
                            } label: {
                                Text(verbatim: model.say(prompt))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Palette.ink)
                                    .padding(.horizontal, 11)
                                    .frame(height: 30)
                                    .background(Capsule().fill(Palette.paper))
                                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.65), lineWidth: 1))
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.96))
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            HStack(spacing: 8) {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.ink2)
                    TextField("Ask Pico, e.g. “Any breakfast spots nearby?”", text: $model.chatDraft)
                        .font(.system(size: 12))
                        .textFieldStyle(.plain)
                        .focused($composerFocused)
                        .submitLabel(.send)
                        .onSubmit(send)
                }
                .padding(.horizontal, 13)
                .frame(height: 43)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))

                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 43, height: 43)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
                }
                .buttonStyle(PressableButtonStyle())
                .opacity(model.chatDraft.trimmingCharacters(in: .whitespaces).isEmpty ? 0.55 : 1)
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 9)
        .padding(.bottom, 10)
        .background(Palette.bg)
        .overlay(alignment: .top) {
            SoftDivider()
        }
    }

    private func send() {
        let text = model.chatDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        composerFocused = false
        model.sendChat(text)
    }

    private func confirm(_ text: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
            model.chatMessages.append(ChatMessage(role: .assistant, text: text))
        }
        Haptics.success()
    }
}
