import SwiftUI

struct TripView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showAddStop = false
    @State private var showReorder = false
    @State private var showDates = false
    @State private var draggingStopID: UUID?
    @State private var stopDragOffset: CGFloat = 0
    @State private var stopDropTarget: Int?
    @State private var stopFrames: [UUID: CGRect] = [:]

    var body: some View {
        Group {
            if model.planBuilt && model.tripLive {
                LiveTripView()
            } else {
                editor
            }
        }
        .sheet(isPresented: $showAddStop) {
            AddStopSheet()
                .environmentObject(model)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $showReorder) {
            ReorderSheet()
                .environmentObject(model)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $showDates) {
            TripDatesSheet(start: model.tripStartDate)
                .environmentObject(model)
                .presentationDetents([.fraction(0.78), .large])
                .presentationCornerRadius(28)
                .presentationBackground(Palette.bg)
        }
        .onAppear {
            model.ensureTripDays()
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-dates") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showDates = true
                }
            }
            #endif
        }
    }

    // MARK: Editor

    private var editor: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottom) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        if model.planBuilt {
                            planBanner
                        }
                        routeSection
                            .id("trip-route")
                        daysSection {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("trip-route", anchor: .top)
                            }
                        }
                        quizSection
                            .id("trip-quiz")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 210)
                }

                if model.planBuilt {
                    tripCTA
                        .padding(.horizontal, 16)
                        .padding(.bottom, 80)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            #if DEBUG
            .onAppear {
                guard ProcessInfo.processInfo.arguments.contains("-tripbottom") else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        proxy.scrollTo("trip-quiz", anchor: .bottom)
                    }
                }
            }
            #endif
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Eyebrow(text: "My trip / BEIJING")
                    DoodleView(kind: .sparkle, color: Palette.accent)
                        .frame(width: 9, height: 9)
                }
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Text("Beijing")
                        .font(.system(size: 44, weight: .black))
                        .tracking(-1)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    TagView(text: model.lang == .zh ? "\(planDayCount) 天 · \(max(0, planDayCount - 1)) 晚" : "\(planDayCount) days · \(max(0, planDayCount - 1)) nights", style: .accent)
                }
                Button {
                    Haptics.tap()
                    showDates = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 9, weight: .bold))
                        Text(model.tripDatesLine(count: planDayCount))
                            .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 7.5, weight: .black))
                            .opacity(0.55)
                    }
                    .foregroundStyle(Palette.ink2)
                    .padding(.horizontal, 9)
                    .frame(height: 25)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.28), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.97))
                .accessibilityLabel("Adjust trip dates")
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                AvatarView(name: "W", size: 36, fill: Palette.lime)
                Text(model.planBuilt ? "Day \(model.tripDay + 1) of \(planDayCount)" : "Today · Day 1")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
        }
    }

    private var planDayCount: Int {
        model.planBuilt ? model.tripDayCount : 4
    }

    private var planBanner: some View {
        Button {
            Haptics.tap()
            model.openAssistant("Trip · Adjust the plan")
        } label: {
            HStack(spacing: 9) {
                ZStack {
                    Circle().fill(Palette.lime)
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                .frame(width: 30, height: 30)
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))

                VStack(alignment: .leading, spacing: 1) {
                    Text("PICO BUILT THIS PLAN")
                        .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundStyle(Palette.ink3)
                    Text(model.lang == .zh
                         ? "\(model.say(model.quizPersona?.title ?? "Your travel plan")) · \(planDayCount) 天"
                         : "\(model.quizPersona?.title ?? "Your travel plan") · \(planDayCount) days")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 4)

                HStack(spacing: 3) {
                    Text("Adjust")
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .black))
                }
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Palette.ink2)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Palette.ink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
        .buttonStyle(PressableButtonStyle(scale: 0.99))
    }

    // MARK: Route

    private var routeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Your route", icon: "point.topleft.down.to.point.bottomright.curvepath", trailing: "Ask Pico") {
                model.openAssistant("Trip · Adjust the plan")
            }

            if model.planBuilt, let day = model.currentTripDay {
                routeCard(day)
            } else {
                emptyRouteCard
            }
        }
    }

    private var emptyRouteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No route yet")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Palette.ink)
            Text("Answer three quick questions and Pico will lay out the days, timing and stops.")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
            LuciaLimeButton(title: "Plan with Pico", icon: "sparkles", wide: true) {
                model.openAssistant("New trip · Planning with Pico")
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.3))
    }

    private func routeCard(_ day: TripDay) -> some View {
        VStack(spacing: 0) {
            dayChips

            ZStack(alignment: .topTrailing) {
                TripRouteMap(
                    stops: model.currentStops,
                    editing: model.tripEdit,
                    selectedID: model.selectedStopID,
                    liveStop: nil,
                    lang: model.lang,
                    onTap: { stop in
                        Haptics.tap()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                            model.selectedStopID = model.selectedStopID == stop.id ? nil : stop.id
                        }
                    },
                    onMove: { id, x, y in
                        model.moveTripStop(id, toX: x, toY: y)
                    },
                    onMoveEnd: {
                        model.didFinishTripStopMove()
                    }
                )
                .frame(height: 188)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Palette.ink, lineWidth: 1.2)
                )

                mapTools
                    .padding(8)
            }
            .padding(.horizontal, 12)

            VStack(alignment: .leading, spacing: 10) {
                head(day)

                if showsAIBar {
                    aiBar
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                VStack(spacing: 2) {
                    ForEach(Array(model.currentStops.enumerated()), id: \.element.id) { index, stop in
                        let isDragging = draggingStopID == stop.id
                        let showDrop = draggingStopID != nil
                            && !isDragging
                            && stopDropTarget == index
                            && dragSourceIndex != index
                        stopRow(index: index, stop: stop, isDropTarget: showDrop)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: TripStopFrameKey.self,
                                        value: [stop.id: proxy.frame(in: .named("tripStops"))]
                                    )
                                }
                            )
                            .offset(y: isDragging ? stopDragOffset : 0)
                            .scaleEffect(isDragging ? 1.02 : 1)
                            .shadow(color: isDragging ? Palette.ink.opacity(0.16) : .clear, radius: 11, x: 0, y: 6)
                            .zIndex(isDragging ? 20 : 0)
                    }
                }
                .coordinateSpace(name: "tripStops")
                .onPreferenceChange(TripStopFrameKey.self) { stopFrames = $0 }

                Text(model.say(day.note))
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 7)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Palette.limeSoft))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(Palette.ink.opacity(0.24), lineWidth: 1)
                    )

                HStack(spacing: 6) {
                    Button {
                        Haptics.tap()
                        showAddStop = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 9.5, weight: .bold))
                            Text("Add a stop")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Capsule().fill(Palette.paperWarm))
                        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.65), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3])))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        Haptics.tap()
                        model.pendingSimilar = true
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            model.tab = .plan
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "square.stack.3d.up.fill")
                                .font(.system(size: 9.5, weight: .bold))
                            Text("Similar routes")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 13)
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.15), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.06), radius: 20, x: 0, y: 12)
    }

    private var dayChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(model.tripDays.indices, id: \.self) { index in
                    let active = model.tripDay == index
                    Button {
                        model.selectTripDay(index)
                    } label: {
                        HStack(spacing: 4) {
                            Text(model.lang == .zh ? "第 \(index + 1) 天" : "D\(index + 1)")
                                .font(.system(size: 10.5, weight: .black, design: .monospaced))
                            Text(model.tripDays[index].date)
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .opacity(active ? 0.75 : 0.55)
                        }
                        .foregroundStyle(active ? Palette.paper : Palette.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(Capsule().fill(active ? Palette.ink : Palette.paperWarm))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: active ? 1.2 : 0.9))
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.95))
                    .accessibilityLabel("Day \(index + 1), \(model.tripDays[index].date)")
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
    }

    private var mapTools: some View {
        HStack(spacing: 5) {
            Button {
                model.toggleTripEdit()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: model.tripEdit ? "checkmark" : "hand.draw")
                        .font(.system(size: 8.5, weight: .bold))
                    Text(model.tripEdit ? "Done" : "Edit pins")
                        .font(.system(size: 9.5, weight: .semibold))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 9)
                .frame(height: 28)
                .background(Capsule().fill(model.tripEdit ? Palette.lime : Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                .compositingGroup()
                .shadow(color: model.tripEdit ? Palette.ink.opacity(0.14) : .clear, radius: 0, x: 0, y: 2)
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))

            Button {
                Haptics.tap()
                showReorder = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 8.5, weight: .bold))
                    Text("Reorder")
                        .font(.system(size: 9.5, weight: .semibold))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 9)
                .frame(height: 28)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))
        }
    }

    private func head(_ day: TripDay) -> some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Text(model.lang == .zh ? String(format: "第 %02d 天", day.day) : String(format: "DAY %02d", day.day))
                        .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(Palette.ink3)
                    TagView(text: model.say(model.tripDay == 0 ? "Today" : day.tag), style: day.tagStyle)
                }
                Text(model.say(day.title))
                    .font(.system(size: 18, weight: .heavy))
                    .tracking(-0.3)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(metaText(day))
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            savedPill
        }
    }

    private var savedPill: some View {
        HStack(spacing: 3) {
            Image(systemName: model.tripSaved ? (model.tripDirty ? "exclamationmark.circle" : "checkmark.circle") : "pencil.circle")
                .font(.system(size: 8, weight: .bold))
            Text(model.tripSaved ? (model.tripDirty ? "Unsaved" : "Saved") : "Draft")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
        }
        .foregroundStyle(model.tripDirty ? Palette.warn : (model.tripSaved ? Palette.ok : Palette.ink2))
        .padding(.horizontal, 7)
        .frame(height: 21)
        .background(Capsule().fill(model.tripDirty ? Palette.accentSoft : (model.tripSaved ? Palette.mintSoft : Palette.paperWarm)))
        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.35), lineWidth: 0.8))
    }

    private var showsAIBar: Bool {
        model.aiSuggestionVisible && model.tripDay == 0 && !model.tripEdit
    }

    private var aiBar: some View {
        HStack(spacing: 7) {
            Image(systemName: "sparkles")
                .font(.system(size: 9.5, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 23, height: 23)
                .background(Circle().fill(Palette.lime))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.9))
            VStack(alignment: .leading, spacing: 1) {
                Text("Pico: move Shichahai to 13:00")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                Text("1.2 km less · one backtrack fewer")
                    .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
            }
            Spacer(minLength: 2)
            Button {
                model.applyRouteSuggestion()
            } label: {
                Text("Apply")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(Palette.paper)
                    .padding(.horizontal, 10)
                    .frame(height: 25)
                    .background(Capsule().fill(Palette.ink))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Palette.limeSoft)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1)
        )
    }

    private let stopChipColors: [Color] = [Palette.mustard, Palette.pink, Palette.mint, Palette.periwinkle, Palette.lime, Palette.sky]

    private func stopRow(index: Int, stop: RouteStop, isDropTarget: Bool = false) -> some View {
        let selected = model.selectedStopID == stop.id
        let last = index == model.currentStops.count - 1
        let isDragging = draggingStopID == stop.id
        return HStack(spacing: 9) {
            Text(stop.time)
                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.ink3)
                .frame(width: 37, alignment: .leading)

            ZStack {
                Circle()
                    .fill(stopChipColors[index % stopChipColors.count])
                    .frame(width: 23, height: 23)
                Circle()
                    .strokeBorder(Palette.ink, lineWidth: 1.1)
                    .frame(width: 23, height: 23)
                Text("\(index + 1)")
                    .font(.system(size: 9.5, weight: .black))
                    .foregroundStyle(Palette.ink)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(model.say(stop.name))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                    if !model.tripEdit, let tag = stop.tag, !tag.isEmpty {
                        TagView(text: model.say(tag), style: stop.tagStyle)
                    }
                }
                Text(model.say(stop.duration) + (last ? "" : " · " + model.say("8 min walk")))
                    .font(.system(size: 8.6, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            if model.tripEdit {
                dragHandle(stop: stop, index: index)
            } else {
                Image(systemName: selected ? "arrow.up.right" : "line.3.horizontal")
                    .font(.system(size: selected ? 9 : 10, weight: .bold))
                    .foregroundStyle(selected ? Palette.ink : Palette.ink3.opacity(0.6))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    selected ? Palette.limeSoft
                        : (isDragging ? Palette.paper : (isDropTarget ? Palette.limeSoft.opacity(0.7) : Color.clear))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(selected ? Palette.ink.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    Palette.accent,
                    style: StrokeStyle(lineWidth: 1.4, dash: [4, 3])
                )
                .opacity(isDropTarget ? 1 : 0)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard !model.tripEdit else { return }
            Haptics.tap()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
                model.selectedStopID = selected ? nil : stop.id
            }
        }
    }

    private func dragHandle(stop: RouteStop, index: Int) -> some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(Palette.ink)
            .frame(width: 30, height: 27)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(draggingStopID == stop.id ? Palette.lime : Palette.paper)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Palette.ink.opacity(0.7), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .gesture(stopDragGesture(stop: stop, index: index))
            .accessibilityLabel("Drag to reorder")
    }

    private var dragSourceIndex: Int? {
        guard let id = draggingStopID else { return nil }
        return model.currentStops.firstIndex(where: { $0.id == id })
    }

    private func dropIndex(at y: CGFloat, excluding id: UUID) -> Int {
        var index = 0
        for stop in model.currentStops where stop.id != id {
            guard let frame = stopFrames[stop.id] else { continue }
            if y > frame.midY { index += 1 }
        }
        return min(index, max(0, model.currentStops.count - 1))
    }

    private func stopDragGesture(stop: RouteStop, index: Int) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named("tripStops"))
            .onChanged { value in
                if draggingStopID != stop.id {
                    draggingStopID = stop.id
                    Haptics.tap()
                }
                stopDragOffset = value.translation.height
                let target = stopFrames.isEmpty ? index : dropIndex(at: value.location.y, excluding: stop.id)
                if target != stopDropTarget {
                    stopDropTarget = target
                    if target != index { Haptics.tap() }
                }
            }
            .onEnded { _ in
                let target = stopDropTarget
                let id = draggingStopID
                withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                    draggingStopID = nil
                    stopDragOffset = 0
                    stopDropTarget = nil
                }
                guard let target, let id else { return }
                let source = model.currentStops.firstIndex(where: { $0.id == id }) ?? index
                guard target != source else { return }
                model.moveTripStopToIndex(id, to: target)
            }
    }

    private func metaText(_ day: TripDay) -> String {
        var parts = day.meta.components(separatedBy: " · ")
        guard !parts.isEmpty else { return day.meta }
        parts[0] = "\(model.currentStops.count) stops"
        return model.tripMeta(parts.joined(separator: " · "))
    }

    // MARK: CTA

    private var tripCTA: some View {
        let saved = model.tripSaved && !model.tripDirty
        return HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(saved ? Palette.ok : (model.tripDirty ? Palette.warn : Palette.ink3))
                        .frame(width: 6, height: 6)
                    Text(model.tripSaved ? (model.tripDirty ? "Unsaved changes" : "Plan saved") : "Draft plan")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                Text("\(model.currentStops.count) stops · Day \(model.tripDay + 1) of \(planDayCount)")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            Spacer(minLength: 4)

            Button {
                if saved {
                    model.startTrip()
                } else {
                    model.saveTripPlan()
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: saved ? "figure.walk" : "checkmark")
                        .font(.system(size: 10, weight: .black))
                    Text(saved ? "Start trip" : "Save plan")
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundStyle(saved ? Palette.ink : Palette.paper)
                .padding(.horizontal, 15)
                .frame(height: 42)
                .background(Capsule().fill(saved ? Palette.lime : Palette.ink))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 2.5)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 23, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.3)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.08), radius: 22, x: 0, y: 10)
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: saved)
    }

    // MARK: Your days

    @ViewBuilder
    private func daysSection(scrollToRoute: @escaping () -> Void) -> some View {
        if model.planBuilt, !model.tripDays.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                SectionHeading(title: "Your days", icon: "calendar", trailing: "\(planDayCount) days")

                VStack(spacing: 7) {
                    ForEach(Array(model.tripDays.enumerated()), id: \.element.id) { index, day in
                        dayRow(day, index: index) {
                            model.selectTripDay(index)
                            scrollToRoute()
                        }
                    }
                }
            }
        }
    }

    private func dayRow(_ day: TripDay, index: Int, action: @escaping () -> Void) -> some View {
        let active = model.tripDay == index
        return Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 10) {
                VStack(spacing: 1) {
                    Text(day.date)
                        .font(.system(size: 14, weight: .black))
                        .tracking(-0.4)
                        .foregroundStyle(Palette.ink)
                    Text(model.weekLabel(day.week))
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                .frame(width: 44)
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Palette.ink.opacity(0.15))
                        .frame(width: 1, height: 30)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(model.lang == .zh ? String(format: "第 %02d 天", day.day) : String(format: "DAY %02d", day.day))
                            .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                            .tracking(0.8)
                            .foregroundStyle(Palette.ink3)
                        TagView(text: model.say(index == 0 ? "Today" : day.tag), style: day.tagStyle)
                    }
                    Text(model.say(day.title))
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                    Text(model.tripMeta("\(day.stops.count) stops · \(day.meta.components(separatedBy: " · ").dropFirst().joined(separator: " · "))"))
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: active ? "checkmark" : "chevron.right")
                    .font(.system(size: 8.5, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 25, height: 25)
                    .background(Circle().fill(active ? Palette.lime : Palette.paperWarm))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(active ? Palette.limeSoft : Palette.paper))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Palette.ink, lineWidth: active ? 1.4 : 1.1)
            )
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.09), radius: 0, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.99))
    }

    // MARK: Travel style check

    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "Travel style check", icon: "sparkles", trailing: "\(model.quizAnswered) / 3")

            VStack(alignment: .leading, spacing: 11) {
                HStack(spacing: 8) {
                    TagView(text: "Trip match", style: .accent)
                    Spacer()
                    if model.quizPersona == nil {
                        Text("Answer all three for your title")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    } else {
                        Button {
                            resetQuiz()
                        } label: {
                            HStack(spacing: 3) {
                                Text("Retake")
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 6, weight: .black))
                            }
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink2)
                            .padding(.horizontal, 8)
                            .frame(height: 23)
                            .background(Capsule().fill(Palette.paper))
                            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.35), lineWidth: 0.9))
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.95))
                    }
                }

                if let persona = model.quizPersona {
                    personaBanner(persona)
                        .transition(.opacity)
                } else {
                    quizQuestion("How many days do you like?", options: ["2–3 days", "4–5 days", "6+ days", "Surprise me"], selection: $model.quizDays)
                    quizQuestion("Your kind of holiday", options: ["Slow culture", "Food first", "Outdoors", "Night owl", "Family friendly", "Budget smart"], selection: $model.quizStyle)
                    quizQuestion("A theme, or none?", options: ["Imperial history", "Hutongs & coffee", "Art & design", "Nature & parks", "Night markets", "No theme"], selection: $model.quizTheme)

                    QuizNoteBox(text: $model.quizNote, compact: true)

                    HStack(spacing: 5) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 9, weight: .bold))
                        Text("Pick one per question — it only changes your suggestion, never the plan.")
                            .font(.system(size: 9, weight: .medium))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .foregroundStyle(Palette.ink3)
                }
            }
            .padding(13)
            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Palette.ink, lineWidth: 1.2)
            )
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        }
    }

    private func personaBanner(_ persona: TravelPersona) -> some View {
        HStack(spacing: 9) {
            Image(systemName: persona.icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Palette.lime))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            VStack(alignment: .leading, spacing: 1) {
                Text("YOUR TRAVEL TITLE")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(Palette.ink3)
                Text(LocalizedStringKey(persona.title))
                    .font(.system(size: 13, weight: .black))
                    .tracking(-0.2)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(persona.meta)
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
                if !persona.note.isEmpty {
                    Text(verbatim: "“\(persona.note)”")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 4)
            if model.planBuilt {
                Button {
                    Haptics.tap()
                    model.openAssistant("Trip · Adjust the plan")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 8, weight: .black))
                        Text("Adjust")
                            .font(.system(size: 9.5, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .padding(.horizontal, 10)
                    .frame(height: 29)
                    .background(Capsule().fill(Palette.ink))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.95))
            } else {
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        model.tab = .plan
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "map")
                            .font(.system(size: 8, weight: .black))
                        Text(persona.fit)
                            .font(.system(size: 9.5, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .padding(.horizontal, 10)
                    .frame(height: 29)
                    .background(Capsule().fill(Palette.ink))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.95))
            }
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.paperWarm))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Palette.ink.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        )
        .id("quiz-result")
    }

    private func resetQuiz() {
        Haptics.tap()
        withAnimation(.easeOut(duration: 0.2)) {
            model.quizDays = nil
            model.quizStyle = nil
            model.quizTheme = nil
            model.quizNote = ""
        }
    }

    private func quizQuestion(_ label: String, options: [String], selection: Binding<String?>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Palette.ink)
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 5),
                    count: options.count <= 4 ? 2 : 3
                ),
                spacing: 5
            ) {
                ForEach(options, id: \.self) { option in
                    let on = selection.wrappedValue == option
                    Button {
                        Haptics.tap()
                        withAnimation(.easeOut(duration: 0.18)) {
                            selection.wrappedValue = option
                        }
                    } label: {
                        Text(option)
                            .font(.system(size: 9.5, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                            .padding(.horizontal, 6)
                            .frame(maxWidth: .infinity)
                            .frame(height: 28)
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
    }
}

// MARK: - Live trip

private struct TripStopFrameKey: PreferenceKey {
    static var defaultValue: [UUID: CGRect] = [:]
    static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

private struct LiveTripView: View {
    @EnvironmentObject private var model: AppModel

    private var stops: [RouteStop] { model.currentStops }
    private var day: TripDay? { model.currentTripDay }
    private var visited: Int { min(model.liveStop, stops.count) }
    private var done: Bool { model.liveStop >= stops.count }
    private var current: RouteStop? {
        guard !done, stops.indices.contains(model.liveStop) else { return nil }
        return stops[model.liveStop]
    }
    private var next: RouteStop? {
        guard !done, stops.indices.contains(model.liveStop + 1) else { return nil }
        return stops[model.liveStop + 1]
    }
    private var progress: Double {
        stops.isEmpty ? 0 : Double(visited) / Double(stops.count)
    }
    private var walked: String {
        String(format: "%.1f", Double(visited) * 0.7)
    }
    private var finishTime: String {
        AppModel.plusMinutes(stops.last?.time ?? "17:30", 60)
    }
    private var clock: String {
        if let current { return model.liveClock(current) }
        if let last = stops.last { return AppModel.plusMinutes(last.time, 30) }
        return "15:42"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    summaryCard
                    mapCard
                    if let current {
                        nowCard(current)
                        if let next {
                            nextCard(next)
                        } else {
                            lastStopCard
                        }
                    } else {
                        doneCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 190)
            }

            liveCTA
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    LiveDot()
                    Text("LIVE TRIP")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1.4)
                        .foregroundStyle(Palette.ink)
                    StickerLabel(text: "DAY \(String(format: "%02d", day?.day ?? 1))", fill: Palette.accentSoft, rotation: 2)
                }
                Text(day?.shortTitle ?? "Today's route")
                    .font(.system(size: 28, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("\(day?.date ?? model.tripStamp(0).date) \(model.weekLabel(day?.week ?? model.tripStamp(0).week)) · Day \(model.tripDay + 1) of \(model.tripDayCount) · 2 travelers")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 6)
            Button {
                model.endLiveTrip()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 8, weight: .black))
                    Text("End")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 11) {
            HStack(spacing: 12) {
                ProgressRingView(
                    progress: progress,
                    label: "\(visited)/\(stops.count)",
                    size: 62,
                    lineWidth: 5,
                    tint: done ? Palette.ok : Palette.accent
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(done ? "Day complete" : "On the move")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                    Text("\(visited) of \(stops.count) stops done")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                    Text("\(walked) km walked · finished ~\(finishTime)")
                        .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }

                Spacer(minLength: 2)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(clock)
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundStyle(Palette.ink)
                    Text("BEIJING TIME")
                        .font(.system(size: 6.8, weight: .bold, design: .monospaced))
                        .tracking(0.6)
                        .foregroundStyle(Palette.ink3)
                }
            }

            LinearProgressBar(progress: progress, height: 6, tint: done ? Palette.ok : Palette.accent)

            HStack(spacing: 5) {
                Image(systemName: done ? "checkmark.circle.fill" : "location.fill")
                    .font(.system(size: 8.5, weight: .bold))
                Text(done ? "Every stop on this day is covered" : "You are here · \(current?.name ?? "")")
                    .font(.system(size: 9.5, weight: .bold))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text("GPS · 12 m")
                    .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 9)
            .frame(height: 27)
            .background(Capsule().fill(Palette.limeSoft))
            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.55), lineWidth: 1))
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.13), radius: 0, x: 0, y: 3)
    }

    private var mapCard: some View {
        VStack(spacing: 0) {
            TripRouteMap(
                stops: stops,
                editing: false,
                selectedID: nil,
                liveStop: model.liveStop,
                lang: model.lang,
                onTap: { stop in
                    Haptics.tap()
                    model.openAssistant("Trip · \(stop.name)")
                }
            )
            .frame(height: 206)

            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Palette.accent)
                Text(coordinateText)
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                Spacer(minLength: 4)
                Text(model.lang == .zh ? "\(stops.count) 个点 · 中轴线" : "\(stops.count) pins · Central Axis")
                    .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
            .padding(.horizontal, 11)
            .frame(height: 30)
            .background(Palette.paperWarm)
        }
        .background(Palette.paper)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.13), radius: 0, x: 0, y: 3)
    }

    private var coordinateText: String {
        if let current { return model.liveCoordinate(current) }
        if let last = stops.last { return model.liveCoordinate(last) }
        return "39.9163° N, 116.3972° E"
    }

    private func nowCard(_ stop: RouteStop) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                TagView(text: "NOW · \(model.liveClock(stop))", style: .accent)
                Spacer()
                Text("STOP \(model.liveStop + 1) OF \(stops.count)")
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .tracking(0.7)
                    .foregroundStyle(Palette.ink3)
            }

            Text(model.say(stop.name))
                .font(.system(size: 21, weight: .black))
                .tracking(-0.4)
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text("\(model.say(stop.duration)) · \(model.say("next leg 6 min walk"))")
                .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink2)

            HStack(spacing: 6) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Palette.accent)
                Text(model.liveCoordinate(stop))
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                Spacer(minLength: 4)
                TagView(text: model.say("Open now"), style: .ok)
            }

            HStack(spacing: 6) {
                Button {
                    Haptics.tap()
                    model.openAssistant("Trip · \(stop.name)")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 8.5, weight: .bold))
                        Text("Ask Pico")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Capsule().fill(Palette.ink))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    Haptics.tap()
                    model.toast("Walking route opened · 6 min", icon: "map.fill")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            .font(.system(size: 8.5, weight: .bold))
                        Text("Navigate")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.13), radius: 0, x: 0, y: 3)
    }

    private func nextCard(_ stop: RouteStop) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("UP NEXT · 6 MIN")
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(Palette.ink3)
                Text(model.say(stop.name))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text("\(stop.time) · \(model.say(stop.duration))")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 4)
            HStack(spacing: 4) {
                Text("\(model.liveStop + 2)")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                Image(systemName: "arrow.right")
                    .font(.system(size: 8.5, weight: .black))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Capsule().fill(Palette.paper))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paperWarm))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.ink.opacity(0.5), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3]))
        )
    }

    private var lastStopCard: some View {
        HStack(spacing: 8) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Palette.lime))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            VStack(alignment: .leading, spacing: 1) {
                Text("LAST STOP")
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(Palette.ink3)
                Text("Finish here, then wrap the day")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette.ink)
            }
            Spacer()
        }
        .padding(11)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.ink.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
    }

    private var doneCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Palette.ok)
                Text(model.tripDay < model.tripDayCount - 1 ? "Day complete" : "Trip complete")
                    .font(.system(size: 20, weight: .black))
                    .tracking(-0.3)
                    .foregroundStyle(Palette.ink)
                Spacer()
            }
            Text(model.tripDay < model.tripDayCount - 1
                 ? "Every stop on this day is checked off. Load tomorrow's route, or end the live trip and keep the saved plan."
                 : "Every stop is checked off. Wrap up the journey and see your Beijing recap.")
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 5) {
                TagView(text: "\(stops.count) stops", style: .ok)
                TagView(text: "\(walked) km walked", style: .soft)
                TagView(text: "~\(finishTime) finish", style: .soft)
                Spacer()
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.limeSoft))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
    }

    private var liveCTA: some View {
        HStack(spacing: 9) {
            Button {
                model.endLiveTrip()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 42)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("End live trip")

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(done ? Palette.ok : Palette.accent)
                        .frame(width: 6, height: 6)
                    Text(done ? "Day complete" : "Live · Day \(model.tripDay + 1) of \(model.tripDayCount)")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                }
                Text(done ? "Every stop covered" : "Next: \(next?.name ?? "finish line")")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            Button {
                if done {
                    model.finishLiveDay()
                } else {
                    model.advanceLiveStop()
                }
            } label: {
                HStack(spacing: 4) {
                    Text(done ? (model.tripDay < model.tripDayCount - 1 ? "Next day" : "Trip wrap-up") : "Next stop")
                        .font(.system(size: 11.5, weight: .bold))
                    Image(systemName: done ? (model.tripDay < model.tripDayCount - 1 ? "map" : "sparkles") : "arrow.right")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 13)
                .frame(height: 42)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 2.5)
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 23, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.3)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.08), radius: 22, x: 0, y: 10)
    }
}

private struct LiveDot: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Palette.accent.opacity(0.28))
                .frame(width: 15, height: 15)
                .scaleEffect(pulse ? 1.25 : 0.7)
                .opacity(pulse ? 0.15 : 1)
            Circle()
                .fill(Palette.accent)
                .frame(width: 7, height: 7)
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.3).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
    }
}

// MARK: - Compact route map

private struct TripRouteMap: View {
    var stops: [RouteStop]
    var editing: Bool
    var selectedID: UUID?
    var liveStop: Int?
    var lang: AppLanguage = .en
    var onTap: (RouteStop) -> Void = { _ in }
    var onMove: (UUID, CGFloat, CGFloat) -> Void = { _, _, _ in }
    var onMoveEnd: () -> Void = {}

    @State private var dragID: UUID?
    @State private var dragOrigin: CGPoint?
    @State private var pulse = false

    private let pad: CGFloat = 18

    private var currentIndex: Int? {
        guard let live = liveStop, stops.indices.contains(live) else { return nil }
        return live
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let content = CGRect(
                x: pad,
                y: pad,
                width: max(1, size.width - pad * 2),
                height: max(1, size.height - pad * 2)
            )

            ZStack {
                Canvas { context, canvasSize in
                    drawBase(&context, size: canvasSize, content: content)
                }

                ForEach(Array(stops.enumerated()), id: \.element.id) { index, stop in
                    mapPin(index: index, stop: stop, content: content)
                        .position(
                            x: content.minX + content.width * stop.x,
                            y: content.minY + content.height * stop.y
                        )
                        .zIndex(dragID == stop.id ? 6 : (currentIndex == index ? 4 : (selectedID == stop.id ? 3 : 1)))
                }

                if currentIndex != nil {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Palette.paper)
                            .frame(width: 4.5, height: 4.5)
                            .opacity(pulse ? 1 : 0.35)
                        Text("YOU ARE HERE")
                            .font(.system(size: 6.8, weight: .black, design: .monospaced))
                            .tracking(0.4)
                            .foregroundStyle(Palette.paper)
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .padding(.horizontal, 7)
                    .frame(height: 18)
                    .background(Capsule().fill(Palette.accent))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 0.9))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(8)
                    .zIndex(10)
                    .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    @ViewBuilder
    private func mapPin(index: Int, stop: RouteStop, content: CGRect) -> some View {
        if editing {
            pinBody(index: index, stop: stop)
                .gesture(dragGesture(for: stop, in: content))
        } else {
            Button {
                onTap(stop)
            } label: {
                pinBody(index: index, stop: stop)
            }
            .buttonStyle(.plain)
        }
    }

    private func pinBody(index: Int, stop: RouteStop) -> some View {
        let selected = selectedID == stop.id
        let isDone = liveStop.map { index < $0 } ?? false
        let isNow = liveStop.map { index == $0 } ?? false
        let diameter: CGFloat = isNow ? 29 : (selected ? 28 : 23)

        return VStack(spacing: 3) {
            ZStack {
                if isNow {
                    Circle()
                        .strokeBorder(Palette.accent.opacity(0.45), lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .scaleEffect(pulse ? 1.12 : 0.85)
                        .opacity(pulse ? 0.18 : 0.85)
                }
                if editing {
                    Circle()
                        .strokeBorder(Palette.accent.opacity(0.9), style: StrokeStyle(lineWidth: 1.3, dash: [3, 3]))
                        .frame(width: 41, height: 41)
                }

                Circle()
                    .fill(fillColor(isDone: isDone, isNow: isNow, selected: selected))
                    .frame(width: diameter, height: diameter)
                Circle()
                    .strokeBorder(Palette.ink, lineWidth: isNow ? 2 : 1.2)
                    .frame(width: diameter, height: diameter)

                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Palette.ink)
                } else {
                    Text("\(index + 1)")
                        .font(.system(size: isNow ? 10 : 8.5, weight: .black))
                        .foregroundStyle(textColor(isNow: isNow, selected: selected))
                }

                if editing {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.system(size: 5, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 14, height: 14)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
                        .offset(x: 15, y: 13)
                }
            }
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 2)

            if selected && liveStop == nil && !editing {
                Text(L10n.text(stop.name, lang))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 0.9))
                    .fixedSize()
            }
        }
        .contentShape(Rectangle())
    }

    private func fillColor(isDone: Bool, isNow: Bool, selected: Bool) -> Color {
        if isNow { return Palette.accent }
        if isDone { return Palette.lime }
        if selected { return Palette.ink }
        return Palette.paper
    }

    private func textColor(isNow: Bool, selected: Bool) -> Color {
        if isNow { return Palette.paper }
        if selected { return Palette.lime }
        return Palette.ink
    }

    private func dragGesture(for stop: RouteStop, in content: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard editing else { return }
                if dragID != stop.id {
                    dragID = stop.id
                    dragOrigin = CGPoint(x: stop.x, y: stop.y)
                    Haptics.tap()
                }
                guard let origin = dragOrigin, content.width > 0, content.height > 0 else { return }
                onMove(
                    stop.id,
                    origin.x + value.translation.width / content.width,
                    origin.y + value.translation.height / content.height
                )
            }
            .onEnded { _ in
                guard dragID == stop.id else { return }
                dragID = nil
                dragOrigin = nil
                onMoveEnd()
            }
    }

    private func drawBase(_ context: inout GraphicsContext, size: CGSize, content: CGRect) {
        let w = size.width
        let h = size.height

        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.paper))

        for row in 0..<7 {
            for col in 0..<4 {
                let block = CGRect(
                    x: CGFloat(col) * (w / 4) + 5,
                    y: CGFloat(row) * (h / 7) + 6,
                    width: w / 4 - 10,
                    height: h / 7 - 12
                )
                let rounded = Path(roundedRect: block, cornerRadius: 5)
                context.fill(rounded, with: .color(Palette.cream.opacity(0.32)))
                context.stroke(rounded, with: .color(Palette.lineSoft.opacity(0.75)), lineWidth: 0.6)
            }
        }

        let parkA = Path(roundedRect: CGRect(x: w * 0.02, y: h * 0.06, width: w * 0.30, height: h * 0.26), cornerRadius: 18)
        context.fill(parkA, with: .color(Palette.mint.opacity(0.8)))
        context.stroke(parkA, with: .color(Palette.ink.opacity(0.5)), lineWidth: 0.9)

        let lake = Path(roundedRect: CGRect(x: w * 0.06, y: h * 0.10, width: w * 0.16, height: h * 0.10), cornerRadius: 12)
        context.fill(lake, with: .color(Palette.sky))
        context.stroke(lake, with: .color(Palette.ink.opacity(0.5)), lineWidth: 0.9)

        let parkB = Path(roundedRect: CGRect(x: w * 0.66, y: h * 0.60, width: w * 0.30, height: h * 0.28), cornerRadius: 16)
        context.fill(parkB, with: .color(Palette.limeSoft))
        context.stroke(parkB, with: .color(Palette.ink.opacity(0.45)), lineWidth: 0.9)

        for index in 0..<6 {
            let treeX = w * (0.07 + CGFloat(index % 3) * 0.055)
            let treeY = h * (0.13 + CGFloat(index / 3) * 0.06)
            let tree = Path(ellipseIn: CGRect(x: treeX, y: treeY, width: 5.5, height: 5.5))
            context.fill(tree, with: .color(Palette.olive))
        }

        var roads = Path()
        roads.move(to: CGPoint(x: w * 0.42, y: 0))
        roads.addLine(to: CGPoint(x: w * 0.56, y: h))
        roads.move(to: CGPoint(x: 0, y: h * 0.52))
        roads.addLine(to: CGPoint(x: w, y: h * 0.44))
        roads.move(to: CGPoint(x: 0, y: h * 0.20))
        roads.addLine(to: CGPoint(x: w, y: h * 0.30))
        context.stroke(roads, with: .color(Palette.cream), style: StrokeStyle(lineWidth: 8, lineCap: .round))
        context.stroke(roads, with: .color(Palette.line.opacity(0.8)), style: StrokeStyle(lineWidth: 0.9, lineCap: .round))

        let labels: [(String, CGPoint)] = [
            ("Shichahai", CGPoint(x: content.minX + content.width * 0.18, y: content.minY + content.height * 0.18)),
            ("Forbidden City", CGPoint(x: content.minX + content.width * 0.70, y: content.minY + content.height * 0.66)),
            ("Jingshan", CGPoint(x: content.minX + content.width * 0.74, y: content.minY + content.height * 0.48))
        ]
        for label in labels {
            context.draw(
                Text(L10n.text(label.0, lang))
                    .font(.system(size: 6.8, weight: .bold))
                    .foregroundColor(Palette.ink3.opacity(0.8)),
                at: label.1,
                anchor: .center
            )
        }

        guard stops.count > 1 else { return }
        let points = stops.map {
            CGPoint(x: content.minX + content.width * $0.x, y: content.minY + content.height * $0.y)
        }

        if let live = liveStop {
            let full = routePath(points)
            context.stroke(full, with: .color(Palette.ink.opacity(0.32)), style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round, dash: [4, 4]))

            let doneCount = min(live + 1, points.count)
            if doneCount > 1 {
                let donePath = routePath(Array(points.prefix(doneCount)))
                context.stroke(donePath, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round))
                context.stroke(donePath, with: .color(Palette.accent), style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
            }
        } else {
            let route = routePath(points)
            context.stroke(route, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
            context.stroke(route, with: .color(Palette.accent), style: StrokeStyle(lineWidth: 2.8, lineCap: .round, lineJoin: .round))
        }
    }

    private func routePath(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        guard points.count > 1 else { return path }
        for index in 1..<points.count {
            let mid = CGPoint(
                x: (points[index - 1].x + points[index].x) / 2,
                y: (points[index - 1].y + points[index].y) / 2
            )
            path.addQuadCurve(to: mid, control: points[index - 1])
        }
        if let last = points.last {
            path.addLine(to: last)
        }
        return path
    }
}

// MARK: - Add stop

private struct AddStopSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Eyebrow(text: "ROUTE · DAY \(String(format: "%02d", model.tripDay + 1))")
                        Text("Add a stop")
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.5)
                            .foregroundStyle(Palette.ink)
                        Text("Pico picks near this day. New stops slot in after the last one and walking times recalculate.")
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
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

                if model.availableTripSuggestions.isEmpty {
                    Text("Every nearby pick is already on this day.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.ink.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
                } else {
                    VStack(spacing: 8) {
                        ForEach(model.availableTripSuggestions) { suggestion in
                            Button {
                                dismiss()
                                Task { @MainActor in
                                    try? await Task.sleep(for: .milliseconds(320))
                                    model.addTripStop(suggestion)
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Palette.ink)
                                        .frame(width: 34, height: 34)
                                        .background(Circle().fill(Palette.lime))
                                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(model.say(suggestion.name))
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(Palette.ink)
                                        Text(model.say(suggestion.meta))
                                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                                            .foregroundStyle(Palette.ink3)
                                    }
                                    Spacer(minLength: 4)
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(Palette.ink)
                                        .frame(width: 26, height: 26)
                                        .background(Circle().fill(Palette.paperWarm))
                                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                                }
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                                .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
                            }
                            .buttonStyle(PressableButtonStyle(scale: 0.99))
                        }
                    }
                }

                Text("Added stops mark the plan as unsaved — save again before you start.")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Palette.bg.ignoresSafeArea())
    }
}

// MARK: - Trip dates

struct TripDatesSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Date

    init(start: Date) {
        _draft = State(initialValue: start)
    }

    private var dayCount: Int { max(1, model.tripDayCount) }
    private var isMonday: Bool { model.tripStamp(0, from: draft).week == "Mon" }

    private var rangeLine: String {
        let nights = dayCount - 1
        return "\(model.tripDateRange(count: dayCount, from: draft)) · \(nights) \(model.lang == .zh ? "晚" : "nights")"
    }

    private var previewRows: [(index: Int, date: String, week: String)] {
        (0..<min(dayCount, 6)).map { index in
            let stamp = model.tripStamp(index, from: draft)
            return (index, stamp.date, model.weekLabel(stamp.week))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    header

                    Text("Pick the day you arrive — every day, weekday and booking reminder follows.")
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)

                    dateField

                    HStack(spacing: 7) {
                        nudge("−1 day", days: -1)
                        nudge("+1 day", days: 1)
                        nudge("+1 week", days: 7)
                    }

                    if isMonday {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Palette.accent)
                            Text("The Forbidden City is closed on Mondays — this start makes Day 1 a Monday.")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundStyle(Palette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Palette.accentSoft))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Palette.accent, lineWidth: 1))
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text(model.lang == .zh ? "行程共 \(dayCount) 天" : "\(dayCount) days on the trip")
                            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                            .tracking(0.6)
                            .foregroundStyle(Palette.ink3)
                        Spacer()
                        Text(rangeLine)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink2)
                    }
                    .padding(.top, 2)

                    VStack(spacing: 0) {
                        ForEach(previewRows, id: \.index) { row in
                            HStack(spacing: 8) {
                                Text(model.lang == .zh ? "第 \(row.index + 1) 天" : "Day \(row.index + 1)")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Palette.ink2)
                                    .frame(width: 52, alignment: .leading)
                                Text(row.date)
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(Palette.ink)
                                Spacer()
                                Text(row.week)
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(Palette.ink3)
                            }
                            .padding(.horizontal, 11)
                            .frame(height: 34)
                            .background(row.index == 0 ? Palette.lime.opacity(0.55) : Color.clear)
                            if row.index != previewRows.count - 1 {
                                Rectangle()
                                    .fill(Palette.ink.opacity(0.08))
                                    .frame(height: 0.8)
                                    .padding(.leading, 11)
                            }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.ink.opacity(0.35), lineWidth: 1))

                    Text("Times stay the same · booked tickets keep their entry slots.")
                        .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                        .padding(.bottom, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 10)
            }

            HStack(spacing: 8) {
                Button {
                    Haptics.tap()
                    withAnimation(.easeInOut(duration: 0.18)) {
                        draft = AppModel.defaultTripStart
                    }
                } label: {
                    Text("Reset")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    let changed = !AppModel.tripCalendar.isDate(draft, inSameDayAs: model.tripStartDate)
                    model.setTripStart(draft)
                    dismiss()
                    if !changed {
                        model.toast(model.lang == .zh ? "日期没有变化" : "Dates unchanged", icon: "info.circle")
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                        Text("Save dates")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Capsule().fill(Palette.ink))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 14)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "TRIP · ADJUST THE START")
                Text("Trip dates")
                    .font(.system(size: 28, weight: .black))
                    .tracking(-0.5)
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
    }

    private var dateField: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Palette.lime))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))

            VStack(alignment: .leading, spacing: 1) {
                Text("Start date")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.5)
                    .foregroundStyle(Palette.ink3)
                DatePicker("", selection: $draft, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .environment(\.locale, model.lang.locale)
            }

            Spacer(minLength: 4)

            Text(model.weekLabel(model.tripStamp(0, from: draft).week))
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 9)
                .frame(height: 24)
                .background(Capsule().fill(Palette.paperWarm))
                .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.4), lineWidth: 1))
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
    }

    private func nudge(_ label: String, days: Int) -> some View {
        Button {
            Haptics.tap()
            if let next = AppModel.tripCalendar.date(byAdding: .day, value: days, to: draft) {
                withAnimation(.easeInOut(duration: 0.18)) {
                    draft = next
                }
            }
        } label: {
            Text(L10n.text(label, model.lang))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .background(Capsule().fill(Palette.paperWarm))
                .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.55), style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
        }
        .buttonStyle(PressableButtonStyle(scale: 0.97))
    }
}
