import SwiftUI

// MARK: - Floating navigation

struct FloatingTabBar: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        HStack(spacing: 3) {
            ForEach(Tab.allCases) { tab in
                tabButton(tab)
            }
        }
        .padding(5)
        .background(Capsule(style: .continuous).fill(Palette.paper))
        .overlay(Capsule(style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.3))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 3)
        .shadow(color: Palette.ink.opacity(0.08), radius: 18, x: 0, y: 10)
    }

    @ViewBuilder
    private func tabButton(_ tab: Tab) -> some View {
        let active = model.tab == tab
        Button {
            guard model.tab != tab else { return }
            Haptics.tap()
            withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                model.tab = tab
            }
        } label: {
            HStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: active ? tab.icon + ".fill" : tab.icon)
                        .font(.system(size: 15, weight: .semibold))
                    if tab.badge > 0 && !active {
                        Circle()
                            .fill(Palette.accent)
                            .frame(width: 6, height: 6)
                            .overlay(Circle().strokeBorder(Palette.paper, lineWidth: 0.8))
                            .offset(x: 7, y: -2)
                    }
                }
                if active {
                    Text(tab.title)
                        .font(.system(size: 11.5, weight: .bold))
                        .fixedSize()
                }
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, active ? 11 : 0)
            .frame(width: active ? nil : 44, height: 44)
            .background(Capsule(style: .continuous).fill(active ? Palette.lime : Color.clear))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(active ? Palette.ink : Color.clear, lineWidth: 1)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle(scale: 0.93))
    }
}

struct AssistantOrb: View {
    @EnvironmentObject private var model: AppModel
    var context: String? = nil
    @State private var breathe = false

    var body: some View {
        Button {
            model.openAssistant(context ?? model.tab.assistantContext)
        } label: {
            ZStack {
                Circle()
                    .fill(Palette.lime.opacity(0.5))
                    .frame(width: 66, height: 66)
                    .scaleEffect(breathe ? 1.16 : 0.84)
                    .opacity(breathe ? 0 : 0.95)
                Circle()
                    .fill(Palette.lime)
                    .frame(width: 54, height: 54)
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.4))
                Image(systemName: "sparkles")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Circle()
                    .fill(Palette.accent)
                    .frame(width: 13, height: 13)
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    .overlay(
                        Image(systemName: "star.fill")
                            .font(.system(size: 5, weight: .black))
                            .foregroundStyle(Palette.paper)
                    )
                    .offset(x: 16, y: -16)
            }
            .frame(width: 66, height: 66)
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 3)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.92))
        .accessibilityLabel("打开 Lucia 助手")
        .onAppear {
            withAnimation(.easeOut(duration: 2.6).repeatForever(autoreverses: false)) {
                breathe = true
            }
        }
    }
}

struct ToastBanner: View {
    var toast: Toast

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: toast.icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.lime)
            Text(toast.text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Palette.paper)
                .lineLimit(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Capsule(style: .continuous).fill(Palette.ink))
        .overlay(Capsule(style: .continuous).strokeBorder(Palette.paper.opacity(0.2), lineWidth: 0.8))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.2), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Chips & controls

struct Chip: View {
    var title: String
    var selected: Bool
    var count: String? = nil
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 4) {
                Text(title)
                if let count {
                    Text(count).opacity(0.6)
                }
            }
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 13)
            .frame(height: 32)
            .background(Capsule().fill(selected ? Palette.lime : Palette.paper))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: selected ? 1.2 : 1))
            .compositingGroup()
            .shadow(color: selected ? Palette.ink.opacity(0.14) : .clear, radius: 0, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.96))
    }
}

struct SegmentedControl<T: Hashable>: View {
    var options: [T]
    var title: (T) -> String
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(active ? Palette.paper : Palette.ink2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(Capsule().fill(active ? Palette.ink : Color.clear))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.98))
            }
        }
        .padding(4)
        .background(Capsule().fill(Palette.paper))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
    }
}

struct LinearProgressBar: View {
    var progress: Double
    var height: CGFloat = 5
    var tint: Color = Palette.accent
    var track: Color = Palette.lineSoft

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(track)
                Capsule()
                    .fill(tint)
                    .frame(width: max(height, geo.size.width * min(1, max(0, progress))))
            }
        }
        .frame(height: height)
    }
}

struct SoftDivider: View {
    var body: some View {
        Rectangle()
            .fill(Palette.lineSoft)
            .frame(height: 0.9)
    }
}

// MARK: - Art

struct CityScape: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            // Flat sky
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Palette.sky)
            )

            // Sun with hand-drawn rays
            let sunCenter = CGPoint(x: w * 0.79, y: h * 0.23)
            let sunRadius = w * 0.085
            for index in 0..<10 {
                let angle = Double(index) * .pi / 5 + 0.2
                var ray = Path()
                ray.move(to: CGPoint(
                    x: sunCenter.x + cos(angle) * (sunRadius + 5),
                    y: sunCenter.y + sin(angle) * (sunRadius + 5)
                ))
                ray.addLine(to: CGPoint(
                    x: sunCenter.x + cos(angle) * (sunRadius + 12),
                    y: sunCenter.y + sin(angle) * (sunRadius + 12)
                ))
                context.stroke(ray, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
            }
            context.fill(
                Path(ellipseIn: CGRect(x: sunCenter.x - sunRadius, y: sunCenter.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)),
                with: .color(Palette.mustard)
            )
            context.stroke(
                Path(ellipseIn: CGRect(x: sunCenter.x - sunRadius, y: sunCenter.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)),
                with: .color(Palette.ink), lineWidth: 1.3
            )

            // Clouds
            func cloud(_ center: CGPoint, scale: CGFloat) {
                var path = Path()
                path.addEllipse(in: CGRect(x: center.x - 24 * scale, y: center.y - 7 * scale, width: 28 * scale, height: 20 * scale))
                path.addEllipse(in: CGRect(x: center.x - 4 * scale, y: center.y - 12 * scale, width: 32 * scale, height: 26 * scale))
                path.addEllipse(in: CGRect(x: center.x + 16 * scale, y: center.y - 5 * scale, width: 24 * scale, height: 18 * scale))
                context.fill(path, with: .color(Palette.paper))
                context.stroke(path, with: .color(Palette.ink), lineWidth: 1.1)
            }
            cloud(CGPoint(x: w * 0.20, y: h * 0.21), scale: 1.0)
            cloud(CGPoint(x: w * 0.56, y: h * 0.13), scale: 0.72)

            // Distant hills
            var hills = Path()
            hills.move(to: CGPoint(x: 0, y: h * 0.68))
            hills.addQuadCurve(to: CGPoint(x: w * 0.34, y: h * 0.60), control: CGPoint(x: w * 0.16, y: h * 0.55))
            hills.addQuadCurve(to: CGPoint(x: w * 0.68, y: h * 0.66), control: CGPoint(x: w * 0.50, y: h * 0.72))
            hills.addQuadCurve(to: CGPoint(x: w, y: h * 0.60), control: CGPoint(x: w * 0.86, y: h * 0.53))
            hills.addLine(to: CGPoint(x: w, y: h))
            hills.addLine(to: CGPoint(x: 0, y: h))
            hills.closeSubpath()
            context.fill(hills, with: .color(Palette.mint))
            hills.addLine(to: CGPoint(x: 0, y: h * 0.68))
            context.stroke(hills, with: .color(Palette.ink), lineWidth: 1.1)

            // Trees
            let trees: [(CGFloat, CGFloat, CGFloat)] = [
                (0.07, 0.86, 0.065), (0.13, 0.89, 0.048), (0.93, 0.85, 0.062), (0.98, 0.89, 0.044)
            ]
            for tree in trees {
                let radius = w * tree.2
                let center = CGPoint(x: w * tree.0, y: h * tree.1 - radius * 0.9)
                let trunk = CGRect(x: center.x - radius * 0.11, y: center.y, width: radius * 0.22, height: radius * 1.7)
                context.fill(Path(trunk), with: .color(Palette.ink))
                let canopy = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2.05))
                context.fill(canopy, with: .color(Palette.olive))
                context.stroke(canopy, with: .color(Palette.ink), lineWidth: 1.1)
            }

            // Ground
            let groundY = h * 0.885
            context.fill(
                Path(CGRect(x: 0, y: groundY, width: w, height: h - groundY)),
                with: .color(Palette.cream)
            )
            var groundLine = Path()
            groundLine.move(to: CGPoint(x: 0, y: groundY))
            groundLine.addLine(to: CGPoint(x: w, y: groundY))
            context.stroke(groundLine, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 1.2, dash: [6, 4]))

            // Palaces
            let pavilions: [(CGFloat, CGFloat, CGFloat)] = [
                (0.16, 0.885, 0.25), (0.84, 0.885, 0.23), (0.50, 0.93, 0.33)
            ]
            for item in pavilions {
                let shapes = Self.pavilion(centerX: w * item.0, baseY: h * item.1, width: w * item.2)
                context.fill(shapes.body, with: .color(Palette.paper))
                context.stroke(shapes.body, with: .color(Palette.ink), lineWidth: 1.2)
                context.fill(shapes.doors, with: .color(Palette.ink))
                context.fill(shapes.roof, with: .color(Palette.coral))
                context.stroke(shapes.roof, with: .color(Palette.ink), lineWidth: 1.2)
                context.stroke(shapes.ridge, with: .color(Palette.ink), lineWidth: 1.4)
                // Lanterns under the eaves
                let lanternY = item.1 * h - w * item.2 * 0.02
                for side in [-0.34, 0.34] {
                    let lx = w * item.0 + w * item.2 * side
                    let rect = CGRect(x: lx - 3.2, y: lanternY + 4, width: 6.4, height: 8)
                    context.fill(Path(ellipseIn: rect), with: .color(Palette.mustard))
                    context.stroke(Path(ellipseIn: rect), with: .color(Palette.ink), lineWidth: 1)
                    var string = Path()
                    string.move(to: CGPoint(x: lx, y: lanternY))
                    string.addLine(to: CGPoint(x: lx, y: lanternY + 4))
                    context.stroke(string, with: .color(Palette.ink), lineWidth: 1)
                }
            }

            // Birds
            let birds: [(CGFloat, CGFloat, CGFloat)] = [(0.60, 0.31, 1.0), (0.66, 0.265, 0.78), (0.72, 0.315, 0.62)]
            for bird in birds {
                var path = Path()
                let x = w * bird.0
                let y = h * bird.1
                let s = bird.2 * 7
                path.move(to: CGPoint(x: x - s, y: y))
                path.addQuadCurve(to: CGPoint(x: x, y: y - s * 0.36), control: CGPoint(x: x - s * 0.5, y: y - s * 0.5))
                path.addQuadCurve(to: CGPoint(x: x + s, y: y), control: CGPoint(x: x + s * 0.5, y: y - s * 0.5))
                context.stroke(path, with: .color(Palette.ink), lineWidth: 1.3)
            }

            // Seal stamp
            let stampRect = CGRect(x: w * 0.885, y: h * 0.82, width: 30, height: 30)
            let stamp = Path(roundedRect: stampRect, cornerRadius: 4)
            context.fill(stamp, with: .color(Palette.coral))
            context.stroke(stamp, with: .color(Palette.ink), lineWidth: 1.2)
            context.draw(
                Text("京")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(Palette.paper),
                at: CGPoint(x: stampRect.midX, y: stampRect.midY),
                anchor: .center
            )

            // Paper grain
            for index in 0..<46 {
                let fx = CGFloat((index * 37) % 101) / 101
                let fy = CGFloat((index * 61) % 101) / 101
                context.fill(
                    Path(ellipseIn: CGRect(x: fx * w, y: fy * h, width: 1.1, height: 1.1)),
                    with: .color(Palette.ink.opacity(0.05))
                )
            }
        }
        .clipped()
    }

    private static func pavilion(centerX: CGFloat, baseY: CGFloat, width: CGFloat)
        -> (body: Path, doors: Path, roof: Path, ridge: Path) {
        let bodyWidth = width * 0.62
        let bodyHeight = width * 0.42
        let bodyRect = CGRect(x: centerX - bodyWidth / 2, y: baseY - bodyHeight, width: bodyWidth, height: bodyHeight)
        let body = Path(bodyRect)

        var doors = Path()
        let doorWidth = width * 0.085
        for offset in [-0.17, 0.0, 0.17] {
            let rect = CGRect(
                x: centerX + width * offset - doorWidth / 2,
                y: baseY - bodyHeight * 0.66,
                width: doorWidth,
                height: bodyHeight * 0.66
            )
            doors.addRoundedRect(in: rect, cornerSize: CGSize(width: doorWidth * 0.45, height: doorWidth * 0.45))
        }

        let eaveY = baseY - bodyHeight
        let ridgeY = eaveY - width * 0.30
        var roof = Path()
        roof.move(to: CGPoint(x: centerX - width * 0.64, y: eaveY - width * 0.01))
        roof.addQuadCurve(
            to: CGPoint(x: centerX - width * 0.17, y: ridgeY),
            control: CGPoint(x: centerX - width * 0.46, y: eaveY + width * 0.005)
        )
        roof.addLine(to: CGPoint(x: centerX + width * 0.17, y: ridgeY))
        roof.addQuadCurve(
            to: CGPoint(x: centerX + width * 0.64, y: eaveY - width * 0.01),
            control: CGPoint(x: centerX + width * 0.46, y: eaveY + width * 0.005)
        )
        roof.addLine(to: CGPoint(x: centerX + width * 0.58, y: eaveY + width * 0.07))
        roof.addQuadCurve(
            to: CGPoint(x: centerX - width * 0.58, y: eaveY + width * 0.07),
            control: CGPoint(x: centerX, y: eaveY + width * 0.11)
        )
        roof.closeSubpath()

        var ridge = Path()
        ridge.move(to: CGPoint(x: centerX - width * 0.15, y: ridgeY))
        ridge.addLine(to: CGPoint(x: centerX + width * 0.15, y: ridgeY))
        return (body, doors, roof, ridge)
    }
}

struct MiniRouteMap: View {
    var points: [CGPoint]
    var tint: Color = Palette.accent
    var showPins: Bool = true

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Palette.paper))

            // Parks
            let parkA = Path(roundedRect: CGRect(x: w * 0.03, y: h * 0.06, width: w * 0.38, height: h * 0.34), cornerRadius: 12)
            context.fill(parkA, with: .color(Palette.mint))
            context.stroke(parkA, with: .color(Palette.ink), lineWidth: 1)

            let pond = Path(roundedRect: CGRect(x: w * 0.09, y: h * 0.11, width: w * 0.21, height: h * 0.13), cornerRadius: 9)
            context.fill(pond, with: .color(Palette.sky))
            context.stroke(pond, with: .color(Palette.ink), lineWidth: 1)

            let parkB = Path(roundedRect: CGRect(x: w * 0.60, y: h * 0.55, width: w * 0.36, height: h * 0.33), cornerRadius: 13)
            context.fill(parkB, with: .color(Palette.limeSoft))
            context.stroke(parkB, with: .color(Palette.ink), lineWidth: 1)

            // Tiny trees
            for index in 0..<6 {
                let tx = w * (0.08 + CGFloat(index % 3) * 0.09)
                let ty = h * (0.14 + CGFloat(index / 3) * 0.10)
                let dot = Path(ellipseIn: CGRect(x: tx, y: ty, width: 5, height: 5))
                context.fill(dot, with: .color(Palette.olive))
            }

            // Roads
            var roads = Path()
            roads.move(to: CGPoint(x: 0, y: h * 0.63))
            roads.addLine(to: CGPoint(x: w, y: h * 0.50))
            roads.move(to: CGPoint(x: w * 0.46, y: 0))
            roads.addLine(to: CGPoint(x: w * 0.58, y: h))
            context.stroke(roads, with: .color(Palette.cream), style: StrokeStyle(lineWidth: 7, lineCap: .round))
            context.stroke(roads, with: .color(Palette.line.opacity(0.7)), style: StrokeStyle(lineWidth: 1, lineCap: .round))

            var thin = Path()
            thin.move(to: CGPoint(x: 0, y: h * 0.26))
            thin.addLine(to: CGPoint(x: w, y: h * 0.35))
            thin.move(to: CGPoint(x: w * 0.16, y: 0))
            thin.addLine(to: CGPoint(x: w * 0.10, y: h))
            context.stroke(thin, with: .color(Palette.line.opacity(0.8)), lineWidth: 1.2)

            guard points.count > 1 else { return }
            let pts = points.map { CGPoint(x: $0.x * w, y: $0.y * h) }
            var route = Path()
            route.move(to: pts[0])
            for index in 1..<pts.count {
                let mid = CGPoint(x: (pts[index - 1].x + pts[index].x) / 2, y: (pts[index - 1].y + pts[index].y) / 2)
                route.addQuadCurve(to: mid, control: pts[index - 1])
            }
            route.addLine(to: pts[pts.count - 1])
            context.stroke(route, with: .color(Palette.ink), style: StrokeStyle(lineWidth: 5.2, lineCap: .round, lineJoin: .round))
            context.stroke(route, with: .color(tint), style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))

            if showPins {
                for point in pts {
                    let outer = Path(ellipseIn: CGRect(x: point.x - 5, y: point.y - 5, width: 10, height: 10))
                    context.fill(outer, with: .color(Palette.paper))
                    context.stroke(outer, with: .color(Palette.ink), lineWidth: 1.2)
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - 2.2, y: point.y - 2.2, width: 4.4, height: 4.4)),
                        with: .color(tint)
                    )
                }
            }
        }
    }
}

struct PhotoTile: View {
    var symbol: String
    var tint: Int
    var height: CGFloat = 96
    var label: String? = nil

    private var colors: [Color] {
        switch tint % 6 {
        case 0: return [Palette.pinkSoft, Palette.pink]
        case 1: return [Palette.skySoft, Palette.sky]
        case 2: return [Palette.mintSoft, Palette.mint]
        case 3: return [Palette.mustardSoft, Palette.mustard]
        case 4: return [Palette.periwinkleSoft, Palette.periwinkle]
        default: return [Palette.limeSoft, Palette.lime]
        }
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)

            Canvas { context, size in
                var arc = Path()
                arc.addArc(
                    center: CGPoint(x: size.width * 0.86, y: size.height * 0.12),
                    radius: size.width * 0.42,
                    startAngle: .degrees(100),
                    endAngle: .degrees(310),
                    clockwise: false
                )
                context.stroke(arc, with: .color(Palette.ink.opacity(0.28)), lineWidth: 1.2)
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.06, y: size.height * 0.60, width: size.width * 0.30, height: size.width * 0.30)),
                    with: .color(Palette.paper.opacity(0.4))
                )
                context.stroke(
                    Path(ellipseIn: CGRect(x: size.width * 0.06, y: size.height * 0.60, width: size.width * 0.30, height: size.width * 0.30)),
                    with: .color(Palette.ink.opacity(0.25)), lineWidth: 1
                )
                // halftone dots
                for index in 0..<12 {
                    let dx = size.width * (0.58 + CGFloat(index % 4) * 0.07)
                    let dy = size.height * (0.66 + CGFloat(index / 4) * 0.09)
                    context.fill(
                        Path(ellipseIn: CGRect(x: dx, y: dy, width: 2, height: 2)),
                        with: .color(Palette.ink.opacity(0.22))
                    )
                }
            }

            Image(systemName: symbol)
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let label {
                Text(label)
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.5)
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                    .padding(8)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.2)
        )
    }
}

struct InfoTile: View {
    var icon: String
    var eyebrow: String
    var value: String
    var detail: String
    var accent: Color = Palette.accent
    var action: () -> Void

    var body: some View {
        PressableCardButton(action: action) {
            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top) {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 27, height: 27)
                        .background(Circle().fill(accent.opacity(0.55)))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Palette.ink)
                }
                Eyebrow(text: eyebrow, color: Palette.ink3)
                Text(value)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(detail)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 2.5)
        }
    }
}

struct Waveform: View {
    var active: Bool
    var color: Color = Palette.paper
    var barCount: Int = 16

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.14)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            HStack(alignment: .center, spacing: 3) {
                ForEach(0..<barCount, id: \.self) { index in
                    let wobble = abs(sin(time * 2.1 + Double(index) * 0.72))
                    Capsule()
                        .fill(color.opacity(active ? 0.92 : 0.45))
                        .frame(width: 2.6, height: active ? CGFloat(wobble) * 20 + 5 : 4)
                }
            }
            .frame(height: 28)
            .animation(.easeInOut(duration: 0.14), value: active)
        }
    }
}

struct MiniMetric: View {
    var value: String
    var label: String
    var accent: Color = Palette.ink

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 25, weight: .black).width(.condensed))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IconBadge: View {
    var icon: String
    var tint: Color = Palette.ink
    var background: Color = Palette.paperWarm
    var size: CGFloat = 34

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: size * 0.32, style: .continuous).fill(background))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                    .strokeBorder(Palette.ink.opacity(0.85), lineWidth: 1)
            )
    }
}
