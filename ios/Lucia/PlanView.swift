import SwiftUI

struct PlanView: View {
    @EnvironmentObject private var model: AppModel
    @State private var showReorder = false
    @State private var showSimilar = false

    var body: some View {
        ZStack {
            BeijingMap()
                .ignoresSafeArea()

            LinearGradient(
                colors: [Palette.bg, Palette.bg.opacity(0.92), Palette.bg.opacity(0.5), Palette.bg.opacity(0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 250)
            .frame(maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                header
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            VStack(spacing: 0) {
                Spacer()
                panel
            }
        }
        .sheet(isPresented: $showReorder) {
            ReorderSheet()
                .environmentObject(model)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $showSimilar) {
            SimilarRoutesSheet()
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .onAppear {
            if model.pendingSimilar {
                model.pendingSimilar = false
                showSimilar = true
            }
        }
        .onChange(of: model.pendingSimilar) { _, pending in
            guard pending else { return }
            model.pendingSimilar = false
            showSimilar = true
        }
        #if DEBUG
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-reorder") {
                showReorder = true
            }
            if args.contains("-similar") {
                showSimilar = true
            }
        }
        #endif
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Eyebrow(text: "MY PLAN / CITYWALK")
                        StickerLabel(text: "DAY 02", fill: Palette.lime, rotation: 3)
                    }
                    Text(model.routeName)
                        .font(.system(size: 29, weight: .black))
                        .tracking(-0.6)
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text("\(model.stops.count) stops · 4.2 km · ~5 hr")
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Button {
                        Haptics.tap()
                        model.notesOpen = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.image")
                                .font(.system(size: 9, weight: .bold))
                            Text("Make a note")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 11)
                        .frame(height: 31)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                        .compositingGroup()
                        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 2)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96))
                    .accessibilityLabel("Generate trip note")

                    HStack(spacing: 6) {
                        AvatarStack(names: ["L", "Z"], size: 27)
                        IconCircleButton(icon: "square.and.arrow.up", size: 31) {
                            model.shareRoute()
                        }
                    }
                }
                .padding(.top, 1)
            }

            HStack(spacing: 6) {
                ForEach(MapLayer.allCases) { layer in
                    Chip(title: layer.title, selected: model.layer == layer) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            model.layer = layer
                        }
                    }
                }
                Spacer(minLength: 4)
                if model.mapEditMode {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 8.5, weight: .bold))
                        Text("Drag stops")
                            .font(.system(size: 9.5, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 30)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
            }
        }
    }

    // MARK: Bottom panel

    private var panel: some View {
        VStack(spacing: 10) {
            Capsule()
                .fill(Palette.ink.opacity(0.35))
                .frame(width: 38, height: 4)
                .padding(.top, 9)

            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(model.stops.count) stops · 4.2 km")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                    if model.mapEditMode {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 8, weight: .bold))
                            Text("Drag pins · route recalculates")
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        }
                        .foregroundStyle(Palette.accent)
                    } else {
                        Text("~5 hr · Walk + subway")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }
                }
                Spacer()
                HStack(spacing: 6) {
                    Button {
                        model.toggleMapEditMode()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: model.mapEditMode ? "checkmark" : "hand.draw")
                                .font(.system(size: 9, weight: .bold))
                            Text(model.mapEditMode ? "Done" : "Edit pins")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 31)
                        .background(Capsule().fill(model.mapEditMode ? Palette.lime : Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                        .compositingGroup()
                        .shadow(color: model.mapEditMode ? Palette.ink.opacity(0.14) : .clear, radius: 0, x: 0, y: 2)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96))

                    Button {
                        showReorder = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 9, weight: .bold))
                            Text("Reorder")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 31)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96))
                }
            }
            .padding(.horizontal, 16)

            if model.aiSuggestionVisible && !model.mapEditMode {
                HStack(spacing: 7) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 23, height: 23)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.9))
                    Text("Pico: move Shichahai to 13:00")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                    Text("1.2 km less")
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                        .lineLimit(1)
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
                .padding(.horizontal, 9)
                .frame(height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(Palette.limeSoft)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(Palette.ink, lineWidth: 1.1)
                )
                .padding(.horizontal, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 3) {
                    ForEach(model.stops.indices, id: \.self) { index in
                        stopRow(index: index, stop: model.stops[index])
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: model.mapEditMode ? 174 : 116)
            .overlay(alignment: .bottom) {
                LinearGradient(
                    colors: [Palette.paper.opacity(0), Palette.paper],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 22)
                .allowsHitTesting(false)
            }

            HStack(spacing: 6) {
                Button {
                    model.openAssistant("Plan · Add a stop")
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 9.5, weight: .bold))
                        Text("Add a stop")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Capsule().fill(Palette.paperWarm))
                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.65), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3])))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    Haptics.tap()
                    showSimilar = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.system(size: 9.5, weight: .bold))
                        Text("Similar routes")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
                }
                .buttonStyle(PressableButtonStyle())
                .accessibilityLabel("View similar routes")

            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 14)
        .background(RoundedRectangle(cornerRadius: 30, style: .continuous).fill(Palette.paper))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
        .shadow(color: Palette.ink.opacity(0.08), radius: 24, x: 0, y: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 84)
    }

    private var stopChipColors: [Color] {
        [Palette.mustard, Palette.pink, Palette.mint, Palette.periwinkle, Palette.lime, Palette.sky]
    }

    private func stopRow(index: Int, stop: RouteStop) -> some View {
        let selected = model.selectedStopID == stop.id
        return Button {
            model.selectStop(stop)
        } label: {
            HStack(spacing: 9) {
                Text(stop.time)
                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .frame(width: 36, alignment: .leading)

                ZStack {
                    Circle()
                        .fill(stopChipColors[index % stopChipColors.count])
                        .frame(width: 21, height: 21)
                    Circle()
                        .strokeBorder(Palette.ink, lineWidth: 1.1)
                        .frame(width: 21, height: 21)
                    Text("\(index + 1)")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(Palette.ink)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(model.say(stop.name))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        if let tag = stop.tag {
                            TagView(text: model.say(tag), style: stop.tagStyle)
                        }
                    }
                    Text(model.say(stop.duration) + " · " + model.say("6 min walk"))
                        .font(.system(size: 8.8, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                }

                Spacer(minLength: 4)

                Image(systemName: selected ? "arrow.up.right" : "line.3.horizontal")
                    .font(.system(size: selected ? 9 : 10, weight: .bold))
                    .foregroundStyle(selected ? Palette.ink : Palette.ink3.opacity(0.6))
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 7)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(selected ? Palette.limeSoft : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(selected ? Palette.ink.opacity(0.55) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Map

private struct BeijingMap: View {
    @EnvironmentObject private var model: AppModel
    @State private var dragOrigin: CGPoint?
    @State private var draggingStopID: UUID?

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let content = CGRect(
                x: 26,
                y: 158,
                width: size.width - 52,
                height: max(200, min(310, size.height * 0.27))
            )

            ZStack {
                Canvas { context, canvasSize in
                    drawBase(context: &context, size: canvasSize, content: content)
                }

                collaborator(name: "Lina", color: Palette.periwinkle,
                             point: CGPoint(x: content.minX + content.width * 0.74,
                                            y: content.minY + content.height * 0.34))
                collaborator(name: "Zhou", color: Palette.lime,
                             point: CGPoint(x: content.minX + content.width * 0.26,
                                            y: content.minY + content.height * 0.60))

                ForEach(Array(model.stops.enumerated()), id: \.element.id) { index, stop in
                    mapPin(index: index, stop: stop, content: content)
                        .position(
                            x: content.minX + content.width * stop.x,
                            y: content.minY + content.height * stop.y
                        )
                        .zIndex(draggingStopID == stop.id ? 6 : (model.selectedStopID == stop.id ? 3 : 1))
                }

                if model.mapEditMode {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("Drag numbered pins — the route recalculates")
                            .font(.system(size: 9.5, weight: .semibold))
                    }
                    .foregroundStyle(Palette.paper)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Capsule().fill(Palette.ink))
                    .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.2), lineWidth: 0.8))
                    .compositingGroup()
                    .shadow(color: Palette.ink.opacity(0.18), radius: 10, x: 0, y: 5)
                    .position(x: size.width / 2, y: content.maxY + 22)
                    .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
        }
    }

    @ViewBuilder
    private func mapPin(index: Int, stop: RouteStop, content: CGRect) -> some View {
        if model.mapEditMode {
            pinBody(index: index, stop: stop)
                .gesture(dragGesture(for: stop, in: content))
        } else {
            Button {
                model.selectStop(stop)
            } label: {
                pinBody(index: index, stop: stop)
            }
            .buttonStyle(.plain)
        }
    }

    private func dragGesture(for stop: RouteStop, in content: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard model.mapEditMode else { return }
                if draggingStopID != stop.id {
                    draggingStopID = stop.id
                    dragOrigin = CGPoint(x: stop.x, y: stop.y)
                    model.selectedStopID = stop.id
                    Haptics.tap()
                }
                guard let origin = dragOrigin, content.width > 0, content.height > 0 else { return }
                model.moveStop(
                    stop.id,
                    toX: origin.x + value.translation.width / content.width,
                    toY: origin.y + value.translation.height / content.height
                )
            }
            .onEnded { _ in
                guard draggingStopID == stop.id else { return }
                draggingStopID = nil
                dragOrigin = nil
                model.didFinishMovingStop()
            }
    }

    private func drawBase(context: inout GraphicsContext, size: CGSize, content: CGRect) {
        let w = size.width
        let h = size.height

        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.paper))

        // City blocks
        for row in 0..<10 {
            for col in 0..<5 {
                let bw = w / 5 - 15
                let bh = h / 10 - 20
                let rect = CGRect(x: CGFloat(col) * (w / 5) + 7.5, y: CGFloat(row) * (h / 10) + 10, width: bw, height: bh)
                let block = Path(roundedRect: rect, cornerRadius: 6)
                context.fill(block, with: .color(Palette.cream.opacity(0.34)))
                context.stroke(block, with: .color(Palette.lineSoft.opacity(0.8)), lineWidth: 0.7)
            }
        }

        // Shichahai park + lake
        let parkA = Path(roundedRect: CGRect(x: w * 0.012, y: h * 0.12, width: w * 0.36, height: h * 0.23), cornerRadius: 28)
        context.fill(parkA, with: .color(Palette.mint.opacity(0.8)))
        context.stroke(parkA, with: .color(Palette.ink.opacity(0.55)), lineWidth: 1)
        let lakeA = Path(roundedRect: CGRect(x: w * 0.06, y: h * 0.155, width: w * 0.21, height: h * 0.095), cornerRadius: 20)
        context.fill(lakeA, with: .color(Palette.sky))
        context.stroke(lakeA, with: .color(Palette.ink.opacity(0.55)), lineWidth: 1)

        // Jingshan / east park
        let parkB = Path(roundedRect: CGRect(x: w * 0.62, y: h * 0.59, width: w * 0.37, height: h * 0.22), cornerRadius: 26)
        context.fill(parkB, with: .color(Palette.limeSoft))
        context.stroke(parkB, with: .color(Palette.ink.opacity(0.5)), lineWidth: 1)

        for index in 0..<9 {
            let treeX = w * (0.055 + CGFloat(index % 4) * 0.062)
            let treeY = h * (0.165 + CGFloat(index / 4) * 0.052)
            let tree = Path(ellipseIn: CGRect(x: treeX, y: treeY, width: 7.5, height: 7.5))
            context.fill(tree, with: .color(Palette.olive))
            context.stroke(tree, with: .color(Palette.ink.opacity(0.75)), lineWidth: 0.8)
        }

        // Roads
        var roads = Path()
        roads.move(to: CGPoint(x: w * 0.48, y: 0))
        roads.addLine(to: CGPoint(x: w * 0.54, y: h))
        roads.move(to: CGPoint(x: 0, y: h * 0.56))
        roads.addLine(to: CGPoint(x: w, y: h * 0.48))
        roads.move(to: CGPoint(x: 0, y: h * 0.24))
        roads.addLine(to: CGPoint(x: w, y: h * 0.34))
        context.stroke(roads, with: .color(Palette.cream), style: StrokeStyle(lineWidth: 13, lineCap: .round))
        context.stroke(roads, with: .color(Palette.line.opacity(0.8)), style: StrokeStyle(lineWidth: 1, lineCap: .round))

        var minor = Path()
        minor.move(to: CGPoint(x: w * 0.18, y: 0))
        minor.addLine(to: CGPoint(x: w * 0.12, y: h))
        minor.move(to: CGPoint(x: w * 0.80, y: 0))
        minor.addLine(to: CGPoint(x: w * 0.76, y: h))
        minor.move(to: CGPoint(x: 0, y: h * 0.74))
        minor.addLine(to: CGPoint(x: w, y: h * 0.66))
        context.stroke(minor, with: .color(Palette.paper), style: StrokeStyle(lineWidth: 6, lineCap: .round))
        context.stroke(minor, with: .color(Palette.line.opacity(0.65)), style: StrokeStyle(lineWidth: 1, lineCap: .round))

        let labels: [(String, CGPoint)] = [
            ("Shichahai", CGPoint(x: content.minX + content.width * 0.16, y: content.minY + content.height * 0.24)),
            ("Nanluoguxiang", CGPoint(x: content.minX + content.width * 0.74, y: content.minY + content.height * 0.22)),
            ("Forbidden City", CGPoint(x: content.minX + content.width * 0.68, y: content.minY + content.height * 0.64)),
            ("Jingshan", CGPoint(x: content.minX + content.width * 0.70, y: content.minY + content.height * 0.48))
        ]
        for label in labels {
            context.draw(
                Text(label.0)
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(Palette.ink2.opacity(0.72)),
                at: label.1,
                anchor: .center
            )
        }

        if model.layer == .community {
            let altA = [CGPoint(x: 0.22, y: 0.82), CGPoint(x: 0.30, y: 0.58), CGPoint(x: 0.46, y: 0.40), CGPoint(x: 0.66, y: 0.22)]
            let altB = [CGPoint(x: 0.76, y: 0.80), CGPoint(x: 0.68, y: 0.58), CGPoint(x: 0.56, y: 0.46), CGPoint(x: 0.38, y: 0.20)]
            for (index, points) in [altA, altB].enumerated() {
                var path = Path()
                let mapped = points.map {
                    CGPoint(x: content.minX + content.width * $0.x, y: content.minY + content.height * $0.y)
                }
                if let first = mapped.first {
                    path.move(to: first)
                    for point in mapped.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(
                    path,
                    with: .color(index == 0 ? Palette.blue.opacity(0.85) : Palette.olive.opacity(0.85)),
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round, dash: [5, 4])
                )
            }
        }

        if model.layer == .crowd {
            let hotspots: [(CGFloat, CGFloat, CGFloat)] = [
                (0.54, 0.60, 46), (0.62, 0.30, 32), (0.48, 0.88, 26)
            ]
            for spot in hotspots {
                let center = CGPoint(x: content.minX + content.width * spot.0, y: content.minY + content.height * spot.1)
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - spot.2, y: center.y - spot.2, width: spot.2 * 2, height: spot.2 * 2)),
                    with: .color(Palette.accent.opacity(0.13))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - spot.2 * 0.45, y: center.y - spot.2 * 0.45, width: spot.2 * 0.9, height: spot.2 * 0.9)),
                    with: .color(Palette.accent.opacity(0.2))
                )
            }
            context.draw(
                Text("Busy after 14:00")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Palette.warn),
                at: CGPoint(x: content.maxX - 46, y: content.maxY - 10),
                anchor: .center
            )
        }

        guard model.stops.count > 1 else { return }
        var route = Path()
        let points = model.stops.map {
            CGPoint(x: content.minX + content.width * $0.x, y: content.minY + content.height * $0.y)
        }
        route.move(to: points[0])
        for index in 1..<points.count {
            let mid = CGPoint(x: (points[index - 1].x + points[index].x) / 2,
                              y: (points[index - 1].y + points[index].y) / 2)
            route.addQuadCurve(to: mid, control: points[index - 1])
        }
        route.addLine(to: points[points.count - 1])

        context.stroke(route, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 7.5, lineCap: .round, lineJoin: .round))
        context.stroke(route, with: .color(Palette.accent), style: StrokeStyle(lineWidth: 3.2, lineCap: .round, lineJoin: .round))
    }

    private func collaborator(name: String, color: Color, point: CGPoint) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Image(systemName: "cursorarrow")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
            Text(name)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(Capsule().fill(color))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
        }
        .position(x: point.x, y: point.y)
        .allowsHitTesting(false)
        .opacity(model.layer == .community ? 1 : 0.55)
    }

    private func pinBody(index: Int, stop: RouteStop) -> some View {
        let selected = model.selectedStopID == stop.id
        let editing = model.mapEditMode
        return VStack(spacing: 3) {
            ZStack {
                if editing {
                    Circle()
                        .strokeBorder(Palette.accent.opacity(0.9), style: StrokeStyle(lineWidth: 1.4, dash: [3, 3]))
                        .frame(width: 45, height: 45)
                }
                Circle()
                    .fill(selected ? Palette.ink : Palette.paper)
                    .frame(width: selected ? 34 : 28, height: selected ? 34 : 28)
                Circle()
                    .strokeBorder(selected ? Palette.lime : Palette.ink, lineWidth: selected ? 2.4 : 1.4)
                    .frame(width: selected ? 34 : 28, height: selected ? 34 : 28)
                Text("\(index + 1)")
                    .font(.system(size: selected ? 12 : 9.5, weight: .black))
                    .foregroundStyle(selected ? Palette.lime : Palette.ink)
                if editing {
                    Image(systemName: "arrow.up.and.down.and.arrow.left.and.right")
                        .font(.system(size: 5.5, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 15, height: 15)
                        .background(Circle().fill(Palette.lime))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
                        .offset(x: 17, y: 15)
                }
            }
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.2), radius: 0, x: 0, y: 2)

            if selected {
                VStack(spacing: 1) {
                    Text(model.say(stop.name))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Text(stop.time)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Similar routes

private struct SimilarRoutesSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Eyebrow(text: "PLATFORM / MATCH")
                        Text("Routes like yours")
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.5)
                            .foregroundStyle(Palette.ink)
                        Text("Three picks from 4,208 community routes — apply one as your own copy.")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Palette.ink2)
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

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                    Text("Top match 94% · Keeps your Forbidden City booking · 1.2 km shorter")
                        .font(.system(size: 10.5, weight: .semibold))
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Palette.ink)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.limeSoft))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                ForEach(model.similarRoutes) { route in
                    routeCard(route)
                }

                Text("Applying creates a separate copy — your edits won't change the original.")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .padding(.bottom, 18)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private func routeCard(_ route: SimilarRoute) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Text("\(route.match)%")
                    .font(.system(size: 19, weight: .black, design: .rounded))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 62, height: 52)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(route.match >= 90 ? Palette.lime : Palette.mustardSoft))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))

                VStack(alignment: .leading, spacing: 3) {
                    Text(route.title)
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Palette.ink)
                    Text("\(route.author) · \(route.stops) stops · \(route.distance) · \(route.duration)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 4) {
                ForEach(route.tags, id: \.self) { tag in
                    TagView(text: tag, style: .soft)
                }
            }

            Text(route.highlight)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .lineSpacing(3)

            Button {
                Haptics.success()
                dismiss()
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 320_000_000)
                    model.copyRoute(named: route.title)
                }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 9.5, weight: .bold))
                    Text("Use as my copy")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 3)
    }
}
