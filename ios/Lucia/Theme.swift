import SwiftUI
import UIKit

// MARK: - Color

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

enum Palette {
    // Paper & ink
    static let bg = Color(hex: 0xF4ECDC)
    static let paper = Color(hex: 0xFFFCF2)
    static let paperWarm = Color(hex: 0xF9F0DC)
    static let ink = Color(hex: 0x191710)
    static let ink2 = Color(hex: 0x534D3F)
    static let ink3 = Color(hex: 0x8D8471)
    static let line = Color(hex: 0xCFC0A5)
    static let lineSoft = Color(hex: 0xE6D9C2)
    static let outline = Color(hex: 0x191710)

    // Editorial accents
    static let accent = Color(hex: 0xEE5B34)
    static let accentSoft = Color(hex: 0xFAD6C4)
    static let coral = Color(hex: 0xEE5B34)
    static let lime = Color(hex: 0xDDEB86)
    static let limeSoft = Color(hex: 0xEFF6CD)
    static let mustard = Color(hex: 0xF2C14E)
    static let mustardSoft = Color(hex: 0xFBE9B8)
    static let pink = Color(hex: 0xF3B1C6)
    static let pinkSoft = Color(hex: 0xFBE0E7)
    static let periwinkle = Color(hex: 0x8CA3E8)
    static let periwinkleSoft = Color(hex: 0xE4E9FB)
    static let mint = Color(hex: 0xB7DFC0)
    static let mintSoft = Color(hex: 0xE4F3E6)
    static let sky = Color(hex: 0xBADCF0)
    static let skySoft = Color(hex: 0xE5F2FA)
    static let lavender = Color(hex: 0xC9C2EE)

    // Semantic
    static let olive = Color(hex: 0x5C7838)
    static let blue = Color(hex: 0x4A63C8)
    static let teal = Color(hex: 0x2C7C72)
    static let warn = Color(hex: 0xC7452A)
    static let ok = Color(hex: 0x3E7F4B)
    static let night = Color(hex: 0x191710)
    static let cream = Color(hex: 0xF2E4C9)
    static let shadow = Color(hex: 0x191710)
}

// MARK: - Type

enum LuciaType {
    /// Tiny uppercase mono labels — the "field notes" voice.
    static func eyebrow(_ size: CGFloat = 9.5) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }

    /// Heavy condensed display — Spotted / Parkette headlines.
    static func display(_ size: CGFloat = 30) -> Font {
        .system(size: size, weight: .black).width(.condensed)
    }

    /// Editorial serif, for soft counterpoint.
    static func serif(_ size: CGFloat = 30, italic: Bool = false) -> Font {
        let base = Font.system(size: size, weight: .semibold, design: .serif)
        return italic ? base.italic() : base
    }

    static func title(_ size: CGFloat = 30) -> Font {
        display(size)
    }

    static func body(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func cardTitle(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .bold)
    }

    static func heavy(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .heavy)
    }
}

// MARK: - Base components

struct Eyebrow: View {
    let text: String
    var color: Color = Palette.ink3
    var body: some View {
        Text(text.uppercased())
            .font(LuciaType.eyebrow())
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

enum TagStyle {
    case neutral, accent, soft, ok, warn, blue, dark

    var foreground: Color {
        switch self {
        case .neutral: return Palette.ink2
        case .accent, .warn: return Palette.ink
        case .soft: return Palette.ink2
        case .ok: return Color(hex: 0x2F6B3C)
        case .blue: return Color(hex: 0x3C53A8)
        case .dark: return Palette.paper
        }
    }

    var background: Color {
        switch self {
        case .neutral: return Palette.paperWarm
        case .accent: return Palette.accentSoft
        case .warn: return Color(hex: 0xF8DCC9)
        case .soft: return Palette.cream.opacity(0.55)
        case .ok: return Palette.mintSoft
        case .blue: return Palette.periwinkleSoft
        case .dark: return Palette.ink
        }
    }

    var border: Color {
        switch self {
        case .dark: return Palette.ink
        default: return Palette.ink.opacity(0.62)
        }
    }
}

struct TagView: View {
    let text: String
    var style: TagStyle = .neutral
    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(style.foreground)
            .padding(.horizontal, 7.5)
            .padding(.vertical, 4)
            .background(Capsule().fill(style.background))
            .overlay(Capsule().strokeBorder(style.border, lineWidth: 1))
    }
}

/// Rotated paper label with an outline — the sticker / tape voice from the references.
struct StickerLabel: View {
    var text: String
    var fill: Color = Palette.mustard
    var rotation: Double = -3
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon).font(.system(size: 8, weight: .bold))
            }
            Text(text.uppercased())
                .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                .tracking(0.6)
        }
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 8)
        .padding(.vertical, 4.5)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1)
        )
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.15), radius: 0, x: 1.5, y: 1.5)
        .rotationEffect(.degrees(rotation))
    }
}

struct TapeStrip: View {
    var color: Color = Palette.mustard.opacity(0.72)
    var rotation: Double = -5

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 56, height: 16)
            .overlay(
                Rectangle()
                    .strokeBorder(Palette.ink.opacity(0.18), style: StrokeStyle(lineWidth: 0.8, dash: [2, 2]))
            )
            .rotationEffect(.degrees(rotation))
    }
}

/// Small hand-drawn marks used to loosen up headers.
enum LuciaDoodle {
    case sparkle, squiggle, sun, flower
}

struct DoodleView: View {
    var kind: LuciaDoodle
    var color: Color = Palette.accent
    var lineWidth: CGFloat = 1.6
    var center: Color = Palette.ink

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            switch kind {
            case .sparkle:
                var path = Path()
                path.move(to: CGPoint(x: w * 0.5, y: 0))
                path.addQuadCurve(to: CGPoint(x: w, y: h * 0.5), control: CGPoint(x: w * 0.58, y: h * 0.42))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h), control: CGPoint(x: w * 0.58, y: h * 0.58))
                path.addQuadCurve(to: CGPoint(x: 0, y: h * 0.5), control: CGPoint(x: w * 0.42, y: h * 0.58))
                path.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0), control: CGPoint(x: w * 0.42, y: h * 0.42))
                context.fill(path, with: .color(color))
            case .squiggle:
                var path = Path()
                path.move(to: CGPoint(x: 0, y: h * 0.6))
                path.addCurve(
                    to: CGPoint(x: w, y: h * 0.4),
                    control1: CGPoint(x: w * 0.3, y: h * 0.05),
                    control2: CGPoint(x: w * 0.68, y: h * 0.95)
                )
                context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            case .sun:
                context.stroke(
                    Path(ellipseIn: CGRect(x: w * 0.24, y: h * 0.24, width: w * 0.52, height: h * 0.52)),
                    with: .color(color), lineWidth: lineWidth
                )
                for index in 0..<8 {
                    let angle = Double(index) * .pi / 4
                    let inner = CGPoint(x: w * 0.5 + cos(angle) * w * 0.36, y: h * 0.5 + sin(angle) * h * 0.36)
                    let outer = CGPoint(x: w * 0.5 + cos(angle) * w * 0.5, y: h * 0.5 + sin(angle) * h * 0.5)
                    var ray = Path()
                    ray.move(to: inner)
                    ray.addLine(to: outer)
                    context.stroke(ray, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                }
            case .flower:
                for index in 0..<5 {
                    let angle = Double(index) * 2 * .pi / 5 - .pi / 2
                    let center = CGPoint(x: w * 0.5 + cos(angle) * w * 0.22, y: h * 0.5 + sin(angle) * h * 0.22)
                    let rect = CGRect(x: center.x - w * 0.18, y: center.y - h * 0.18, width: w * 0.36, height: h * 0.36)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
                context.fill(
                    Path(ellipseIn: CGRect(x: w * 0.37, y: h * 0.37, width: w * 0.26, height: h * 0.26)),
                    with: .color(center)
                )
            }
        }
    }
}

struct LuciaCardModifier: ViewModifier {
    var padding: CGFloat = 14
    var radius: CGFloat = 20
    var fill: Color = Palette.paper
    var stroke: Color = Palette.outline
    var shadowed: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(stroke, lineWidth: 1.2)
            )
            .compositingGroup()
            .shadow(
                color: shadowed ? Palette.ink.opacity(0.08) : .clear,
                radius: 0, x: 0, y: 3
            )
            .shadow(
                color: shadowed ? Palette.ink.opacity(0.05) : .clear,
                radius: 14, x: 0, y: 8
            )
    }
}

extension View {
    func luciaCard(
        padding: CGFloat = 14,
        radius: CGFloat = 20,
        fill: Color = Palette.paper,
        stroke: Color = Palette.outline,
        shadowed: Bool = true
    ) -> some View {
        modifier(LuciaCardModifier(padding: padding, radius: radius, fill: fill, stroke: stroke, shadowed: shadowed))
    }

    /// Paper card with the reference's chunky ink outline (no soft shadow).
    func outlineCard(
        padding: CGFloat = 14,
        radius: CGFloat = 20,
        fill: Color = Palette.paper,
        lineWidth: CGFloat = 1.3
    ) -> some View {
        self
            .padding(padding)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Palette.ink, lineWidth: lineWidth)
            )
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.14), radius: 0, x: 0, y: 3)
    }

    func dashedBorder(color: Color = Palette.ink.opacity(0.35), radius: CGFloat = 20, dash: [CGFloat] = [5, 4]) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(color, style: StrokeStyle(lineWidth: 1.2, dash: dash))
        )
    }
}

struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct LuciaPrimaryButton: View {
    var title: String
    var icon: String? = nil
    var wide: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 11, weight: .bold))
                }
                Text(title).font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Palette.paper)
            .padding(.horizontal, 15)
            .frame(height: 36)
            .frame(maxWidth: wide ? .infinity : nil)
            .background(Capsule().fill(Palette.ink))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct LuciaLimeButton: View {
    var title: String
    var icon: String? = nil
    var wide: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 11, weight: .bold))
                }
                Text(title).font(.system(size: 12, weight: .bold))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 15)
            .frame(height: 36)
            .frame(maxWidth: wide ? .infinity : nil)
            .background(Capsule().fill(Palette.lime))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.18), radius: 0, x: 0, y: 2.5)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct LuciaSoftButton: View {
    var title: String
    var icon: String? = nil
    var wide: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(spacing: 5) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 10, weight: .bold))
                }
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 13)
            .frame(height: 33)
            .frame(maxWidth: wide ? .infinity : nil)
            .background(Capsule().fill(Palette.paper))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct IconCircleButton: View {
    var icon: String
    var size: CGFloat = 34
    var dark: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(dark ? Palette.ink : Palette.ink)
                .frame(width: size, height: size)
                .background(Circle().fill(dark ? Palette.lime : Palette.paper))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
                .compositingGroup()
                .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

struct SectionHeading: View {
    var title: String
    var index: String? = nil
    var trailing: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let index {
                Text(index)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Palette.lime))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            }
            Text(title)
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(Palette.ink)
                .tracking(-0.2)
            Spacer()
            if let trailing {
                Button {
                    Haptics.tap()
                    trailingAction?()
                } label: {
                    HStack(spacing: 3) {
                        Text(trailing)
                        if trailingAction != nil {
                            Image(systemName: "arrow.up.right").font(.system(size: 8, weight: .black))
                        }
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 9)
                    .frame(height: 25)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: trailingAction == nil ? 0.8 : 1.1))
                }
                .buttonStyle(.plain)
                .disabled(trailingAction == nil)
            }
        }
    }
}

struct ProgressRingView: View {
    var progress: Double
    var label: String
    var size: CGFloat = 54
    var lineWidth: CGFloat = 4.5
    var track: Color = Palette.lineSoft
    var tint: Color = Palette.accent
    var labelColor: Color = Palette.ink

    var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0.02, progress))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(label)
                .font(.system(size: size * 0.21, weight: .black))
                .foregroundStyle(labelColor)
        }
        .frame(width: size, height: size)
    }
}

struct AvatarView: View {
    var name: String
    var size: CGFloat = 30
    var fill: Color = Palette.lime

    var body: some View {
        Text(name)
            .font(.system(size: size * 0.4, weight: .semibold, design: .serif))
            .foregroundStyle(Palette.ink)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.3))
    }
}

struct AvatarStack: View {
    var names: [String]
    var size: CGFloat = 24
    private let fills: [Color] = [Palette.lime, Palette.pink, Palette.periwinkle, Palette.mustard]

    var body: some View {
        HStack(spacing: -7) {
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                AvatarView(name: name, size: size, fill: fills[index % fills.count])
            }
        }
    }
}

struct SheetHandle: View {
    var body: some View {
        Capsule()
            .fill(Palette.ink.opacity(0.35))
            .frame(width: 38, height: 4)
    }
}

struct PressableCardButton<Content: View>: View {
    var action: () -> Void
    @ViewBuilder var content: Content

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            content
        }
        .buttonStyle(PressableButtonStyle(scale: 0.985))
    }
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
