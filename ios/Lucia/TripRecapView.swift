import SwiftUI

// MARK: - Model

private struct RecapHidden: Identifiable {
    let id = UUID()
    let name: String
    let pct: Double
}

private struct RecapSolved: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let note: String
}

private struct RecapFood: Identifiable {
    let id = UUID()
    let name: String
    let place: String
    let image: String
    let note: String
}

private struct RecapData {
    var city = "Beijing"
    var dates = "10/15 – 10/18"
    var year = "2026"
    var title = "The Central Axis Cartographer"
    var kicker = "Your Beijing chapter"
    var blurb = "Four days, seventeen stops, one straight line through the middle of Beijing — and every side door that opened along the way."
    var quote = "You walked the axis like a local: early gates, long lunches, and never a queue longer than twelve minutes."
    var rank = 7
    var days = 4
    var places = 17
    var newPlaces = 13
    var km = 31.8
    var steps = "41,600"
    var onFeet = "9h 20m"
    var rare = "Corner Tower moat walk"
    var rarePct = 2.7
    var hidden: [RecapHidden] = []
    var solved: [RecapSolved] = []
    var unlocked: [String] = []
    var foods: [RecapFood] = []
    var extraFoods: [String] = []

    static let beijing: RecapData = {
        var data = RecapData()
        data.hidden = [
            RecapHidden(name: "Corner Tower moat walk", pct: 2.7),
            RecapHidden(name: "Zhihua Temple side courtyard", pct: 4.9),
            RecapHidden(name: "Yandai Xiejie back lane", pct: 12),
            RecapHidden(name: "Jingshan east slope", pct: 23),
            RecapHidden(name: "Shichahai west bank", pct: 31),
            RecapHidden(name: "Forbidden City · 09:00 gate", pct: 88)
        ]
        data.solved = [
            RecapSolved(icon: "ticket.fill", title: "The palace sold out at 13:00", note: "Pico moved you to the 09:00 gate — inside before the tour groups."),
            RecapSolved(icon: "arrow.triangle.swap", title: "Chang'an Avenue closed for the marathon", note: "Rerouted through the hutongs; you arrived 20 minutes early."),
            RecapSolved(icon: "sun.max.fill", title: "Rain forecast on Great Wall morning", note: "Swapped Days 2 and 3. You climbed Badaling in full sun."),
            RecapSolved(icon: "fork.knife", title: "Siji Minfu had a 90-minute queue", note: "A table was held for 11:20. Duck on the table by 11:35."),
            RecapSolved(icon: "clock.fill", title: "Jingshan last entry in 11 minutes", note: "Found the east gate and made sunset with 4 minutes to spare."),
            RecapSolved(icon: "person.2.fill", title: "Two passports, one booking", note: "Split the reservation and kept both seats together."),
            RecapSolved(icon: "figure.walk", title: "Shichahai kept pulling the route west", note: "Moved it to 13:00 — 1.2 km less on tired feet.")
        ]
        data.unlocked = [
            "Tiananmen Square", "Forbidden City", "Jingshan Park", "Shichahai", "Nanluoguxiang",
            "Drum & Bell Towers", "Badaling Great Wall", "Summer Palace", "National Museum of China",
            "Qianmen Street", "Olympic Forest Park", "Daoxiangcun", "Hutong coffee"
        ]
        data.foods = [
            RecapFood(name: "Peking duck", place: "Siji Minfu", image: "post-n3", note: "Crackled at 11:35, no queue."),
            RecapFood(name: "Copper-pot hotpot", place: "Manhengji", image: "post-n10", note: "Hand-cut lamb, sesame dip."),
            RecapFood(name: "Daoxiangcun pastries", place: "Qianmen", image: "post-n7", note: "Loose ones, not the gift box."),
            RecapFood(name: "Hutong coffee", place: "Qianmen back lane", image: "post-n4", note: "Afternoon light included.")
        ]
        data.extraFoods = ["Zhajiang noodles", "Jianbing", "Tanghulu", "Sour plum drink"]
        return data
    }()
}

private enum RecapPalette {
    static let bg = Color(hex: 0x16130C)
    static let cream = Color(hex: 0xF4ECDC)
    static let dim = Color(hex: 0xF4ECDC).opacity(0.58)
    static let faint = Color(hex: 0xF4ECDC).opacity(0.36)
    static let line = Color(hex: 0xF4ECDC).opacity(0.14)
    static let fill = Color(hex: 0xF4ECDC).opacity(0.055)
    static let accent = Palette.lime
}

// MARK: - Screen

struct TripRecapView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    private let data = RecapData.beijing
    private let total = 8

    private var slide: Int { model.recapSlide }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: Binding(
                get: { model.recapSlide },
                set: { model.recapSlide = $0 }
            )) {
                coverSlide.tag(0)
                titleSlide.tag(1)
                hiddenSlide.tag(2)
                solvedSlide.tag(3)
                placesSlide.tag(4)
                foodSlide.tag(5)
                distanceSlide.tag(6)
                finalSlide.tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            footer
        }
        .background(RecapPalette.bg.ignoresSafeArea())
        .environment(\.colorScheme, .dark)
    }

    private var cityLabel: String {
        model.lang == .zh ? L10n.text(data.city, model.lang) : data.city
    }

    private func t(_ key: String) -> String {
        L10n.text(key, model.lang)
    }

    // MARK: Header & footer

    private var header: some View {
        HStack(spacing: 10) {
            Button {
                Haptics.tap()
                model.recapOpen = false
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(RecapPalette.cream)
                    .frame(width: 27, height: 27)
                    .background(Circle().fill(RecapPalette.fill))
                    .overlay(Circle().strokeBorder(RecapPalette.line, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("Close recap")

            Text("TRIP WRAP-UP")
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(1.8)
                .foregroundStyle(RecapPalette.dim)

            Spacer()

            (Text(String(format: "%02d", slide + 1))
                .foregroundStyle(RecapPalette.cream)
             + Text(" / ")
                .foregroundStyle(RecapPalette.accent)
             + Text(String(format: "%02d", total))
                .foregroundStyle(RecapPalette.dim))
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(1)

            LanguagePill(dark: true)
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .padding(.top, 8)
        .padding(.bottom, 6)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { index in
                    Button {
                        guard slide != index else { return }
                        Haptics.tap()
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                            model.recapSlide = index
                        }
                    } label: {
                        Capsule()
                            .fill(index == slide ? RecapPalette.accent : RecapPalette.cream.opacity(0.25))
                            .frame(width: index == slide ? 17 : 5, height: 5)
                            .frame(height: 20)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Slide \(index + 1)")
                }
            }

            Spacer()

            Button {
                Haptics.tap()
                if slide >= total - 1 {
                    model.recapOpen = false
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                        model.recapSlide += 1
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(slide >= total - 1 ? "Finish" : "Next")
                        .font(.system(size: 10, weight: .black))
                    Image(systemName: slide >= total - 1 ? "checkmark" : "arrow.right")
                        .font(.system(size: 9, weight: .black))
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(Capsule().fill(RecapPalette.accent))
                .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    // MARK: Slides

    private var coverSlide: some View {
        ZStack(alignment: .topTrailing) {
            Text(data.year)
                .font(.system(size: 150, weight: .black))
                .tracking(-8)
                .foregroundStyle(RecapPalette.cream.opacity(0.04))
                .offset(x: 24, y: 96)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("TRIP WRAP-UP · \(data.year)")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(1.6)
                    .foregroundStyle(RecapPalette.dim)
                    .padding(.top, 4)

                Spacer()

                VStack(spacing: 2) {
                    Text("WALKED")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(1)
                    Text("\(data.km, specifier: "%.1f") KM")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                }
                .foregroundStyle(RecapPalette.accent)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(RoundedRectangle(cornerRadius: 10).fill(RecapPalette.fill))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(RecapPalette.accent, lineWidth: 1.2)
                )
                .rotationEffect(.degrees(6))
            }

            Spacer(minLength: 18)

            Text(cityLabel.uppercased())
                .font(.system(size: 66, weight: .black))
                .tracking(-3.5)
                .foregroundStyle(RecapPalette.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(data.dates)
                    .foregroundStyle(RecapPalette.accent)
                Text("\(data.days) days · \(data.places) stops")
                    .foregroundStyle(RecapPalette.dim)
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .tracking(0.4)
            .padding(.top, 8)

            RouteSquiggle()
                .stroke(RecapPalette.accent.opacity(0.8), style: StrokeStyle(lineWidth: 2.4, lineCap: .round, dash: [1, 7]))
                .frame(height: 64)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 0) {
                Text("The city,")
                    .font(.system(size: 30, weight: .black))
                    .tracking(-1.2)
                    .foregroundStyle(RecapPalette.cream)
                Text("one step at a time.")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .italic()
                    .foregroundStyle(RecapPalette.accent)
            }
            .lineSpacing(-2)

            Text(data.blurb)
                .font(.system(size: 11))
                .lineSpacing(3)
                .foregroundStyle(RecapPalette.dim)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            Spacer(minLength: 10)

            HStack(spacing: 6) {
                Image(systemName: "hand.draw")
                    .font(.system(size: 10, weight: .bold))
                Text("Swipe or tap next")
                    .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                    .tracking(1.2)
            }
            .foregroundStyle(RecapPalette.cream.opacity(0.45))
            .frame(maxWidth: .infinity)
            .padding(.bottom, 6)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        }
    }

    private var titleSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                slideTop("YOUR EXPLORER TITLE", trailing: "OF THE TRIP", icon: "sparkles")

                VStack(alignment: .leading, spacing: 8) {
                    Text("You are officially")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .tracking(0.8)
                        .foregroundStyle(RecapPalette.dim)
                    Text(t(data.title))
                        .font(.system(size: 36, weight: .black))
                        .tracking(-1.6)
                        .foregroundStyle(RecapPalette.cream)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Rectangle()
                    .fill(RecapPalette.accent)
                    .frame(width: 42, height: 2)

                HStack(spacing: 12) {
                    Text("Top \(data.rank)%")
                        .font(.system(size: 30, weight: .black))
                        .tracking(-1.4)
                        .foregroundStyle(RecapPalette.accent)
                    (Text("of \(cityLabel) explorers\n")
                        .foregroundColor(RecapPalette.dim)
                     + Text("this season")
                        .foregroundColor(RecapPalette.dim))
                        .font(.system(size: 8, weight: .semibold, design: .monospaced))
                        .tracking(0.4)
                        .textCase(.uppercase)
                        .lineSpacing(2)
                }

                Text(data.quote)
                    .font(.system(size: 12.5))
                    .lineSpacing(4)
                    .foregroundStyle(RecapPalette.dim)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    recapStamp(icon: "figure.walk", text: String(format: "%.1f km", data.km))
                    recapStamp(icon: "mappin", text: "\(data.newPlaces) new places")
                    recapStamp(icon: "star.fill", text: String(format: "rarest %.1f%%", data.rarePct))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var hiddenSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                slideTop("THE ROAD LESS WALKED", count: 3)

                bigLine("\(data.hidden.count)", caption: "places only a few\ntravelers find")

                (
                    Text("Your rarest stop was ")
                        .foregroundColor(RecapPalette.dim)
                    + Text(t(data.rare))
                        .foregroundColor(RecapPalette.cream).bold()
                    + Text(" — only ")
                        .foregroundColor(RecapPalette.dim)
                    + Text("\(data.rarePct, specifier: "%.1f")%")
                        .foregroundColor(RecapPalette.accent).bold()
                    + Text(" of RoamChina travelers have unlocked it.")
                        .foregroundColor(RecapPalette.dim)
                )
                .font(.system(size: 11.5))
                .lineSpacing(3)

                VStack(spacing: 11) {
                    ForEach(data.hidden) { item in
                        rarityRow(item)
                    }
                }
                .padding(.top, 2)

                note("Share of travelers who checked in here — lower is rarer.", icon: "info.circle")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var solvedSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                slideTop("PICO’S QUIET WINS", count: 4)

                bigLine(String(format: "%02d", data.solved.count), caption: "problems handled before\nthey became stories")

                VStack(spacing: 7) {
                    ForEach(data.solved) { item in
                        HStack(alignment: .top, spacing: 9) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(RecapPalette.cream.opacity(0.1))
                                .frame(width: 27, height: 27)
                                .overlay(
                                    Image(systemName: item.icon)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(RecapPalette.accent)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(item.title))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(RecapPalette.cream)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text(LocalizedStringKey(item.note))
                                    .font(.system(size: 9))
                                    .lineSpacing(1.5)
                                    .foregroundStyle(RecapPalette.dim)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 4)

                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .black))
                                .foregroundStyle(RecapPalette.accent)
                                .padding(.top, 4)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(RecapPalette.fill))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(RecapPalette.cream.opacity(0.11), lineWidth: 1)
                        )
                    }
                }

                note("No refunds, no rebookings, no lost afternoons.", icon: "sparkles")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var placesSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                slideTop("NEW GROUND", count: 5)

                bigLine("\(data.newPlaces)", caption: "new places unlocked\non this trip")

                Text("\(data.places) stops in total. Some were on every list; the good ones were not.")
                    .font(.system(size: 11))
                    .lineSpacing(3)
                    .foregroundStyle(RecapPalette.dim)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 6)], spacing: 6) {
                    ForEach(Array(data.unlocked.enumerated()), id: \.offset) { index, place in
                        HStack(spacing: 7) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundStyle(index % 3 == 2 ? Palette.coral : RecapPalette.accent)
                            Text(LocalizedStringKey(place))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(RecapPalette.cream)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(RecapPalette.fill))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(RecapPalette.line, lineWidth: 1)
                        )
                    }
                }
                .padding(.top, 2)

                note("First-time check-ins, collected into your Beijing passport.", icon: "mappin")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var foodSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                slideTop("THE EATING PART", count: 6)

                bigLine("\(data.foods.count)", caption: "meals worth the walk")

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    ForEach(data.foods) { food in
                        VStack(alignment: .leading, spacing: 0) {
                            Image(food.image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 74)
                                .clipped()
                                .overlay(alignment: .bottomLeading) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(RecapPalette.cream)
                                        .padding(4)
                                        .background(Circle().fill(Color.black.opacity(0.55)))
                                        .padding(6)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(food.name))
                                    .font(.system(size: 9.5, weight: .bold))
                                    .foregroundStyle(RecapPalette.cream)
                                Text(LocalizedStringKey("\(food.place) · \(food.note)"))
                                    .font(.system(size: 7.5))
                                    .lineSpacing(1.5)
                                    .foregroundStyle(RecapPalette.dim)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(8)
                        }
                        .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(RecapPalette.fill))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                .strokeBorder(RecapPalette.cream.opacity(0.13), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                }

                HStack(spacing: 5) {
                    Text("Also eaten")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(1)
                        .foregroundStyle(RecapPalette.dim)
                    ForEach(data.extraFoods, id: \.self) { food in
                        Text(LocalizedStringKey(food))
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(RecapPalette.dim)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .overlay(
                                Capsule().strokeBorder(RecapPalette.cream.opacity(0.28), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                            )
                    }
                }
                .padding(.top, 2)

                note("Every one within a 12-minute walk of the route.", icon: "heart")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var distanceSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                slideTop("MILES IN YOUR SHOES", count: 7)

                HStack(alignment: .lastTextBaseline, spacing: 12) {
                    Text("\(data.km, specifier: "%.1f")")
                        .font(.system(size: 80, weight: .black))
                        .tracking(-5)
                        .foregroundStyle(RecapPalette.accent)
                    (Text("km\n")
                        .foregroundColor(RecapPalette.cream)
                     + Text("on foot")
                        .foregroundColor(RecapPalette.cream))
                        .font(.system(size: 13, weight: .heavy))
                        .lineSpacing(1)
                        .padding(.bottom, 4)
                }

                HStack(spacing: 0) {
                    Text("START")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundStyle(RecapPalette.dim)
                        .padding(.horizontal, 5)
                        .background(RecapPalette.bg)

                    ZStack {
                        Rectangle()
                            .fill(RecapPalette.cream.opacity(0.3))
                            .frame(height: 1)
                        HStack {
                            ForEach(0..<4, id: \.self) { _ in
                                Circle()
                                    .strokeBorder(RecapPalette.accent, lineWidth: 1.4)
                                    .background(Circle().fill(RecapPalette.bg))
                                    .frame(width: 8, height: 8)
                                Spacer()
                            }
                        }
                    }

                    Text(data.dates.components(separatedBy: "–").last?.trimmingCharacters(in: .whitespaces) ?? "10/18")
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundStyle(RecapPalette.dim)
                        .padding(.horizontal, 5)
                        .background(RecapPalette.bg)
                }
                .frame(height: 22)

                HStack(spacing: 6) {
                    distanceStat(data.steps, label: "steps")
                    distanceStat(data.onFeet, label: "on your feet")
                    distanceStat("\(data.days)", label: "days out")
                }

                Text("About three-quarters of a marathon — in one pair of shoes, with coffee stops.")
                    .font(.system(size: 13.5))
                    .lineSpacing(4)
                    .foregroundStyle(RecapPalette.cream)

                note("More than 82% of RoamChina travelers walk on a \(data.days)-day trip.", icon: "figure.walk")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 14)
        }
    }

    private var finalSlide: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .black))
                    Text("TRIP COMPLETE")
                        .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                }
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(Capsule().fill(RecapPalette.accent))
                .padding(.top, 6)

                VStack(alignment: .leading, spacing: 0) {
                    Text("The city")
                        .font(.system(size: 42, weight: .black))
                        .tracking(-2)
                        .foregroundStyle(RecapPalette.cream)
                    Text("remembers.")
                        .font(.system(size: 42, weight: .semibold, design: .serif))
                        .italic()
                        .foregroundStyle(RecapPalette.accent)
                }
                .padding(.top, 14)

                Text("This one is archived in Journey reports, with the title, the rare places and every meal attached.")
                    .font(.system(size: 12.5))
                    .lineSpacing(4)
                    .foregroundStyle(RecapPalette.dim)
                    .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("\(cityLabel) · \(data.dates)")
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(0.6)
                        .foregroundStyle(Palette.ink3)
                    Text(t(data.title))
                        .font(.system(size: 19, weight: .black))
                        .tracking(-0.5)
                        .foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 8) {
                        finalStat("\(data.newPlaces)", "new places")
                        finalStat(String(format: "%.1f", data.km), "km walked")
                        finalStat("Top \(data.rank)%", "explorers")
                    }
                    .padding(.top, 2)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(RecapPalette.cream)
                        .shadow(color: .black.opacity(0.3), radius: 0, x: 6, y: 6)
                )
                .rotationEffect(.degrees(-1.1))
                .padding(.top, 18)

                VStack(spacing: 7) {
                    Button {
                        Haptics.success()
                        model.toast("Recap link copied · \(t(data.title))", icon: "square.and.arrow.up")
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 11, weight: .bold))
                            Text("Share recap")
                                .font(.system(size: 11, weight: .black))
                        }
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Capsule().fill(RecapPalette.accent))
                        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())

                    Button {
                        Haptics.tap()
                        model.recapOpen = false
                        dismiss()
                    } label: {
                        HStack(spacing: 5) {
                            Text("Back to your trip")
                                .font(.system(size: 10, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 9, weight: .black))
                        }
                        .foregroundStyle(RecapPalette.cream)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Capsule().fill(RecapPalette.fill))
                        .overlay(Capsule().strokeBorder(RecapPalette.cream.opacity(0.28), lineWidth: 1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.top, 16)

                note("Kept on your device · nothing shared unless you tap share.", icon: "lock")
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: Pieces

    private func slideTop(_ kicker: String, trailing: String? = nil, icon: String? = nil, count: Int? = nil) -> some View {
        HStack {
            Text(LocalizedStringKey(kicker))
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .tracking(1.8)
                .foregroundStyle(RecapPalette.accent)

            Spacer()

            if let trailing {
                HStack(spacing: 3) {
                    if let icon {
                        Image(systemName: icon).font(.system(size: 7, weight: .bold))
                    }
                    Text(LocalizedStringKey(trailing))
                        .font(.system(size: 7, weight: .bold, design: .monospaced))
                        .tracking(0.8)
                }
                .foregroundStyle(RecapPalette.cream)
                .padding(.horizontal, 7)
                .padding(.vertical, 3.5)
                .overlay(Capsule().strokeBorder(RecapPalette.cream.opacity(0.3), lineWidth: 1))
            }

            if let count {
                Text("\(String(format: "%02d", count)) / 08")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(RecapPalette.dim)
            }
        }
        .padding(.bottom, 2)
    }

    private func bigLine(_ number: String, caption: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            Text(number)
                .font(.system(size: 62, weight: .black))
                .tracking(-3.5)
                .foregroundStyle(RecapPalette.accent)
            Text(LocalizedStringKey(caption))
                .font(.system(size: 11, weight: .bold))
                .lineSpacing(2)
                .foregroundStyle(RecapPalette.dim)
                .padding(.bottom, 3)
        }
    }

    private func rarityRow(_ item: RecapHidden) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(LocalizedStringKey(item.name))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(RecapPalette.cream)
                    .lineLimit(2)
                Spacer()
                Text("\(item.pct, specifier: "%.1f")%")
                    .font(.system(size: 9, weight: .heavy, design: .monospaced))
                    .foregroundStyle(RecapPalette.accent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(RecapPalette.cream.opacity(0.13))
                    Capsule()
                        .fill(LinearGradient(colors: [RecapPalette.accent, Palette.coral], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * max(0.03, min(1, item.pct / 100)))
                }
            }
            .frame(height: 5)

            Text(LocalizedStringKey(item.pct < 10 ? "A true side door" : item.pct < 50 ? "Known by the curious" : "A classic, well earned"))
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .foregroundStyle(RecapPalette.faint)
        }
    }

    private func recapStamp(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(RecapPalette.cream)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Capsule().fill(RecapPalette.fill))
        .overlay(Capsule().strokeBorder(RecapPalette.cream.opacity(0.28), lineWidth: 1))
    }

    private func note(_ text: LocalizedStringKey, icon: String) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(RecapPalette.faint)
    }

    private func distanceStat(_ value: String, label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .black))
                .tracking(-0.5)
                .foregroundStyle(RecapPalette.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 7, weight: .semibold, design: .monospaced))
                .tracking(0.5)
                .textCase(.uppercase)
                .foregroundStyle(RecapPalette.dim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(RecapPalette.fill))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(RecapPalette.line, lineWidth: 1)
        )
    }

    private func finalStat(_ value: String, _ label: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 15, weight: .black))
                .tracking(-0.4)
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 7.5, weight: .semibold, design: .monospaced))
                .textCase(.uppercase)
                .foregroundStyle(Palette.ink3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Route doodle

private struct RouteSquiggle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 4, y: rect.height * 0.78))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.36, y: rect.height * 0.3),
            control1: CGPoint(x: rect.width * 0.14, y: rect.height * 0.78),
            control2: CGPoint(x: rect.width * 0.14, y: rect.height * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.68, y: rect.height * 0.66),
            control1: CGPoint(x: rect.width * 0.5, y: rect.height * 0.44),
            control2: CGPoint(x: rect.width * 0.56, y: rect.height * 0.9)
        )
        path.addCurve(
            to: CGPoint(x: rect.width - 4, y: rect.height * 0.32),
            control1: CGPoint(x: rect.width * 0.82, y: rect.height * 0.4),
            control2: CGPoint(x: rect.width * 0.88, y: rect.height * 0.16)
        )
        return path
    }
}
