import SwiftUI

struct ForumChannelView: View {
    var channel: ForumFilter

    var body: some View {
        Group {
            switch channel {
            case .restaurant:
                RestaurantChannel()
            case .spot:
                SpotChannel()
            case .gift:
                GiftChannel()
            case .route:
                RouteChannel()
            case .event:
                EventChannel()
            case .all:
                EmptyView()
            }
        }
        .background(Palette.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Shared header

struct ChannelHeader: View {
    var eyebrow: String
    var sticker: String
    var title: String
    var subtitle: String
    var fill: Color
    var actionTitle: String?
    var actionIcon: String
    var action: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    init(
        eyebrow: String,
        sticker: String,
        title: String,
        subtitle: String,
        fill: Color,
        actionTitle: String? = nil,
        actionIcon: String = "plus",
        action: (() -> Void)? = nil
    ) {
        self.eyebrow = eyebrow
        self.sticker = sticker
        self.title = title
        self.subtitle = subtitle
        self.fill = fill
        self.actionTitle = actionTitle
        self.actionIcon = actionIcon
        self.action = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    Haptics.tap()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 9, weight: .black))
                        Text("Community")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.95))

                Spacer()

                if let actionTitle, let action {
                    Button {
                        Haptics.tap()
                        action()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: actionIcon)
                                .font(.system(size: 9, weight: .bold))
                            Text(actionTitle)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 11)
                        .frame(height: 32)
                        .background(Capsule().fill(Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.95))
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Eyebrow(text: eyebrow)
                    StickerLabel(text: sticker, fill: fill, rotation: -3)
                }
                Text(title)
                    .font(.system(size: 29, weight: .black))
                    .tracking(-0.6)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
                Text(subtitle)
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
        }
    }
}

// MARK: - Restaurant

private struct RestaurantChannel: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPlace: ForumPlace?
    @State private var showCompose = false

    private var restaurants: [ForumPlace] {
        model.forumPlaces
            .filter { $0.kind == .restaurant }
            .sorted { $0.heat > $1.heat }
    }

    private let authors = ["Lina", "Zhou", "Ken"]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                ChannelHeader(
                    eyebrow: "COMMUNITY / EAT",
                    sticker: "EAT",
                    title: "Taste is Beijing's first impression",
                    subtitle: "This week's heat · From 4,208 saves and check-ins",
                    fill: Palette.mustard,
                    actionTitle: "Share",
                    actionIcon: "square.and.pencil",
                    action: { showCompose = true }
                )

                rankingCard
                communityShares
                shareButton
                tipCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
        .sheet(item: $selectedPlace) { place in
            PlaceSheet(place: place)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $showCompose) {
            ComposePost(initialTag: "Food")
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
    }

    private var rankingCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Eyebrow(text: "HEAT CHART / THIS WEEK")
                Spacer()
                Text("Updated every 2 hr")
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
            .padding(.bottom, 9)

            ForEach(Array(restaurants.enumerated()), id: \.element.id) { index, place in
                Button {
                    Haptics.tap()
                    selectedPlace = place
                } label: {
                    HStack(spacing: 10) {
                        Text(String(format: "%02d", index + 1))
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(index == 0 ? Palette.paper : Palette.ink)
                            .frame(width: 27, height: 27)
                            .background(Circle().fill(index == 0 ? Palette.ink : Palette.paperWarm))
                            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))

                        PhotoTile(symbol: place.symbol, tint: place.tint, height: 52)
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .strokeBorder(Palette.ink, lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 5) {
                                Text(place.title)
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundStyle(Palette.ink)
                                    .lineLimit(1)
                                if index == 0 {
                                    TagView(text: "Hottest", style: .accent)
                                }
                            }
                            Text("\(place.area) · \(place.price)")
                                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                                .foregroundStyle(Palette.ink3)
                                .lineLimit(1)
                            HStack(spacing: 5) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 7, weight: .bold))
                                    .foregroundStyle(place.heat >= 90 ? Palette.coral : Palette.mustard)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Palette.cream).frame(width: 78, height: 4)
                                    Capsule()
                                        .fill(place.heat >= 90 ? Palette.coral : Palette.mustard)
                                        .frame(width: 78 * CGFloat(place.heat) / 100, height: 4)
                                }
                                Text("\(place.heat)")
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Palette.ink2)
                            }
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 8.5, weight: .black))
                            .foregroundStyle(Palette.ink3)
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index != restaurants.count - 1 {
                    SoftDivider()
                }
            }
        }
        .padding(13)
        .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 3)
    }

    private var communityShares: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Latest shares")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("From check-ins")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(restaurants.prefix(3).enumerated()), id: \.element.id) { index, place in
                        Button {
                            Haptics.tap()
                            selectedPlace = place
                        } label: {
                            shareCard(place, author: authors[index % authors.count], tint: index)
                        }
                        .buttonStyle(PressableButtonStyle(scale: 0.98))
                    }
                }
                .padding(.vertical, 3)
            }
        }
    }

    private func shareCard(_ place: ForumPlace, author: String, tint: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(String(author.prefix(1)))
                    .font(.system(size: 8.5, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(tint == 0 ? Palette.pink : (tint == 1 ? Palette.periwinkle : Palette.mint)))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.9))
                Text(author)
                    .font(.system(size: 9.5, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                Spacer(minLength: 0)
                TagView(text: "Checked in", style: .ok)
            }

            Text("“\(place.note)”")
                .font(.system(size: 11.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .lineSpacing(3)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Text(place.title)
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "heart.fill")
                    .font(.system(size: 7))
                    .foregroundStyle(Palette.accent)
                Text(place.likes)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
        }
        .padding(12)
        .frame(width: 250, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.09), radius: 0, x: 0, y: 2.5)
    }

    private var shareButton: some View {
        Button {
            Haptics.tap()
            showCompose = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "plus.bubble.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("Share a favorite restaurant")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Capsule().fill(Palette.paperWarm))
            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.7), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3])))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var tipCard: some View {
        HStack(spacing: 9) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Palette.mint))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text("Off-peak beats queuing")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("Take a number at Siji Minfu after 15:00, or Man Heng Ji before 17:00 — shortest waits.")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.limeSoft))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
    }
}

// MARK: - Spots

private struct SpotChannel: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPlace: ForumPlace?
    @State private var mood = "All"

    private let moods = ["All", "Sunset", "Quiet", "Family", "Architecture", "Boating"]

    private var spots: [ForumPlace] {
        let list = model.forumPlaces.filter { $0.kind == .spot }
        guard mood != "All" else { return list }
        return list.filter { $0.tags.contains(mood) }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                ChannelHeader(
                    eyebrow: "COMMUNITY / SEE",
                    sticker: "SEE",
                    title: "Where to see Beijing",
                    subtitle: "Pick by sunset, quiet, family or architecture · 3 this week",
                    fill: Palette.mint
                )

                moodRow

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                    spacing: 12
                ) {
                    ForEach(spots) { place in
                        spotCard(place)
                    }
                }

                if spots.isEmpty {
                    Text("No picks under this theme yet — try another filter.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                        .padding(.vertical, 16)
                }

                sunsetBanner
                askCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
        .sheet(item: $selectedPlace) { place in
            PlaceSheet(place: place)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
    }

    private var moodRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(moods, id: \.self) { option in
                    Chip(title: option, selected: mood == option) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            mood = option
                        }
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    private func spotCard(_ place: ForumPlace) -> some View {
        let saved = model.savedPlaces.contains(place.id)
        return VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topTrailing) {
                PhotoTile(symbol: place.symbol, tint: place.tint, height: 122)
                    .frame(height: 122)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        Text("Best · \(place.bestTime)")
                            .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                            .foregroundStyle(Palette.paper)
                            .padding(.horizontal, 7)
                            .frame(height: 21)
                            .background(Capsule().fill(Palette.ink.opacity(0.78)))
                            .padding(7)
                    }

                Button {
                    model.toggleSaved(place)
                    Haptics.tap()
                } label: {
                    Image(systemName: saved ? "heart.fill" : "heart")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(saved ? Palette.coral : Palette.ink)
                        .frame(width: 27, height: 27)
                        .background(Circle().fill(Palette.paper))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(6)
            }

            Text(place.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
            Text(place.area)
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)
            HStack(spacing: 4) {
                TagView(text: place.tags.first ?? "Pick", style: .soft)
                Spacer(minLength: 0)
                Text(place.price)
                    .font(.system(size: 9.5, weight: .black))
                    .foregroundStyle(Palette.ink)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        .contentShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .onTapGesture {
            Haptics.tap()
            selectedPlace = place
        }
    }

    private var sunsetBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "sun.horizon.fill")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Palette.mustard))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
            VStack(alignment: .leading, spacing: 2) {
                Text("Sunset this week 17:18")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("Reach Jingshan's Wanchun Pavilion by 16:40 to claim a spot on the east side.")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
            TagView(text: "Best 90 min", style: .warn)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.mustardSoft))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
    }

    private var askCard: some View {
        HStack(spacing: 9) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.ink)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Palette.lime))
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
            VStack(alignment: .leading, spacing: 2) {
                Text("Fit 3 sights into one day?")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("Pico plans around sunset, closing days and transit.")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
            Image(systemName: "arrow.right")
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(Palette.ink)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.limeSoft))
        .dashedBorder(color: Palette.ink.opacity(0.5), radius: 17)
        .contentShape(Rectangle())
        .onTapGesture {
            model.openAssistant("Community · Sight picks")
        }
    }
}

// MARK: - Gifts

private struct GiftChannel: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPlace: ForumPlace?
    @State private var showCompose = false

    private var gifts: [ForumPlace] {
        model.forumPlaces.filter { $0.kind == .gift }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                ChannelHeader(
                    eyebrow: "COMMUNITY / TAKE HOME",
                    sticker: "GIFT",
                    title: "Beijing to take home",
                    subtitle: "What locals buy · Check-in friendly, packs flat",
                    fill: Palette.pink,
                    actionTitle: "Share",
                    actionIcon: "square.and.pencil",
                    action: { showCompose = true }
                )

                compareCard

                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Text("Local picks")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text("\(gifts.count) items · Most saved")
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }

                    ForEach(gifts) { place in
                        giftRow(place)
                    }
                }

                packButton
                shippingTip
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
        .sheet(item: $selectedPlace) { place in
            PlaceSheet(place: place)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $showCompose) {
            ComposePost(initialTag: "Gifts")
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
    }

    private var compareCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text("Locals buy")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                Text("Loose pastries\nSour plum drink mix\nCorner tower magnets")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Rectangle()
                .fill(Palette.ink.opacity(0.14))
                .frame(width: 1)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text("Tourist versions")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                Text("Over-boxed gift sets\nSouvenir keychains\nBagged roast duck")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .strikethrough(true, color: Palette.ink3.opacity(0.6))
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.pinkSoft))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .overlay(alignment: .topLeading) {
            StickerLabel(text: "Buy right", fill: Palette.paper, rotation: -4)
                .offset(x: 12, y: -11)
        }
        .padding(.top, 8)
    }

    private func giftRow(_ place: ForumPlace) -> some View {
        let saved = model.savedPlaces.contains(place.id)
        return HStack(spacing: 10) {
            PhotoTile(symbol: place.symbol, tint: place.tint, height: 72)
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(place.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Text(place.subtitle)
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    ForEach(place.tags.prefix(2), id: \.self) { tag in
                        TagView(text: tag, style: .soft)
                    }
                }
                Text(place.price)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Palette.ink)
            }

            Spacer(minLength: 0)

            VStack(spacing: 6) {
                Button {
                    model.toggleSaved(place)
                    Haptics.tap()
                } label: {
                    Image(systemName: saved ? "heart.fill" : "heart")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(saved ? Palette.coral : Palette.ink)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Palette.paperWarm))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
                Text(place.likes)
                    .font(.system(size: 8, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        .contentShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
        .onTapGesture {
            Haptics.tap()
            selectedPlace = place
        }
    }

    private var packButton: some View {
        Button {
            for gift in gifts.prefix(3) {
                model.addToChecklist(
                    title: gift.title,
                    meta: "\(gift.price) · Gift",
                    category: .docs,
                    phase: .arrival
                )
            }
            Haptics.success()
            model.toast("3 gifts added to your prep list", icon: "checklist")
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 10, weight: .bold))
                Text("Add picks to prep list")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(Capsule().fill(Palette.lime))
            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var shippingTip: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "airplane")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Palette.ink)
            Text("Packing tip: choose vacuum-sealed pastries; put sour plum mix and pickles in checked bags. Keep magnets with you.")
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .lineSpacing(3)
            Spacer(minLength: 0)
        }
        .padding(11)
        .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.45), lineWidth: 1))
    }
}

// MARK: - Routes

private struct RouteChannel: View {
    @EnvironmentObject private var model: AppModel
    @State private var showCompose = false

    private let tints: [Color] = [Palette.blue, Palette.accent, Palette.olive]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                ChannelHeader(
                    eyebrow: "COMMUNITY / WALK",
                    sticker: "WALK",
                    title: "Walk someone else's route",
                    subtitle: "Community citywalks · Apply as your own copy",
                    fill: Palette.periwinkle,
                    actionTitle: "Share",
                    actionIcon: "square.and.pencil",
                    action: { showCompose = true }
                )

                myRouteCard

                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Text("Community routes")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text("\(model.forumRoutes.count) routes · 1 new this week")
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }

                    ForEach(Array(model.forumRoutes.enumerated()), id: \.element.id) { index, route in
                        routeCard(route, index: index)
                    }
                }

                shareRouteButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
        .sheet(isPresented: $showCompose) {
            ComposePost(initialTag: "Routes", initialAttachRoute: true)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
    }

    private var myRouteCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Eyebrow(text: "MY ROUTE / DRAFT", color: Palette.lime)
                Spacer()
                TagView(text: "\(model.stops.count) stops", style: .dark)
            }
            Text(model.routeName)
                .font(.system(size: 21, weight: .black))
                .tracking(-0.4)
                .foregroundStyle(Palette.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text("4.2 km · ~5 hr · Walk + subway")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.paper.opacity(0.6))

            HStack(spacing: 7) {
                Button {
                    Haptics.tap()
                    model.tab = .plan
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 8.5, weight: .bold))
                        Text("Back to map")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.lime))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())

                Button {
                    model.shareRoute()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 8.5, weight: .bold))
                        Text("Share with a friend")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 34)
                    .background(Capsule().fill(Palette.paper.opacity(0.12)))
                    .overlay(Capsule().strokeBorder(Palette.paper.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .fill(Palette.ink)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 23, style: .continuous)
                .strokeBorder(Palette.paper.opacity(0.16), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            DoodleView(kind: .sparkle, color: Palette.lime.opacity(0.7), lineWidth: 1.2)
                .frame(width: 38, height: 38)
                .padding(14)
                .allowsHitTesting(false)
        }
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
    }

    private func routeCard(_ route: ForumRoute, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack(alignment: .topTrailing) {
                MiniRouteMap(points: routePoints(index), tint: tints[index % tints.count])
                    .frame(height: 128)
                StickerLabel(text: "ROUTE 0\(index + 1)", fill: Palette.mustard, rotation: 3)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(route.title)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Palette.ink)
                    Text("\(route.author) · \(route.meta)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                Spacer()
                Text("♥ \(route.likes)")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }

            HStack(spacing: 5) {
                ForEach(route.tags, id: \.self) { tag in
                    TagView(text: tag, style: .soft)
                }
                Spacer(minLength: 0)
                Text("\(route.stops) stops · \(route.distance)")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            Button {
                model.copyRoute(named: route.title)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc.fill")
                        .font(.system(size: 9, weight: .bold))
                    Text("Apply to my route")
                        .font(.system(size: 10.5, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(11)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.11), radius: 0, x: 0, y: 3)
    }

    private func routePoints(_ index: Int) -> [CGPoint] {
        switch index {
        case 0:
            return [CGPoint(x: 0.16, y: 0.82), CGPoint(x: 0.30, y: 0.62), CGPoint(x: 0.28, y: 0.40), CGPoint(x: 0.52, y: 0.34), CGPoint(x: 0.70, y: 0.52), CGPoint(x: 0.86, y: 0.26)]
        case 1:
            return [CGPoint(x: 0.48, y: 0.86), CGPoint(x: 0.52, y: 0.66), CGPoint(x: 0.58, y: 0.50), CGPoint(x: 0.38, y: 0.38), CGPoint(x: 0.62, y: 0.22)]
        default:
            return [CGPoint(x: 0.20, y: 0.80), CGPoint(x: 0.34, y: 0.62), CGPoint(x: 0.50, y: 0.52), CGPoint(x: 0.64, y: 0.34), CGPoint(x: 0.80, y: 0.22)]
        }
    }

    private var shareRouteButton: some View {
        Button {
            Haptics.tap()
            showCompose = true
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "figure.walk.motion")
                    .font(.system(size: 13, weight: .bold))
                VStack(alignment: .leading, spacing: 1) {
                    Text("Share your citywalk")
                        .font(.system(size: 11.5, weight: .bold))
                    Text("Link your route — friends can apply it in one tap")
                        .font(.system(size: 9, weight: .medium))
                        .opacity(0.68)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 10, weight: .black))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 14)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Palette.periwinkleSoft))
            .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Events

private struct EventChannel: View {
    @EnvironmentObject private var model: AppModel
    @State private var showCompose = false
    @State private var launchComposeApplied = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                ChannelHeader(
                    eyebrow: "COMMUNITY / EVENTS",
                    sticker: "EVENTS",
                    title: "Meet in Beijing this week",
                    subtitle: "Local stalls, flea markets and night rides · \(model.localEvents.count) events",
                    fill: Palette.accentSoft,
                    actionTitle: "Post",
                    actionIcon: "plus",
                    action: { showCompose = true }
                )

                if let featured = model.localEvents.first {
                    featuredCard(featured)
                }

                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Text("Event calendar")
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                        Spacer()
                        Text("By time")
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }

                    ForEach(Array(model.localEvents.dropFirst())) { event in
                        eventRow(event)
                    }
                }

                publishButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
        .sheet(isPresented: $showCompose) {
            EventComposeSheet()
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        #if DEBUG
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            guard !launchComposeApplied else { return }
            launchComposeApplied = true
            if args.contains("-eventcompose") {
                showCompose = true
            }
        }
        #endif
    }

    private func featuredCard(_ event: LocalEvent) -> some View {
        let joined = model.joinedEventIDs.contains(event.id)
        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    TagView(text: "Featured this week", style: .neutral)
                    Spacer()
                    Text("\(event.date) · \(event.time)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.ink.opacity(0.6))
                }
                Text(event.title)
                    .font(.system(size: 26, weight: .black))
                    .tracking(-0.4)
                    .foregroundStyle(Palette.ink)
                    .lineLimit(2)
                Text(event.subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.ink.opacity(0.68))
                    .lineSpacing(2)
                HStack(spacing: 8) {
                    AvatarStack(names: ["L", "Z", "K"], size: 21)
                    Text("\(event.attendees + (joined ? 1 : 0)) going")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Palette.ink.opacity(0.65))
                    Spacer()
                    Button {
                        model.toggleJoin(event)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: joined ? "checkmark" : "plus")
                                .font(.system(size: 8.5, weight: .black))
                            Text(joined ? "Going" : "Join")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 13)
                        .frame(height: 31)
                        .background(Capsule().fill(joined ? Palette.paper : Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 8, weight: .bold))
                    Text(event.place)
                        .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                        .lineLimit(1)
                }
                .foregroundStyle(Palette.ink.opacity(0.55))
            }
            .padding(16)

            DoodleView(kind: .sun, color: Palette.ink.opacity(0.45), lineWidth: 1.5)
                .frame(width: 50, height: 50)
                .padding(.top, 34)
                .padding(.trailing, 13)
                .allowsHitTesting(false)
        }
        .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Palette.coral))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.4))
        .overlay(alignment: .top) {
            TapeStrip(color: Palette.paper.opacity(0.55), rotation: -4)
                .offset(y: -7)
        }
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.15), radius: 0, x: 0, y: 4)
    }

    private func eventRow(_ event: LocalEvent) -> some View {
        let joined = model.joinedEventIDs.contains(event.id)
        let parts = dateParts(event.date)
        return HStack(spacing: 10) {
            VStack(spacing: 1) {
                Text(parts.0)
                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                Text(parts.1)
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .opacity(0.7)
            }
            .foregroundStyle(Palette.ink)
            .frame(width: 48, height: 52)
            .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(eventFill(event.tint)))
            .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(event.title)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .lineLimit(1)
                    if event.isMine {
                        TagView(text: "My post", style: .accent)
                    }
                }
                Text("\(event.time) · \(event.place)")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .lineLimit(1)
                Text("\(event.host) · \(event.fee) · \(event.attendees + (joined ? 1 : 0)) going")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Button {
                model.toggleJoin(event)
            } label: {
                Text(joined ? "Going" : "Join")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 11)
                    .frame(height: 29)
                    .background(Capsule().fill(joined ? Palette.lime : Palette.paperWarm))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
    }

    private var publishButton: some View {
        Button {
            Haptics.tap()
            showCompose = true
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 12, weight: .bold))
                Text("Host a local event")
                    .font(.system(size: 11.5, weight: .bold))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 9, weight: .black))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Capsule().fill(Palette.paperWarm))
            .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.7), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3])))
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func eventFill(_ tint: Int) -> Color {
        [Palette.limeSoft, Palette.pinkSoft, Palette.periwinkleSoft, Palette.mintSoft][tint % 4]
    }

    private func dateParts(_ date: String) -> (String, String) {
        let parts = date.split(separator: " ")
        let monthDay = parts.first.map(String.init) ?? date
        let weekday = parts.count > 1 ? String(parts[1]) : ""
        return (monthDay, weekday)
    }
}

// MARK: - Event compose

private struct EventComposeSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var date = "11/08 Sat"
    @State private var time = "18:00"
    @State private var place = ""
    @State private var fee = "Free"
    @State private var note = ""

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && !place.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 15) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Eyebrow(text: "COMMUNITY · HOST AN EVENT")
                        Text("Bring something good\nto Beijing")
                            .font(.system(size: 28, weight: .black))
                            .tracking(-0.5)
                            .foregroundStyle(Palette.ink)
                            .lineSpacing(1)
                        Text("It appears in the local events channel — editable anytime.")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundStyle(Palette.ink3)
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

                field(title: "Event name", placeholder: "e.g. Baita Temple flea market", text: $title)

                HStack(spacing: 8) {
                    field(title: "Date", placeholder: "11/08 Sat", text: $date)
                    field(title: "Time", placeholder: "18:00", text: $time)
                }

                field(title: "Place", placeholder: "Drum & Bell Towers square · Meet-up", text: $place)
                field(title: "Fee", placeholder: "Free / ¥20 / split", text: $fee)

                VStack(alignment: .leading, spacing: 5) {
                    Eyebrow(text: "ABOUT")
                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("What you'll do, who it's for, what to bring…")
                                .font(.system(size: 11.5))
                                .foregroundStyle(Palette.ink3)
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                        }
                        TextEditor(text: $note)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Palette.ink2)
                            .scrollContentBackground(.hidden)
                            .frame(height: 108)
                            .padding(9)
                    }
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paper))
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
                }

                previewCard

                HStack(spacing: 5) {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 9, weight: .bold))
                    Text("Free to post · Shown after review")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Palette.ink3)
                }
                .padding(.top, 1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                model.publishEvent(title: title, date: date, time: time, place: place, fee: fee, note: note)
                dismiss()
            } label: {
                Text("Post to local events")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(canPublish ? Palette.ink : Palette.ink3)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Capsule().fill(canPublish ? Palette.lime : Palette.cream.opacity(0.7)))
                    .overlay(Capsule().strokeBorder(canPublish ? Palette.ink : Palette.ink.opacity(0.3), lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!canPublish)
            .padding(.horizontal, 20)
            .padding(.top, 9)
            .padding(.bottom, 8)
            .background(Palette.bg)
        }
        .background(Palette.bg.ignoresSafeArea())
    }

    private func field(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Eyebrow(text: title)
            TextField(placeholder, text: text)
                .font(.system(size: 12.5, weight: .semibold))
                .textFieldStyle(.plain)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Palette.paper))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        }
    }

    private var previewCard: some View {
        HStack(spacing: 9) {
            VStack(spacing: 1) {
                Text(date.split(separator: " ").first.map(String.init) ?? date)
                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                Text("Preview")
                    .font(.system(size: 6.5, weight: .bold, design: .monospaced))
                    .opacity(0.6)
            }
            .foregroundStyle(Palette.ink)
            .frame(width: 48, height: 52)
            .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Palette.limeSoft))
            .overlay(RoundedRectangle(cornerRadius: 13, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(title.isEmpty ? "Your event name" : title)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundStyle(title.isEmpty ? Palette.ink3 : Palette.ink)
                    .lineLimit(1)
                Text("\(time) · \(place.isEmpty ? "Meeting point" : place)")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .lineLimit(1)
                Text("@Wang Bo · \(fee.isEmpty ? "Free" : fee)")
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)
            TagView(text: "My post", style: .accent)
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink.opacity(0.5), style: StrokeStyle(lineWidth: 1.1, dash: [4, 3])))
    }
}
