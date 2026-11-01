import SwiftUI

struct ForumView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selectedPost: ForumPost? = nil
    @State private var standalonePlace: ForumPlace? = nil
    @State private var showCompose = false
    @State private var feedFilter: ForumPostKind = .all
    @State private var path = NavigationPath()
    @State private var launchChannelApplied = false

    private var query: String {
        model.forumSearch.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var feedPosts: [ForumPost] {
        model.forumPosts.filter { post in
            let matchesFilter = query.isEmpty ? (feedFilter == .all || post.kind == feedFilter) : true
            guard matchesFilter else { return false }
            guard !query.isEmpty else { return true }
            let haystack = ([post.title, post.body, post.author] + post.tags
                + [model.say(post.title), model.say(post.body)] + post.tags.map { model.say($0) })
                .joined(separator: " ")
            return haystack.localizedCaseInsensitiveContains(query)
        }
    }

    private var leftPosts: [ForumPost] {
        feedPosts.enumerated().filter { $0.offset % 2 == 0 }.map(\.element)
    }

    private var rightPosts: [ForumPost] {
        feedPosts.enumerated().filter { $0.offset % 2 == 1 }.map(\.element)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    searchBar

                    if query.isEmpty {
                        filterRow
                        feedIntro
                    } else {
                        searchHeading
                    }

                    if feedPosts.isEmpty {
                        emptyState
                    } else {
                        postFeed
                    }

                    feedEnd
                }
                .padding(.horizontal, 18)
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
        .sheet(item: $selectedPost) { post in
            PostDetailSheet(post: post) { channel in
                path.append(channel)
            }
            .environmentObject(model)
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(30)
            .presentationBackground(Palette.bg)
        }
        .sheet(item: $standalonePlace) { place in
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
                standalonePlace = place
            }
            if args.contains("-compose") {
                showCompose = true
            }
            if args.contains("-postdetail"), let post = feedPosts.first {
                selectedPost = post
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
                    Eyebrow(text: "COMMUNITY / BEIJING")
                    DoodleView(kind: .flower, color: Palette.mustard)
                        .frame(width: 12, height: 12)
                }
                Text("Our Beijing")
                    .font(.system(size: 36, weight: .black))
                    .tracking(-0.8)
                    .foregroundStyle(Palette.ink)
                Text("4,208 notes · 126 today · Locals post too")
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
            TextField("Search notes, places, people", text: $model.forumSearch)
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
        .frame(height: 44)
        .background(Capsule().fill(Palette.paper))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.2))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2)
    }

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(ForumPostKind.allCases) { kind in
                    Chip(title: model.say(kind.title), selected: feedFilter == kind) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
                            feedFilter = kind
                        }
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    private var feedIntro: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Circle()
                .fill(Palette.accent)
                .frame(width: 6, height: 6)
                .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.7))
            Text(model.say(feedFilter == .all ? "Latest notes" : "\(feedFilter.title) notes"))
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Palette.ink)
            Spacer()
            Text(verbatim: model.lang == .zh ? "\(feedPosts.count) 篇 · 最新在前" : "\(feedPosts.count) posts · Newest first")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)
        }
        .padding(.top, 2)
    }

    private var searchHeading: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(verbatim: model.lang == .zh ? "搜索“\(query)”" : "Search “\(query)”")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(Palette.ink)
                .lineLimit(1)
            Spacer()
            Text(verbatim: model.lang == .zh ? "\(feedPosts.count) 条笔记" : "\(feedPosts.count) notes")
                .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3)
        }
        .padding(.top, 2)
    }

    // MARK: Feed

    private var postFeed: some View {
        HStack(alignment: .top, spacing: 10) {
            LazyVStack(spacing: 10) {
                ForEach(leftPosts) { post in
                    postCard(post)
                }
            }
            LazyVStack(spacing: 10) {
                ForEach(rightPosts) { post in
                    postCard(post)
                }
            }
        }
    }

    private func postCard(_ post: ForumPost) -> some View {
        let saved = model.savedPostIDs.contains(post.id)
        return VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                PostCoverView(post: post, height: post.height)
                    .overlay(alignment: .topLeading) {
                        Text(model.say(post.kind.label))
                            .font(.system(size: 7.5, weight: .bold, design: .monospaced))
                            .tracking(0.4)
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 7)
                            .frame(height: 20)
                            .background(Capsule().fill(Palette.paper))
                            .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                            .padding(8)
                    }

                Button {
                    model.toggleSavedPost(post)
                } label: {
                    Image(systemName: saved ? "bookmark.fill" : "heart")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(saved ? Palette.accent : Palette.ink)
                        .frame(width: 27, height: 27)
                        .background(Circle().fill(Palette.paper))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle(scale: 0.94))
                .padding(7)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(model.say(post.title))
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                Text(model.say(post.body))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .lineSpacing(2)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 5) {
                    Text(post.avatar)
                        .font(.system(size: 7, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 17, height: 17)
                        .background(Circle().fill(avatarFill(post.tint)))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 0.8))
                    Text(post.author)
                        .font(.system(size: 8.5, weight: .semibold))
                        .foregroundStyle(Palette.ink2)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "heart")
                        .font(.system(size: 7, weight: .semibold))
                        .foregroundStyle(Palette.ink3)
                    Text(post.likes)
                        .font(.system(size: 8, weight: .medium, design: .monospaced))
                        .foregroundStyle(Palette.ink3)
                }
                .padding(.top, 2)
            }
            .padding(10)
        }
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Palette.paper))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Palette.ink, lineWidth: 1.1))
        .compositingGroup()
        .shadow(color: Palette.ink.opacity(0.1), radius: 0, x: 0, y: 2.5)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onTapGesture {
            Haptics.tap()
            selectedPost = post
        }
    }

    private var feedEnd: some View {
        VStack(spacing: 4) {
            Text("You're all caught up")
                .font(.system(size: 9.5, weight: .bold))
                .foregroundStyle(Palette.ink3)
            Text("4,208 notes · Pull to refresh")
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(Palette.ink3.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
    }

    private var emptyState: some View {
        VStack(spacing: 9) {
            DoodleView(kind: .squiggle, color: Palette.ink.opacity(0.4), lineWidth: 1.5)
                .frame(width: 42, height: 12)
            Text(query.isEmpty
                ? (model.lang == .zh ? "还没有笔记" : "No notes yet")
                : (model.lang == .zh ? "没有找到“\(query)”" : "Nothing for “\(query)”"))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Palette.ink)
            Text("Try another category, or start a citywalk under Events.")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Palette.ink3)
            LuciaLimeButton(title: "Ask Pico", icon: "sparkles") {
                model.openAssistant("Community · Find inspiration")
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }

    private func avatarFill(_ tint: Int) -> Color {
        [Palette.pink, Palette.sky, Palette.mint, Palette.mustard, Palette.periwinkle, Palette.lime][tint % 6]
    }
}

// MARK: - Post detail

struct PostDetailSheet: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    let post: ForumPost
    var onOpenChannel: (ForumFilter) -> Void = { _ in }

    @State private var selectedPlace: ForumPlace?

    private var saved: Bool { model.savedPostIDs.contains(post.id) }

    private var linkedPlace: ForumPlace? {
        guard let title = post.placeTitle else { return nil }
        return model.forumPlaces.first { $0.title == title }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                header

                ZStack(alignment: .topLeading) {
                    PostCoverView(post: post, height: 208)
                    Text(model.say(post.kind.label))
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .tracking(0.5)
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 8)
                        .frame(height: 22)
                        .background(Capsule().fill(Palette.paper))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                        .padding(9)
                }
                .overlay(alignment: .bottomTrailing) {
                    if let credit = post.credit {
                        Text(verbatim: model.lang == .zh
                            ? "图片 · \(credit) · Wikimedia Commons"
                            : "Photo · \(credit) · Wikimedia Commons")
                            .font(.system(size: 7, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Palette.paper)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Palette.ink.opacity(0.62)))
                            .padding(9)
                    }
                }

                HStack(spacing: 9) {
                    Text(post.avatar)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(Palette.ink)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(avatarFill(post.tint)))
                        .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.author)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Palette.ink)
                        Text(verbatim: model.lang == .zh
                            ? "\(model.say(post.time)) · 在北京"
                            : "\(post.time) · Beijing")
                            .font(.system(size: 8.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Palette.ink3)
                    }
                    Spacer()
                    TagView(text: post.tags.first ?? "Note", style: .soft)
                }

                Text(model.say(post.title))
                    .font(.system(size: 25, weight: .black))
                    .tracking(-0.4)
                    .foregroundStyle(Palette.ink)
                    .lineSpacing(1)

                Text(model.say(post.body))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Palette.ink2)
                    .lineSpacing(4)

                HStack(spacing: 6) {
                    ForEach(post.tags, id: \.self) { tag in
                        TagView(text: tag, style: .soft)
                    }
                }

                Rectangle()
                    .fill(Palette.ink.opacity(0.12))
                    .frame(height: 1)
                    .padding(.vertical, 2)

                HStack(spacing: 14) {
                    Label(post.likes, systemImage: "heart")
                    Label(post.saves, systemImage: "bookmark")
                    Label(model.lang == .zh
                        ? (post.comments == 0 ? "还没有评论" : "\(post.comments) 条评论")
                        : (post.comments == 0 ? "No comments yet" : "\(post.comments) comments"),
                        systemImage: "bubble.left")
                }
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundStyle(Palette.ink2)

                if !post.comment.isEmpty {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(verbatim: model.lang == .zh
                            ? (post.comments == 0 ? "来自作者" : "评论 · \(post.comments)")
                            : (post.comments == 0 ? "From the author" : "Comments · \(post.comments)"))
                            .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                            .tracking(0.6)
                            .foregroundStyle(Palette.ink3)
                        Text(model.say(post.comment))
                            .font(.system(size: 10.5, weight: .medium))
                            .foregroundStyle(Palette.ink2)
                            .lineSpacing(2)
                    }
                    .padding(11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(Palette.paperWarm))
                    .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).strokeBorder(Palette.ink.opacity(0.45), lineWidth: 1))
                }

                HStack(spacing: 7) {
                    Button {
                        model.toggleSavedPost(post)
                    } label: {
                        postActionLabel(
                            title: model.say(saved ? "Saved" : "Save"),
                            icon: saved ? "bookmark.fill" : "heart",
                            fill: Palette.lime
                        )
                    }
                    .buttonStyle(PressableButtonStyle())

                    if linkedPlace != nil {
                        Button {
                            selectedPlace = linkedPlace
                        } label: {
                            postActionLabel(title: model.say("Place details"), icon: "mappin.and.ellipse", fill: Palette.paper)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }

                    if post.routeIndex != nil {
                        Button {
                            applyRoute()
                        } label: {
                            postActionLabel(title: model.say("Use route"), icon: "point.topleft.down.to.point.bottomright.curvepath", fill: Palette.paper)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }

                    if post.eventTitle != nil {
                        Button {
                            openEventChannel()
                        } label: {
                            postActionLabel(title: model.say("View event"), icon: "calendar", fill: Palette.paper)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }

                Button {
                    askPico()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                        Text("Ask Pico if it's worth it")
                            .font(.system(size: 11.5, weight: .bold))
                    }
                    .foregroundStyle(Palette.paper)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Capsule().fill(Palette.ink))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.top, 2)

                Text(verbatim: post.isMine
                    ? model.say("Posted by you · Visible to the community")
                    : model.say("Posted in RoamChina Community · From community members"))
                    .font(.system(size: 8.5, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 26)
        }
        .background(Palette.bg.ignoresSafeArea())
        .sheet(item: $selectedPlace) { place in
            PlaceSheet(place: place)
                .environmentObject(model)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Eyebrow(text: "\(model.say(post.kind.label)) · \(model.lang == .zh ? "社区笔记" : "COMMUNITY NOTE")")
                Text(verbatim: model.lang == .zh ? "\(post.author) 的笔记" : "\(post.author)'s notes")
                    .font(.system(size: 22, weight: .black))
                    .tracking(-0.3)
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

    private func postActionLabel(title: String, icon: String, fill: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(title)
                .font(.system(size: 10.5, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(Palette.ink)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(Capsule().fill(fill))
        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
    }

    private func avatarFill(_ tint: Int) -> Color {
        [Palette.pink, Palette.sky, Palette.mint, Palette.mustard, Palette.periwinkle, Palette.lime][tint % 6]
    }

    private func applyRoute() {
        guard let index = post.routeIndex, model.forumRoutes.indices.contains(index) else { return }
        let name = model.forumRoutes[index].title
        Haptics.success()
        Task { @MainActor in
            dismiss()
            try? await Task.sleep(nanoseconds: 250_000_000)
            model.copyRoute(named: name)
        }
    }

    private func openEventChannel() {
        Haptics.tap()
        Task { @MainActor in
            dismiss()
            try? await Task.sleep(nanoseconds: 250_000_000)
            model.forumFilter = .event
            onOpenChannel(.event)
        }
    }

    private func askPico() {
        Haptics.tap()
        Task { @MainActor in
            dismiss()
            try? await Task.sleep(nanoseconds: 250_000_000)
            model.openAssistant("Community · \(post.title)")
        }
    }
}
