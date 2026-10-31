import SwiftUI

struct ForumView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPlace: ForumPlace? = nil
    @State private var showCompose = false
    @State private var path = NavigationPath()
    @State private var launchChannelApplied = false

    private var query: String {
        model.forumSearch.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var filteredPlaces: [ForumPlace] {
        model.forumPlaces.filter { place in
            let matchesFilter = model.forumFilter == .all || model.forumFilter == place.kind
            let matchesQuery = query.isEmpty
                || place.title.localizedCaseInsensitiveContains(query)
                || place.subtitle.localizedCaseInsensitiveContains(query)
                || place.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            return matchesFilter && matchesQuery
        }
    }

    private var filteredRoutes: [ForumRoute] {
        guard model.forumFilter == .all || model.forumFilter == .route else { return [] }
        if query.isEmpty { return model.forumRoutes }
        return model.forumRoutes.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.tags.contains { $0.localizedCaseInsensitiveContains(query) } }
    }

    private var showEvent: Bool {
        (model.forumFilter == .all || model.forumFilter == .event) && query.isEmpty
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar
                    if query.isEmpty {
                        channelRail
                        if showEvent {
                            eventCard
                        }
                        if !filteredRoutes.isEmpty {
                            routesSection
                        }
                        placesSection
                    } else {
                        searchResults
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 130)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Palette.bg)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ForumFilter.self) { channel in
                ForumChannelView(channel: channel)
                    .environmentObject(model)
            }
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
            ComposePost()
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        #if DEBUG
        .onAppear {
            let args = ProcessInfo.processInfo.arguments
            if args.contains("-place"), let place = model.forumPlaces.first {
                selectedPlace = place
            }
            if args.contains("-compose") {
                showCompose = true
            }
            guard !launchChannelApplied else { return }
            launchChannelApplied = true
            if args.contains("-restaurant") { path.append(ForumFilter.restaurant) }
            if args.contains("-spot") { path.append(ForumFilter.spot) }
            if args.contains("-gift") { path.append(ForumFilter.gift) }
            if args.contains("-route") { path.append(ForumFilter.route) }
            if args.contains("-event") { path.append(ForumFilter.event) }
            if args.contains("-eventcompose") { path.append(ForumFilter.event) }
        }
        #endif
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Eyebrow(text: "社区 / BEIJING")
                    DoodleView(kind: .flower, color: Palette.mustard)
                        .frame(width: 12, height: 12)
                }
                Text("大家的北京")
                    .font(.system(size: 36, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(Palette.ink)
                Text("4,208 条路线 · 1,286 家餐厅 · 本地人也在看")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer()
            Button {
                Haptics.tap()
                showCompose = true
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Palette.paper)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Palette.ink))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    .compositingGroup()
                    .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 2)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.top, 4)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Palette.ink)
            TextField("搜餐厅、路线、伴手礼", text: $model.forumSearch)
                .font(.system(size: 12, weight: .medium))
                .textFieldStyle(.plain)
                .submitLabel(.search)
            if !model.forumSearch.isEmpty {
                Button {
                    withAnimation { model.forumSearch = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.ink3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Capsule().fill(Palette.paper))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2)
    }

    private let channels: [ForumFilter] = [.restaurant, .spot, .gift, .route, .event]

    private var channelRail: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text("主题频道")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Text("一页一个主题 →")
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(channels) { channel in
                        channelCard(channel)
                    }
                }
                .padding(.vertical, 3)
            }
        }
    }

    private func channelCard(_ channel: ForumFilter) -> some View {
        Button {
            Haptics.tap()
            path.append(channel)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: channelIcon(channel))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Palette.paper.opacity(0.82)))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(Palette.ink.opacity(0.55))
                }
                Spacer(minLength: 0)
                Text(channelTitle(channel))
                    .font(.system(size: 13.5, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                Text(channelSubtitle(channel))
                    .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink.opacity(0.62))
                    .lineLimit(1)
            }
            .padding(10)
            .frame(width: 132, height: 98)
            .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(channelFill(channel)))
            .overlay(RoundedRectangle(cornerRadius: 19, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
            .compositingGroup()
            .shadow(color: Palette.ink.opacity(0.12), radius: 0, x: 0, y: 3)
            .overlay(alignment: .topTrailing) {
                if channel == .event {
                    Circle()
                        .fill(Palette.accent)
                        .frame(width: 7, height: 7)
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
                        .offset(x: -9, y: 9)
                }
            }
        }
        .buttonStyle(PressableButtonStyle(scale: 0.97))
    }

    private func channelTitle(_ channel: ForumFilter) -> String {
        switch channel {
        case .restaurant: return "餐厅热度"
        case .spot: return "景点推荐"
        case .gift: return "伴手礼"
        case .route: return "城市漫步"
        case .event: return "本地活动"
        case .all: return "全部"
        }
    }

    private func channelSubtitle(_ channel: ForumFilter) -> String {
        switch channel {
        case .restaurant:
            return "热度榜 · \(model.forumPlaces.filter { $0.kind == .restaurant }.count) 家"
        case .spot:
            return "本周 · \(model.forumPlaces.filter { $0.kind == .spot }.count) 处"
        case .gift:
            return "本地人买 · \(model.forumPlaces.filter { $0.kind == .gift }.count) 件"
        case .route:
            return "可套用 · \(model.forumRoutes.count) 条"
        case .event:
            return "本周 · \(model.localEvents.count) 场"
        case .all:
            return "全部内容"
        }
    }

    private func channelFill(_ channel: ForumFilter) -> Color {
        switch channel {
        case .restaurant: return Palette.mustardSoft
        case .spot: return Palette.mint
        case .gift: return Palette.pinkSoft
        case .route: return Palette.periwinkleSoft
        case .event: return Palette.accentSoft
        case .all: return Palette.cream
        }
    }

    private func channelIcon(_ channel: ForumFilter) -> String {
        switch channel {
        case .restaurant: return "flame"
        case .spot: return "camera.macro"
        case .gift: return "gift"
        case .route: return "figure.walk"
        case .event: return "calendar"
        case .all: return "square.grid.2x2"
        }
    }

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("搜索 “\(query)”")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(1)
                Spacer()
                Text("\(filteredPlaces.count + filteredRoutes.count) 条")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
            }

            if filteredPlaces.isEmpty && filteredRoutes.isEmpty {
                emptyState
            } else {
                if !filteredRoutes.isEmpty {
                    routesSection
                }
                if !filteredPlaces.isEmpty {
                    placesSection
                }
            }
        }
    }

    // MARK: Event

    private var eventCard: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    TagView(text: "本地活动", style: .neutral)
                    Spacer()
                    Text(model.forumEvent.date)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.ink.opacity(0.6))
                }
                Text(model.forumEvent.title)
                    .font(.system(size: 27, weight: .black))
                    .tracking(-0.5)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)
                Text(model.forumEvent.subtitle)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(Palette.ink.opacity(0.65))
                HStack(spacing: 8) {
                    AvatarStack(names: ["林", "周", "K"], size: 22)
                    Text("\(model.forumEvent.attendees + (model.joinedEvent ? 1 : 0)) 人已报名")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundStyle(Palette.ink.opacity(0.65))
                    Spacer()
                    Button {
                        model.joinEvent()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: model.joinedEvent ? "checkmark" : "plus")
                                .font(.system(size: 9, weight: .black))
                            Text(model.joinedEvent ? "已报名" : "报名")
                                .font(.system(size: 10.5, weight: .bold))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 13)
                        .frame(height: 31)
                        .background(Capsule().fill(model.joinedEvent ? Palette.paper : Palette.lime))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                    }
                    .buttonStyle(PressableButtonStyle())
                }
                .padding(.top, 2)
                HStack(spacing: 6) {
                    Text(model.forumEvent.place)
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink.opacity(0.5))
                    Spacer(minLength: 4)
                    Button {
                        Haptics.tap()
                        path.append(ForumFilter.event)
                    } label: {
                        HStack(spacing: 3) {
                            Text("活动频道")
                                .font(.system(size: 8.5, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 7, weight: .black))
                        }
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 8)
                        .frame(height: 23)
                        .background(Capsule().fill(Palette.paper.opacity(0.7)))
                        .overlay(Capsule().strokeBorder(Palette.ink.opacity(0.7), lineWidth: 0.9))
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.95))
                }
            }
            .padding(16)

            DoodleView(kind: .sun, color: Palette.ink.opacity(0.5), lineWidth: 1.6)
                .frame(width: 54, height: 54)
                .padding(.top, 38)
                .padding(.trailing, 14)
                .allowsHitTesting(false)
        }
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.coral)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
        .overlay(alignment: .top) {
            TapeStrip(color: Palette.paper.opacity(0.55), rotation: -4)
                .offset(y: -7)
        }
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
    }

    // MARK: Routes

    private var routesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text("01")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Palette.lime))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                Text("社区路线")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Button {
                    Haptics.tap()
                    path.append(ForumFilter.route)
                } label: {
                    HStack(spacing: 3) {
                        Text("全部路线")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 7, weight: .black))
                    }
                    .foregroundStyle(Palette.ink2)
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(model.forumRoutes.indices, id: \.self) { index in
                        routeCard(route: model.forumRoutes[index], index: index)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func routeCard(route: ForumRoute, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ZStack(alignment: .topTrailing) {
                MiniRouteMap(points: index == 0
                    ? [CGPoint(x: 0.16, y: 0.82), CGPoint(x: 0.30, y: 0.62), CGPoint(x: 0.28, y: 0.40), CGPoint(x: 0.52, y: 0.34), CGPoint(x: 0.70, y: 0.52), CGPoint(x: 0.86, y: 0.26)]
                    : [CGPoint(x: 0.48, y: 0.86), CGPoint(x: 0.52, y: 0.66), CGPoint(x: 0.58, y: 0.50), CGPoint(x: 0.38, y: 0.38), CGPoint(x: 0.62, y: 0.22)],
                    tint: index == 0 ? Palette.blue : Palette.accent
                )
                .frame(height: 112)

                StickerLabel(text: "ROUTE 0\(index + 1)", fill: Palette.mustard, rotation: 3)
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

            Text(route.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Palette.ink)
            Text("\(route.author) · \(route.meta)")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)

            HStack(spacing: 4) {
                ForEach(route.tags, id: \.self) { tag in
                    TagView(text: tag, style: .soft)
                }
                Spacer(minLength: 0)
                Image(systemName: "heart")
                    .font(.system(size: 8.5, weight: .semibold))
                Text(route.likes)
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundStyle(Palette.ink2)

            Button {
                model.copyRoute(named: route.title)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 9, weight: .bold))
                    Text("套用到我的路线")
                        .font(.system(size: 10.5, weight: .bold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(Capsule().fill(Palette.lime))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(11)
        .frame(width: 264)
        .background(RoundedRectangle(cornerRadius: 21, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 21, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.13), radius: 0, x: 0, y: 3)
    }

    // MARK: Places

    private var placesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 8) {
                Text("02")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 22, height: 22)
                    .background(Circle().fill(Palette.mustard))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                Text(model.forumFilter == .gift ? "伴手礼推荐" : "本地人推荐")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                Spacer()
                if query.isEmpty {
                    Text("\(filteredPlaces.count) 处")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                } else {
                    Text("搜索 “\(query)”")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Palette.accent)
                }
            }

            if filteredPlaces.isEmpty {
                Text("没有找到匹配的地点，换个关键词试试。")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .padding(.vertical, 12)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                    spacing: 10
                ) {
                    ForEach(filteredPlaces) { place in
                        placeCard(place)
                    }
                }
            }
        }
    }

    private var placeFills: [Color] {
        [Palette.pinkSoft, Palette.skySoft, Palette.mintSoft, Palette.mustardSoft, Palette.periwinkleSoft, Palette.limeSoft]
    }

    private func placeCard(_ place: ForumPlace) -> some View {
        let saved = model.savedPlaces.contains(place.id)
        return VStack(alignment: .leading, spacing: 7) {
            ZStack(alignment: .topTrailing) {
                PhotoTile(symbol: place.symbol, tint: place.tint, height: 100)
                Button {
                    model.toggleSaved(place)
                } label: {
                    Image(systemName: saved ? "heart.fill" : "heart")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(saved ? Palette.coral : Palette.ink)
                        .frame(width: 28, height: 28)
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
            Text(place.subtitle)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Palette.ink2)
                .lineLimit(1)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(place.price)
                    .font(.system(size: 10.5, weight: .black))
                    .foregroundStyle(Palette.ink)
                Spacer()
                Image(systemName: "heart")
                    .font(.system(size: 7.5, weight: .semibold))
                    .foregroundStyle(Palette.ink2)
                Text(place.likes)
                    .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
            }
        }
        .padding(9)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(placeFills[place.tint % placeFills.count]))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.11), radius: 0, x: 0, y: 2.5)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            Haptics.tap()
            selectedPlace = place
        }
    }

    private var emptyState: some View {
        VStack(spacing: 9) {
            DoodleView(kind: .squiggle, color: Palette.ink.opacity(0.4), lineWidth: 1.5)
                .frame(width: 42, height: 12)
            Text("这片街区还没有内容")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
            Text("换个筛选，或者问问 Lucia。")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Palette.ink3)
            LuciaLimeButton(title: "问问 Lucia", icon: "sparkles") {
                model.openAssistant("论坛 · 找点灵感")
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}
