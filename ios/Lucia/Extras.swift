import SwiftUI
import UIKit

// MARK: - Visual notes

struct NotesPoster: View {
    @EnvironmentObject private var model: AppModel
    @State private var copied = false

    private var cleanName: String {
        model.routeName.replacingOccurrences(of: " · Draft", with: "")
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 6)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    poster
                    ShareLink(item: model.routeSummary) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 11, weight: .bold))
                            Text("Share this note")
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
                            Text(copied ? "Caption copied" : "Copy caption")
                                .font(.system(size: 11.5, weight: .medium))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 43)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Text("The note includes route order, times and distance — ready for social.")
                        .font(.system(size: 9.5))
                        .foregroundStyle(Palette.ink3)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 30)
            }
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
            Text("Visual note")
                .font(.system(size: 21, weight: .black))
                .foregroundStyle(Palette.ink)
            Spacer()
            Button {
                Haptics.tap()
                closeNote()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
                    .contentShape(Circle())
            }
            .buttonStyle(PressableButtonStyle())
            .simultaneousGesture(TapGesture().onEnded { closeNote() })
            .accessibilityLabel("Close visual note")
        }
    }

    private func closeNote() {
        model.notesOpen = false
    }

    private var poster: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Eyebrow(text: "ROAMCHINA · CITYWALK")
                Spacer()
                StickerLabel(text: "NO. 014", fill: Palette.mustard, rotation: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(cleanName)
                    .font(.system(size: 30, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                Text("2026.10.15 · Beijing · With Lina & Zhou")
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
                Label("6 stops", systemImage: "mappin.and.ellipse")
                Label("4.2 km", systemImage: "figure.walk")
                Label("~5 hr", systemImage: "clock")
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
                Text("Slow down — Beijing shows itself.")
                    .font(.system(size: 10.5, design: .serif))
                    .foregroundStyle(Palette.ink3)
                Spacer()
                Text("roamchina.travel")
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
                    Eyebrow(text: "SHOW STAFF", color: Palette.paper.opacity(0.45))
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
                            Text("Play Chinese")
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 22)
                        .frame(height: 45)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.9), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Text("No network needed · Saved in your offline pack")
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
                    Text("Reorder stops")
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(Palette.ink)
                    Text("Drag the handles — times recalculate")
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Done")
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
                ForEach(model.reorderStops) { stop in
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
                    model.moveReorderStops(from: source, to: destination)
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
                ("What we store", "Your trip, checklist ticks and offline phrase pack stay on this device. Community browsing isn't linked to your identity."),
                ("What we never upload", "Passport numbers, phone numbers and payment details never pass through Pico. Ticket bookings open the official channel instead."),
                ("Offline use", "Maps, translation and emergency phrases work offline. Offline mode never uploads your location; a link is created only when you choose to share."),
                ("Your choices", "Turn off notifications under Me, or long-press a checklist item to delete your own additions.")
            ]
        }
        return [
            ("What Pico covers", "Pico offers trip planning, prep, translation and community browsing. Tickets, hotels and transport come from official third-party channels."),
            ("Content & advice", "AI suggestions draw on public information and your preferences. Check official sources for opening hours, prices and weather."),
            ("Community rules", "Share real experiences. No infringing, promotional or unfriendly content — it will be hidden."),
            ("Cost", "Core features are free. Some offline packs and extras may be paid, always shown before you buy.")
        ]
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow(text: "ROAMCHINA · LEGAL")
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

                Text("Updated October 2026 · For RoamChina iOS v1.0")
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

                Text("Questions: hello@roamchina.travel")
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
                    Eyebrow(text: "WHY IT'S HERE")
                    Text("Locals come here too — it's better outside tour-group hours. Arrive 20 minutes before opening, or come after 15:00.")
                        .font(.system(size: 11))
                        .foregroundStyle(Palette.ink2)
                        .lineSpacing(4)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.mustardSoft))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                VStack(alignment: .leading, spacing: 0) {
                    infoRow(icon: "clock", title: "Hours", value: "10:00 – 22:00")
                    SoftDivider().padding(.leading, 38)
                    infoRow(icon: "location", title: "Distance", value: "2.4 km from hotel · 2 metro stops")
                    SoftDivider().padding(.leading, 38)
                    infoRow(icon: "figure.walk", title: "Suggested stay", value: "45 min – 1 hr")
                }
                .padding(.horizontal, 13)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                Button {
                    model.openAssistant("Community · \(place.title)")
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        Text("Ask Pico: which day should I come?")
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
                        Text("After 3pm there's barely a wait, and the duck skin is still crisp.")
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
                        Text("Lina · Community note · 3 days ago")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                        Spacer(minLength: 0)
                        TagView(text: "86 saves", style: .neutral)
                    }
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
                .overlay(alignment: .topLeading) {
                    StickerLabel(text: "FROM THE COMMUNITY", fill: Palette.pink, rotation: -4, icon: "quote.bubble.fill")
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
                        Text(added ? "Added to list" : "Add to list")
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

    private let tags = ["Food", "Sights", "Routes", "Gifts", "Events"]

    init(initialTag: String = "Food", initialAttachRoute: Bool = false) {
        _tag = State(initialValue: initialTag)
        _attachRoute = State(initialValue: initialAttachRoute)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Eyebrow(text: "COMMUNITY · POST")
                        Text("Share your Beijing")
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

                TextField("Give it a title, e.g. “Dongsi coffee map”", text: $title)
                    .font(.system(size: 13, weight: .semibold))
                    .textFieldStyle(.plain)
                    .padding(13)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))

                ZStack(alignment: .topLeading) {
                    if bodyText.isEmpty {
                        Text("Tell us what you tried: what you ordered, what it cost, the best time to go…")
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
                    Eyebrow(text: "PHOTOS")
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
                                    Text(photos.isEmpty ? "Add photos" : "Add another")
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
                    Text("Real photos get saved more · Up to 9")
                        .font(.system(size: 9))
                        .foregroundStyle(Palette.ink3)
                }

                VStack(alignment: .leading, spacing: 7) {
                    Eyebrow(text: "CATEGORY")
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
                    Text("Be real, be specific, add prices — that's what gets saved.")
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
                            Text("Link my route")
                                .font(.system(size: 11.5, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                            Text("\(model.routeName) · \(model.stops.count) stops · 4.2 km")
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
                    Text("Posts appear under Community · Beijing — edit or delete anytime.")
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
                model.toast("Posted · Thanks for sharing", icon: "paperplane.fill")
                dismiss()
            } label: {
                Text("Post to community")
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
