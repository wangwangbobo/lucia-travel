import SwiftUI

enum LegalKind: String, Identifiable {
    case privacy, terms
    var id: String { rawValue }
    var title: String { self == .privacy ? "Privacy policy" : "Terms of service" }
}

struct JourneyRarity: Identifiable {
    let name: String
    let pct: Double
    var id: String { name }
}

struct JourneyReport: Identifiable {
    let id: String
    let city: String
    let dates: String
    let color: Color
    let title: String
    let blurb: String
    let places: Int
    let newPlaces: Int
    let km: Double
    let rare: String
    let rarePct: Double
    let rank: Int
    let stamps: [String]
    let rarities: [JourneyRarity]

    static let all: [JourneyReport] = [
        JourneyReport(
            id: "chengdu", city: "Chengdu", dates: "Mar 2026", color: Palette.mint,
            title: "The Bamboo Teahouse Wanderer",
            blurb: "Five days of teahouses, chilli oil and one very long bamboo walk. You never once took a taxi before noon.",
            places: 14, newPlaces: 11, km: 38.4,
            rare: "Wangjianglou bamboo grove", rarePct: 3.2, rank: 12,
            stamps: ["Tea house", "Chilli", "Bamboo"],
            rarities: [
                JourneyRarity(name: "Wangjianglou bamboo grove", pct: 3.2),
                JourneyRarity(name: "Yu's Bakery back lane", pct: 7.8),
                JourneyRarity(name: "People's Park teahouse", pct: 28),
                JourneyRarity(name: "Wenshu Monastery", pct: 54),
                JourneyRarity(name: "Kuanzhai Alley", pct: 81)
            ]
        ),
        JourneyReport(
            id: "shanghai", city: "Shanghai", dates: "Nov 2025", color: Palette.pink,
            title: "The Lane Flâneur",
            blurb: "Four days of art deco lanes, midnight noodles and a ferry you took three times for the view.",
            places: 12, newPlaces: 9, km: 41.2,
            rare: "Zhangyuan lane houses", rarePct: 6.8, rank: 18,
            stamps: ["Lanes", "Art deco", "Night ferry"],
            rarities: [
                JourneyRarity(name: "Zhangyuan lane houses", pct: 6.8),
                JourneyRarity(name: "Yangjing snack street", pct: 11),
                JourneyRarity(name: "West Bund galleries", pct: 34),
                JourneyRarity(name: "Wukang Road", pct: 62),
                JourneyRarity(name: "The Bund", pct: 94)
            ]
        )
    ]
}

struct MeView: View {
    @EnvironmentObject private var model: AppModel
    @State private var legal: LegalKind? = nil
    @State private var externalOpen = false
    @State private var report: JourneyReport? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header
                statsCard
                tripCard
                journeysSection
                reservationsSection
                servicesSection
                externalSection
                settingsSection
                legalSection
                footer
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 130)
        }
        .sheet(item: $legal) { kind in
            LegalSheet(kind: kind)
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(28)
                .presentationBackground(Palette.bg)
        }
        .sheet(item: $report) { journey in
            JourneyReportSheet(journey: journey)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        #if DEBUG
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-report"), report == nil {
                report = JourneyReport.all.first
            }
        }
        #endif
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Palette.lime)
                    .frame(width: 64, height: 64)
                Text("W")
                    .font(.system(size: 27, weight: .semibold, design: .serif))
                    .foregroundStyle(Palette.ink)
                Circle()
                    .strokeBorder(Palette.ink, lineWidth: 1.4)
                    .frame(width: 64, height: 64)
            }
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 3)

            VStack(alignment: .leading, spacing: 5) {
                Eyebrow(text: "ME / PROFILE")
                Text("Wang Bo")
                    .font(.system(size: 31, weight: .black))
                    .tracking(-0.5)
                    .foregroundStyle(Palette.ink)
                HStack(spacing: 5) {
                    TagView(text: "RoamChina member", style: .accent)
                    TagView(text: "12th city", style: .soft)
                }
            }
            Spacer()
            IconCircleButton(icon: "gearshape", size: 37) {
                model.openAssistant("Me · Settings & preferences")
            }
        }
    }

    private var statsCard: some View {
        HStack(spacing: 8) {
            statBlock(value: "12", label: "Cities visited", fill: Palette.mustardSoft)
            statBlock(value: "46", label: "Saved places", fill: Palette.pinkSoft)
            statBlock(value: "3", label: "Shared routes", fill: Palette.mintSoft)
        }
    }

    private func statBlock(value: String, label: String, fill: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 34, weight: .black).width(.condensed))
                .foregroundStyle(Palette.ink)
            Text(LocalizedStringKey(label))
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.ink2)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(fill))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
    }

    // MARK: Current trip

    private var tripCard: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Palette.lime.opacity(0.18))
                .frame(width: 220, height: 220)
                .offset(x: 84, y: -100)

            DoodleView(kind: .sparkle, color: Palette.paper.opacity(0.5))
                .frame(width: 26, height: 26)
                .offset(x: -78, y: 92)

            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    TagView(text: "Leaves in 3 days", style: .accent)
                    Spacer()
                    Text(model.tripDateRange(count: model.tripDayCount))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.paper.opacity(0.55))
                }
                Text(model.lang == .zh
                     ? "北京 · \(model.tripDayCount) 天 \(max(0, model.tripDayCount - 1)) 晚"
                     : "Beijing · \(model.tripDayCount) days, \(max(0, model.tripDayCount - 1)) nights")
                    .font(.system(size: 27, weight: .black))
                    .tracking(-0.4)
                    .foregroundStyle(Palette.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text("Wangfujing · 2 adults · Central Axis, slowly")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.paper.opacity(0.55))

                HStack(spacing: 8) {
                    AvatarStack(names: ["L", "Z"], size: 22)
                    Text(model.lang == .zh ? "与 Lina、Zhou 同行" : "With Lina & Zhou")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.paper.opacity(0.5))
                    Spacer()
                    Button {
                        Haptics.tap()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            model.tab = .trip
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("View trip")
                                .font(.system(size: 10, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8, weight: .black))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.top, 2)

                HStack(spacing: 8) {
                    Button {
                        model.checklistOpen = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "checklist")
                                .font(.system(size: 9, weight: .bold))
                            Text(model.lang == .zh ? "清单 \(model.doneCount)/\(model.totalCount)" : "Prep \(model.doneCount)/\(model.totalCount)")
                                .font(.system(size: 9.5, weight: .semibold))
                        }
                        .foregroundStyle(Palette.paper.opacity(0.85))
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(Capsule().fill(Palette.paper.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.2), lineWidth: 0.8))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        model.tab = .plan
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "map")
                                .font(.system(size: 9, weight: .bold))
                            Text("Open route")
                                .font(.system(size: 9.5, weight: .semibold))
                        }
                        .foregroundStyle(Palette.paper.opacity(0.85))
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(Capsule().fill(Palette.paper.opacity(0.14)))
                        .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.2), lineWidth: 0.8))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(RoundedRectangle(cornerRadius: 26, style: .continuous).fill(Palette.ink))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.4))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
    }

    // MARK: Journey reports

    private var journeysSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(
                title: "Journey reports",
                index: "01",
                trailing: model.lang == .zh ? "\(JourneyReport.all.count) 份归档" : "\(JourneyReport.all.count) archived"
            )

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Palette.coral)
                        .frame(width: 7, height: 7)
                        .overlay(Circle().stroke(Palette.coral.opacity(0.25), lineWidth: 3))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Beijing · in progress")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(Palette.ink)
                        Text(model.lang == .zh
                             ? "总结 \(model.tripStamp(model.tripDayCount).date) 解锁——新地点、稀有度和你的称号"
                             : "Wrap-up unlocks \(model.tripStamp(model.tripDayCount).date) — new places, rarity and your title")
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundStyle(Palette.ink2)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 4)
                    TagView(text: "Day 1", style: .soft)
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
                .background(Palette.lime.opacity(0.26))

                SoftDivider()

                ForEach(Array(JourneyReport.all.enumerated()), id: \.element.id) { index, journey in
                    journeyRow(journey)
                    if index != JourneyReport.all.count - 1 {
                        SoftDivider()
                    }
                }

                HStack(alignment: .top, spacing: 5) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.top, 1)
                    Text("Each finished trip is archived automatically, on your device.")
                        .font(.system(size: 8.5, weight: .medium))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .foregroundStyle(Palette.ink3)
                .padding(.horizontal, 11)
                .padding(.vertical, 9)
            }
            .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .clipShape(RoundedRectangle(cornerRadius: 21, style: .continuous))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        }
    }

    private func journeyRow(_ journey: JourneyReport) -> some View {
        Button {
            Haptics.tap()
            report = journey
        } label: {
            HStack(spacing: 9) {
                Text(model.say(journey.dates).uppercased())
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .frame(width: 50, alignment: .leading)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(model.say(journey.city)) · \(model.say(journey.title))")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(model.lang == .zh
                         ? "\(journey.newPlaces) 个新地点 · 最稀有 \(String(format: "%.1f", journey.rarePct))%"
                         : "\(journey.newPlaces) new places · rarest find \(String(format: "%.1f", journey.rarePct))%")
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer(minLength: 4)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Attraction reservations

    private var reservationsSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(
                title: "Attraction bookings",
                index: "02",
                trailing: model.lang == .zh ? "\(model.bookedAttractionCount)/\(model.attractions.count) 已预约" : "\(model.bookedAttractionCount)/\(model.attractions.count) booked"
            )

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(model.bookedAttractionCount) / \(model.attractions.count)")
                            .font(.system(size: 25, weight: .black).width(.condensed))
                            .foregroundStyle(Palette.ink)
                        Text("sights booked")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundStyle(Palette.ink2)
                        Spacer()
                        Text("\(Int(model.attractionProgress * 100))%")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink2)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Palette.cream)
                            Capsule()
                                .fill(Palette.lime)
                                .frame(width: max(6, geo.size.width * CGFloat(model.attractionProgress)))
                        }
                    }
                    .frame(height: 8)
                    .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.25), lineWidth: 0.8))
                }
                .padding(.top, 10)
                .padding(.bottom, 7)

                SoftDivider()

                ForEach(Array(model.attractions.enumerated()), id: \.element.id) { index, attraction in
                    attractionRow(attraction)
                    if index != model.attractions.count - 1 {
                        SoftDivider().padding(.leading, 50)
                    }
                }

                Button {
                    if model.pendingAttractions.isEmpty {
                        model.toast("All sights booked · Passes ready", icon: "checkmark.seal.fill")
                    } else {
                        model.bookAllAttractions()
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: model.pendingAttractions.isEmpty ? "checkmark.seal.fill" : "ticket.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(model.pendingAttractions.isEmpty
                             ? "All sights booked · View passes"
                             : "Book remaining \(model.pendingAttractions.count) sights")
                            .font(.system(size: 11.5, weight: .bold))
                    }
                    .foregroundStyle(model.pendingAttractions.isEmpty ? Palette.ink2 : Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Capsule().fill(model.pendingAttractions.isEmpty ? Palette.paperWarm : Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.vertical, 10)

                HStack(spacing: 5) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 9, weight: .bold))
                    Text("Show your pass at the gate and scan your ID to enter.")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                    Spacer(minLength: 0)
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        }
    }

    private func attractionRow(_ attraction: AttractionBooking) -> some View {
        Button {
            if attraction.booked {
                model.toast("Pass \(attraction.code ?? "ready") · Scan ID at the gate", icon: "ticket.fill")
            } else {
                model.bookAttraction(attraction)
            }
        } label: {
            HStack(spacing: 10) {
                IconBadge(icon: attraction.symbol, tint: Palette.ink, background: attractionFill(attraction.tint), size: 37)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(model.say(attraction.title))
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        if attraction.booked {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Palette.ok)
                        }
                    }
                    Text("\(model.tripStamp(max(0, attraction.day - 1)).date) · \(attraction.time)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                    Text(attraction.price)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.ink2)
                }

                Spacer(minLength: 4)

                if attraction.booked {
                    TagView(text: "Booked", style: .ok)
                } else {
                    Text("Book")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 11)
                        .frame(height: 29)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func attractionFill(_ tint: Int) -> Color {
        [Palette.pinkSoft, Palette.skySoft, Palette.mintSoft, Palette.mustardSoft, Palette.periwinkleSoft, Palette.limeSoft][tint % 6]
    }

    // MARK: Services

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(title: "Trip services", index: "03")
            VStack(spacing: 0) {
                serviceRow(icon: "waveform", tint: Palette.lime, title: "Offline phrase pack", detail: "Beijing · 86 phrases · 4.2 MB") {
                    model.translateMode = .offline
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        model.tab = .translate
                    }
                }
                SoftDivider().padding(.leading, 50)
                serviceRow(icon: "doc.richtext", tint: Palette.periwinkle, title: "Export trip", detail: "PDF / link · With map") {
                    model.toast("PDF trip created", icon: "doc.richtext.fill")
                }
                SoftDivider().padding(.leading, 50)
                serviceRow(icon: "phone.badge.waveform", tint: Palette.pink, title: "Emergency contacts", detail: "120 / 110 · 24h Chinese support") {
                    model.translateMode = .offline
                    model.scenario = .emergency
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        model.tab = .translate
                    }
                }
                SoftDivider().padding(.leading, 50)
                serviceRow(icon: "questionmark.bubble", tint: Palette.mustard, title: "Help & feedback", detail: "FAQs · Chat with Pico") {
                    model.openAssistant("Me · Help & feedback")
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        }
    }

    private func serviceRow(icon: String, tint: Color, title: String, detail: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                IconBadge(icon: icon, tint: Palette.ink, background: tint, size: 37)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Text(detail)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Palette.ink2)
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: External info

    private var externalSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(title: "External info", index: "04", trailing: "Optional")

            VStack(spacing: 0) {
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                        externalOpen.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        IconBadge(icon: "link", tint: Palette.ink2, background: Palette.cream, size: 34)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Flights & hotels")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Palette.ink2)
                            Text("Synced externally · Reference only, trip unchanged")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(Palette.ink3)
                        }
                        Spacer(minLength: 4)
                        TagView(text: "Synced", style: .soft)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Palette.ink3)
                            .rotationEffect(.degrees(externalOpen ? 180 : 0))
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if externalOpen {
                    SoftDivider().padding(.leading, 50)

                    externalRow(icon: "airplane", title: "Air China CA182", detail: "\(model.tripStamp(0).date) 08:45 → 11:20 · Capital T3", status: "Ticketed") {
                        model.toast("Flight details opened", icon: "airplane")
                    }
                    SoftDivider().padding(.leading, 50)
                    externalRow(icon: "building.2", title: "Mandarin Oriental Wangfujing", detail: "\(model.tripDateRange(count: model.tripDayCount)) · \(max(0, model.tripDayCount - 1)) nights · King room", status: "Confirmed") {
                        model.toast("Hotel confirmation opened", icon: "building.2.fill")
                    }

                    Text("From airline and hotel confirmations · Reference only; not used for alerts or bookings.")
                        .font(.system(size: 8.5, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paperWarm))
            .dashedBorder(color: Palette.ink.opacity(0.4), radius: 21)
        }
    }

    private func externalRow(icon: String, title: String, detail: String, status: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                IconBadge(icon: icon, tint: Palette.ink3, background: Palette.cream, size: 33)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(Palette.ink2)
                    Text(detail)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer(minLength: 4)
                TagView(text: status, style: .soft)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 9) {
            SectionHeading(title: "Notifications & preferences", index: "05")
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    IconBadge(icon: "bell", tint: Palette.ink, background: Palette.accentSoft, size: 37)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Notifications & Live Activities")
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        Text("Flight, ticket and nearby event alerts")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(Palette.ink3)
                    }
                    Spacer(minLength: 4)
                    Toggle("", isOn: $model.notificationsOn)
                        .labelsHidden()
                        .tint(Palette.ink)
                        .scaleEffect(0.82)
                }
                .padding(.vertical, 9)

                SoftDivider().padding(.leading, 50)

                HStack(spacing: 10) {
                    IconBadge(icon: "globe.asia.australia", tint: Palette.ink, background: Palette.periwinkleSoft, size: 37)
                    Text("Language")
                        .font(.system(size: 12.5, weight: .bold))
                        .foregroundStyle(Palette.ink)
                    Spacer()
                    Text("English")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                }
                .padding(.vertical, 9)
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
            .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        }
    }

    // MARK: Legal

    private var legalSection: some View {
        VStack(spacing: 0) {
            legalRow(title: "Privacy policy") { legal = .privacy }
            SoftDivider().padding(.leading, 16)
            legalRow(title: "Terms of service") { legal = .terms }
        }
        .padding(.horizontal, 13)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
    }

    private func legalRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(Palette.ink2)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        VStack(spacing: 6) {
            DoodleView(kind: .squiggle, color: Palette.ink.opacity(0.28), lineWidth: 1.2)
                .frame(width: 40, height: 9)
            Text("RoamChina · v1.0")
                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                .foregroundStyle(Palette.ink3)
            Text("Made for slow travel · In Beijing")
                .font(.system(size: 10.5, weight: .medium, design: .serif).italic())
                .foregroundStyle(Palette.ink3.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .padding(.bottom, 4)
    }
}

// MARK: - Journey report sheet

struct JourneyReportSheet: View {
    var journey: JourneyReport
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 13) {
                header
                hero
                stats
                rarityCard
                award
                Text("\(journey.places) places visited in total · archived when the trip ended · kept on your device")
                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 2)
                actions
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "Journey archive · \(journey.dates)")
                Text("\(journey.city) trip report")
                    .font(.system(size: 27, weight: .black))
                    .tracking(-0.5)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            Spacer(minLength: 4)
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

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(Palette.paper.opacity(0.32))
                .frame(width: 120, height: 120)
                .offset(x: 34, y: -38)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 7, weight: .black))
                    Text("TRIP COMPLETE")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundStyle(Palette.paper)
                .padding(.horizontal, 8)
                .frame(height: 20)
                .background(Capsule().fill(Palette.ink))

                Text(journey.title)
                    .font(.system(size: 25, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)
                    .padding(.top, 10)

                Text(journey.blurb)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 6)

                HStack(spacing: 4) {
                    ForEach(journey.stamps, id: \.self) { stamp in
                        Text(stamp)
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Palette.limeSoft))
                            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.7), lineWidth: 0.8))
                    }
                }
                .padding(.top, 9)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(journey.color))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 3)
    }

    private var stats: some View {
        HStack(spacing: 6) {
            reportStat(value: "\(journey.newPlaces)", label: "new places\nunlocked")
            reportStat(value: String(format: "%.1f", journey.km), label: "km\nwalked")
            reportStat(value: "Top \(journey.rank)%", label: "\(journey.city)\nexplorers")
        }
    }

    private func reportStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .tracking(-0.6)
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.ink3)
                .lineSpacing(1.5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2)
    }

    private var rarityCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How rare was your route?")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Palette.ink)
            Text("Share of RoamChina travelers who unlocked each place")
                .font(.system(size: 8.5, weight: .medium))
                .foregroundStyle(Palette.ink3)
                .padding(.top, 2)

            VStack(spacing: 0) {
                ForEach(journey.rarities) { item in
                    HStack(spacing: 8) {
                        Text(item.name)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Palette.ink)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        ZStack(alignment: .leading) {
                            Capsule().fill(Palette.ink.opacity(0.1))
                            Capsule()
                                .fill(Palette.coral)
                                .frame(width: CGFloat(66 * max(0.04, item.pct / 100)))
                        }
                        .frame(width: 66, height: 5)
                        Text("\(item.pct, specifier: "%.1f")%")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.ink2)
                            .frame(width: 34, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.top, 7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
    }

    private var award: some View {
        HStack(spacing: 9) {
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Palette.ink)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Palette.lime))
            VStack(alignment: .leading, spacing: 2) {
                Text(journey.rare)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(Palette.paper)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Only \(journey.rarePct, specifier: "%.1f")% of travelers found this — your rarest unlock.")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(Palette.paper.opacity(0.65))
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Palette.ink))
    }

    private var actions: some View {
        HStack(spacing: 9) {
            Button {
                model.toast("Report saved to your archive", icon: "tray.and.arrow.down.fill")
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "tray.and.arrow.down")
                        .font(.system(size: 10, weight: .bold))
                    Text("Save")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())

            Button {
                model.toast("Report link copied · \(journey.title)", icon: "square.and.arrow.up")
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 10, weight: .bold))
                    Text("Share report")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.top, 2)
    }
}
