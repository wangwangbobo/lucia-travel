import SwiftUI
import AVFoundation

@MainActor
final class AppModel: ObservableObject {

    // MARK: Navigation
    @Published var tab: Tab = .trip
    @Published var checklistOpen = false
    @Published var assistantOpen = false
    @Published var assistantContext = "New trip · Planning with Pico"
    @Published var notesOpen = false
    @Published var onboarding = true
    @Published var planBuilt = false
    @Published var firstRunFlow = true
    @Published var lang: AppLanguage = .en
    @Published var recapOpen = false
    @Published var recapSlide = 0

    // MARK: Trip
    @Published var reminderDismissed = false
    @Published var checklist: [ChecklistItem]
    @Published var toast: Toast?

    // MARK: Plan
    @Published var routeName = "Central Axis · Draft"
    @Published var stops: [RouteStop]
    @Published var selectedStopID: UUID?
    @Published var layer: MapLayer = .mine
    @Published var aiSuggestionVisible = true
    @Published var routeApplied = false
    @Published var mapEditMode = false
    @Published var pendingSimilar = false

    // MARK: Merged trip editor
    @Published var tripDays: [TripDay] = []
    @Published var tripStartDate: Date = AppModel.defaultTripStart
    @Published var tripDay = 0
    @Published var tripEdit = false
    @Published var tripSaved = false
    @Published var tripDirty = false
    @Published var tripLive = false
    @Published var liveStop = 0

    let tripSuggestions: [TripSuggestion] = [
        TripSuggestion(name: "Metal Hands · Qianmen", meta: "Coffee · 45 min", x: 0.66, y: 0.74),
        TripSuggestion(name: "Siji Minfu · Duck", meta: "Lunch · 1.5 hr", x: 0.60, y: 0.63),
        TripSuggestion(name: "Beihai Park", meta: "Boats · 1.5 hr", x: 0.34, y: 0.44),
        TripSuggestion(name: "Temple of Heaven", meta: "Sights · 1.5 hr", x: 0.44, y: 0.90)
    ]

    // MARK: Forum
    @Published var forumFilter: ForumFilter = .all
    @Published var forumSearch = ""
    @Published var joinedEvent = false
    @Published var joinedEventIDs: Set<UUID> = []
    @Published var savedPlaces: Set<UUID> = []
    @Published var savedPostIDs: Set<UUID> = []
    @Published var localEvents: [LocalEvent]
    @Published var forumPosts: [ForumPost]

    // MARK: Translate
    @Published var translateMode: TranslateMode = .live
    @Published var scenario: Scenario = .medical
    @Published var liveMessages: [LiveMessage]
    @Published var listening = false
    @Published var languageFlipped = false
    @Published var photoSample: PhotoSample = .menu
    @Published var photoScanning = false
    @Published var photoScanned = false

    // MARK: Me
    @Published var notificationsOn = true
    @Published var attractions: [AttractionBooking]

    // MARK: Chat
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatDraft = ""
    @Published var chatThinking = false

    // MARK: Plan builder (shared with the trip page style check)
    @Published var quizDays: String? = nil
    @Published var quizStyle: String? = nil
    @Published var quizTheme: String? = nil
    @Published var quizNote = ""

    var quizAnswered: Int {
        [quizDays, quizStyle, quizTheme].compactMap { $0 }.count
    }

    var quizPersona: TravelPersona? {
        guard let days = quizDays, let style = quizStyle, let theme = quizTheme else { return nil }
        let map: [String: (String, String)] = [
            "Slow culture": ("The Slow Culture Wanderer", "safari"),
            "Food first": ("The Table-First Wanderer", "fork.knife"),
            "Outdoors": ("The Open-Air Rambler", "figure.walk"),
            "Night owl": ("The After-Dark Flâneur", "star.fill"),
            "Family friendly": ("The Easy-Going Family Wanderer", "person.2.fill"),
            "Budget smart": ("The Shrewd City Wanderer", "ticket")
        ]
        let base = map[style] ?? ("The Slow Culture Wanderer", "safari")
        let axisThemes = ["Imperial history", "Hutongs & coffee", "Night markets"]
        let fit = axisThemes.contains(theme) ? "Central Axis" : "Imperial Gardens"
        let note = quizNote.trimmingCharacters(in: .whitespacesAndNewlines)
        return TravelPersona(
            title: base.0,
            icon: base.1,
            meta: "\(days) · \(style) · \(theme)",
            fit: fit,
            note: String(note.prefix(140))
        )
    }

    var planLength: Int {
        if quizDays == "2–3 days" { return 3 }
        if quizDays == "6+ days" { return 6 }
        return 4
    }

    var showPlanBuilder: Bool { onboarding && !planBuilt }

    // MARK: Static demo content
    let forumRoutes: [ForumRoute] = [
        ForumRoute(title: "Two days in the hutongs · 8 stops", author: "@Lina", meta: "4.8 · 1.2k saves", tags: ["Easy", "Coffee", "Photo spots"], stops: 8, distance: "6.4 km", likes: "1.2k"),
        ForumRoute(title: "Central Axis · Half day", author: "@Ken", meta: "4.9 · 2.1k saves", tags: ["Classic", "Walk", "Sunset"], stops: 6, distance: "4.2 km", likes: "2.1k"),
        ForumRoute(title: "Drum Tower to Houhai · After dark", author: "@Zhe", meta: "4.7 · 968 saves", tags: ["Night", "Bars", "Easy"], stops: 5, distance: "3.8 km", likes: "968")
    ]

    let forumPlaces: [ForumPlace] = [
        ForumPlace(title: "Siji Minfu · Forbidden City", subtitle: "Arrive before 11:00 · Peking duck", price: "¥150", tags: ["Family", "Local favorite"], kind: .restaurant, likes: "2.3k", symbol: "fork.knife", tint: 0, heat: 96, area: "Dongcheng · Forbidden City", note: "After 3pm there's barely a wait, and the skin stays crisp.", bestTime: "Before 11:00 / after 15:00"),
        ForumPlace(title: "Man Heng Ji · Niujie", subtitle: "Hand-cut lamb · copper-pot hotpot", price: "¥95", tags: ["Local", "Queue"], kind: .restaurant, likes: "1.9k", symbol: "flame", tint: 6, heat: 93, area: "Xicheng · Niujie", note: "Hand-cut lamb with sesame dip — even locals happily queue.", bestTime: "Take a number before 17:00"),
        ForumPlace(title: "Pangmei Noodles · Beixinqiao", subtitle: "Chongqing noodles · crispy pork", price: "¥45", tags: ["Local", "Quick bite"], kind: .restaurant, likes: "886", symbol: "takeoutbag.and.cup.and.straw", tint: 1, heat: 88, area: "Dongcheng · Beixinqiao", note: "Ask for mild heat; the crispy pork is best fresh from the wok.", bestTime: "Weekdays 14:00"),
        ForumPlace(title: "Metal Hands · Qianmen", subtitle: "Hutong coffee · house roast", price: "¥45", tags: ["Coffee", "Quiet"], kind: .restaurant, likes: "1.1k", symbol: "cup.and.saucer.fill", tint: 5, heat: 81, area: "Dongcheng · Qianmen", note: "A quiet café down a side lane, best light in the afternoon.", bestTime: "15:00–17:00"),
        ForumPlace(title: "Daoxiangcun · Local gifts", subtitle: "Skip the gift boxes · 8 picks", price: "¥50–120", tags: ["Gifts", "Check-in"], kind: .gift, likes: "1.7k", symbol: "gift", tint: 2, heat: 86, area: "Branches citywide", note: "Loose pastries beat the gift boxes — check the date.", bestTime: "Morning restock"),
        ForumPlace(title: "Palace Museum Shop · Magnets", subtitle: "Corner-tower series · limited colors", price: "¥39", tags: ["Light", "Limited"], kind: .gift, likes: "604", symbol: "sparkles", tint: 3, heat: 78, area: "Forbidden City · Shenwu Gate", note: "The corner-tower magnet sells out, so buy it on the way in.", bestTime: "1 hr after opening"),
        ForumPlace(title: "Tongrentang · Sour plum mix", subtitle: "Brew a Beijing summer", price: "¥38", tags: ["Check-in", "Light"], kind: .gift, likes: "512", symbol: "leaf", tint: 7, heat: 74, area: "Dongcheng · Dashilar", note: "Brewed at home, it tastes more like Beijing than any bottle.", bestTime: "Any time"),
        ForumPlace(title: "Sunset at Jingshan", subtitle: "Up before 17:00 · Wanchun Pavilion", price: "Free", tags: ["Sunset", "Palace views"], kind: .spot, likes: "3.4k", symbol: "sun.horizon", tint: 4, heat: 94, area: "Dongcheng · Jingshan", note: "Reach Wanchun Pavilion before 17:00 for the full palace view.", bestTime: "40 min before sunset"),
        ForumPlace(title: "Temple of Heaven", subtitle: "Echo Wall · old cypresses", price: "¥34", tags: ["Architecture", "Quiet"], kind: .spot, likes: "2.8k", symbol: "building.columns", tint: 8, heat: 90, area: "Dongcheng · Temple of Heaven", note: "Enter from the south gate; the Echo Wall is best when quiet.", bestTime: "1 hr after opening"),
        ForumPlace(title: "Beihai Park", subtitle: "Boats and the White Dagoba", price: "¥10", tags: ["Family", "Boating"], kind: .spot, likes: "2.1k", symbol: "sailboat", tint: 9, heat: 82, area: "Xicheng · Beihai", note: "Rent a boat — the White Dagoba looks best from the water.", bestTime: "After 15:00")
    ]

    let forumEvent = ForumEvent(
        title: "Hutong Night Market · Free entry",
        subtitle: "Handmade goods, vinyl and snacks from local stalls",
        date: "10/18 Sat · 18:00",
        place: "Drum & Bell Towers square · 35 min from hotel",
        attendees: 128
    )

    let similarRoutes: [SimilarRoute] = [
        SimilarRoute(
            title: "Central Axis · Classic half day",
            author: "@Ken",
            match: 94,
            stops: 6,
            distance: "4.2 km",
            duration: "~5 hr",
            tags: ["Classic", "Walk", "Sunset"],
            highlight: "Matches 5 of your 6 stops, with the palace section in the same order."
        ),
        SimilarRoute(
            title: "Hutong coffee crawl · 8 stops",
            author: "@Lina",
            match: 87,
            stops: 8,
            distance: "6.4 km",
            duration: "~a full day",
            tags: ["Coffee", "Photo spots", "Easy"],
            highlight: "Swaps Nanluoguxiang for three coffee shops — good for an afternoon start."
        ),
        SimilarRoute(
            title: "Jingshan sunset + Shichahai at night",
            author: "@Zhe",
            match: 79,
            stops: 5,
            distance: "3.8 km",
            duration: "~3 hr",
            tags: ["Night", "Sunset", "Local"],
            highlight: "Keeps your Jingshan sunset, then walks back along Shichahai — one backtrack fewer."
        )
    ]

    let phrases: [Phrase] = [
        Phrase(zh: "请问最近的地铁站怎么走？", en: "Where is the nearest subway station?", scenario: .route),
        Phrase(zh: "我迷路了，能帮我看看地图吗？", en: "I'm lost. Could you help me read the map?", scenario: .route),
        Phrase(zh: "我对花生过敏，请确认这道菜不含花生。", en: "I'm allergic to peanuts. Does this dish contain any?", scenario: .dining),
        Phrase(zh: "可以刷卡吗？", en: "Can I pay by card?", scenario: .dining),
        Phrase(zh: "我食物过敏，需要去医院。", en: "I have a food allergy and need a hospital.", scenario: .medical),
        Phrase(zh: "请帮我叫一辆救护车。", en: "Please call an ambulance for me.", scenario: .medical),
        Phrase(zh: "我对青霉素过敏。", en: "I am allergic to penicillin.", scenario: .medical),
        Phrase(zh: "这是我正在服用的药。", en: "This is the medication I am taking.", scenario: .medical),
        Phrase(zh: "请带我去这个地址。", en: "Please take me to this address.", scenario: .taxi),
        Phrase(zh: "大概需要多长时间？", en: "How long will it take?", scenario: .taxi),
        Phrase(zh: "这个多少钱？", en: "How much is this?", scenario: .shopping),
        Phrase(zh: "可以退税吗？", en: "Can I get a tax refund?", scenario: .shopping),
        Phrase(zh: "请帮我报警。", en: "Please help me call the police.", scenario: .emergency),
        Phrase(zh: "我需要中文翻译帮助。", en: "I need help from a Chinese interpreter.", scenario: .emergency)
    ]

    // MARK: Init
    init() {
        checklist = Self.makeChecklist()
        stops = Self.makeStops()
        liveMessages = [
            LiveMessage(zh: "你好，请问最近的地铁站怎么走？", en: "Hello, where is the nearest subway station?", isMine: false),
            LiveMessage(zh: "直走两个路口，在红绿灯处左转。", en: "Go straight for two blocks, then turn left at the lights.", isMine: true)
        ]
        localEvents = Self.makeLocalEvents()
        forumPosts = Self.makeForumPosts()
        attractions = Self.makeAttractions()
        applySavedChecklist()
        applyLaunchScreen()
    }

    // Enables screenshot QA: `simctl launch ... ai.lucia.travel -plan`
    private func applyLaunchScreen() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-zh") { lang = .zh }
        if let index = args.firstIndex(of: "-tripstart"), args.indices.contains(index + 1) {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.calendar = Self.tripCalendar
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: args[index + 1]) {
                tripStartDate = Self.tripCalendar.startOfDay(for: date)
            }
        }
        if args.contains("-plan") || args.contains("-similar") { tab = .plan }
        if args.contains("-mapedit") {
            tab = .plan
            mapEditMode = true
            aiSuggestionVisible = false
            selectedStopID = stops.first(where: { $0.name == "Forbidden City" })?.id
        }
        if args.contains("-forum") { tab = .forum }
        if args.contains("-translate") { tab = .translate }
        if args.contains("-me") { tab = .me }
        if args.contains("-offline") {
            tab = .translate
            translateMode = .offline
        }
        if args.contains("-photocam") {
            tab = .translate
            translateMode = .photo
            photoScanned = false
        }
        if args.contains("-photo") {
            tab = .translate
            translateMode = .photo
            photoScanned = true
        }
        if args.contains("-photo-sign") {
            tab = .translate
            translateMode = .photo
            photoSample = .sign
            photoScanned = true
        }
        if args.contains("-restaurant") || args.contains("-spot") || args.contains("-gift")
            || args.contains("-route") || args.contains("-event") || args.contains("-eventcompose") {
            tab = .forum
        }
        if args.contains("-notes") {
            tab = .plan
            notesOpen = true
        }
        if args.contains("-checklist") { checklistOpen = true }
        if args.contains("-quizdone") {
            quizDays = quizDays ?? "4–5 days"
            quizStyle = quizStyle ?? "Food first"
            quizTheme = quizTheme ?? "Hutongs & coffee"
        }
        if let index = args.firstIndex(of: "-quiznote"), args.indices.contains(index + 1) {
            quizNote = args[index + 1]
        }
        if args.contains("-plantrip") {
            tab = .trip
            quizDays = "6+ days"
            quizStyle = "Food first"
            quizTheme = "Hutongs & coffee"
            onboarding = false
            planBuilt = true
            assistantContext = "Plan · Central Axis · \(planLength) days"
            routeName = "Central Axis · New plan"
        }
        if args.contains("-planbuilt") {
            quizDays = "4–5 days"
            quizStyle = "Food first"
            quizTheme = "Hutongs & coffee"
            onboarding = false
            planBuilt = true
            assistantContext = "Plan · Central Axis · \(planLength) days"
            routeName = "Central Axis · New plan"
            if let persona = quizPersona {
                let note = quizNote.trimmingCharacters(in: .whitespacesAndNewlines)
                chatMessages = [
                    ChatMessage(role: .assistant, text: "Hi, I'm Pico. Tell me what kind of trip you like and I'll build your first Beijing plan — route order, timing and all."),
                    ChatMessage(role: .user, text: note.isEmpty ? "4–5 days · Food first · Hutongs & coffee" : "4–5 days · Food first · Hutongs & coffee · \(note)"),
                    ChatMessage(role: .assistant, text: planNarrative(persona), card: .plan)
                ]
            }
            assistantOpen = true
        }
        if args.contains("-assistant") {
            assistantContext = onboarding ? "New trip · Planning with Pico" : tab.assistantContext
            seedAssistant()
            assistantOpen = true
        }
        if args.contains("-autobuild") {
            quizDays = "4–5 days"
            quizStyle = "Food first"
            quizTheme = "Hutongs & coffee"
            assistantContext = "New trip · Planning with Pico"
            seedAssistant()
            assistantOpen = true
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(900))
                self?.buildPlan()
            }
        }
        if let index = args.firstIndex(of: "-ask"), args.indices.contains(index + 1) {
            let question = args[index + 1]
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(1400))
                self?.sendChat(question)
            }
        }
        if args.contains("-place") || args.contains("-compose") { tab = .forum }
        if args.contains("-reorder") { tab = .plan }
        if args.contains("-bigtype") {
            tab = .translate
            translateMode = .offline
        }
        if args.contains("-recap") {
            tab = .trip
            onboarding = false
            planBuilt = true
            ensureTripDays()
            recapOpen = true
            if let index = args.firstIndex(of: "-recapslide"),
               args.indices.contains(index + 1),
               let value = Int(args[index + 1]) {
                recapSlide = min(max(value, 0), 7)
            }
        }
        if planBuilt {
            ensureTripDays()
            if args.contains("-tripday2") { tripDay = min(1, tripDays.count - 1) }
            if args.contains("-tripday3") { tripDay = min(2, tripDays.count - 1) }
            if args.contains("-tripedit") {
                tripSaved = true
                tripEdit = true
                aiSuggestionVisible = false
            }
            if args.contains("-tripsaved") {
                tripSaved = true
                tripDirty = false
                aiSuggestionVisible = false
            }
            if args.contains("-triplivedone") {
                tripSaved = true
                tripLive = true
                liveStop = currentStops.count
            } else if args.contains("-triplive3") {
                tripSaved = true
                tripLive = true
                liveStop = min(3, max(0, currentStops.count - 1))
            } else if args.contains("-triplive") {
                tripSaved = true
                tripLive = true
                liveStop = 1
            }
        }
        if args.contains("-closedock") { assistantOpen = false }
        #endif
        firstRunFlow = onboarding && !planBuilt
    }

    // MARK: Checklist
    var doneCount: Int { checklist.filter { $0.status == .done }.count }
    var totalCount: Int { checklist.count }
    var progress: Double { totalCount == 0 ? 0 : Double(doneCount) / Double(totalCount) }
    var remaining: Int { max(0, totalCount - doneCount) }

    func items(in phase: ChecklistPhase) -> [ChecklistItem] {
        checklist.filter { $0.phase == phase }
    }

    func phaseDone(_ phase: ChecklistPhase) -> Int {
        items(in: phase).filter { $0.status == .done }.count
    }

    func categoryStats(_ category: ChecklistCategory) -> (done: Int, total: Int) {
        let list = checklist.filter { $0.category == category }
        return (list.filter { $0.status == .done }.count, list.count)
    }

    func toggle(_ item: ChecklistItem) {
        guard let index = checklist.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            checklist[index].status = checklist[index].status == .done ? (checklist[index].actionLabel == nil ? .todo : .action) : .done
        }
        Haptics.tap()
        persistChecklist()
    }

    func complete(_ item: ChecklistItem) {
        guard let index = checklist.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) { checklist[index].status = .done }
        Haptics.success()
        persistChecklist()
        toast("Done · \(item.title)", icon: "checkmark.seal.fill")
    }

    func bookForbiddenCity() {
        if let index = checklist.firstIndex(where: { $0.title.hasPrefix("Forbidden City tickets") }) {
            withAnimation { checklist[index].status = .done }
            persistChecklist()
        }
        Haptics.success()
        toast("Booked \(tripStamp(0).date) 09:00 · 2 adults", icon: "ticket.fill")
    }

    func aiRecheck() {
        let open = checklist.filter { $0.status != .done }.count
        Haptics.success()
        if open == 0 {
            toast("All 12 checks complete", icon: "checkmark.seal.fill")
        } else {
            toast("Recheck done · \(open) to go, reordered", icon: "sparkles")
        }
    }

    func addToChecklist(title: String, meta: String, category: ChecklistCategory = .tickets, phase: ChecklistPhase = .before) {
        guard !checklist.contains(where: { $0.title == title }) else {
            toast("Already on your list", icon: "checkmark.circle.fill")
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            checklist.append(
                ChecklistItem(
                    title: title,
                    meta: meta,
                    category: category,
                    phase: phase,
                    status: .action,
                    actionLabel: "View",
                    tag: "New",
                    tagStyle: .accent
                )
            )
        }
        Haptics.success()
        persistChecklist()
        toast("Added to your pre-trip list", icon: "text.badge.plus")
    }

    var checklistSummary: String {
        let lines = checklist.map { item -> String in
            "\(item.status == .done ? "✓" : "○") \(item.title) — \(item.meta)"
        }
        return "Pico · Beijing 4 days, 3 nights · Pre-trip checklist\nProgress \(doneCount)/\(totalCount)\n\n" + lines.joined(separator: "\n")
    }

    private func persistChecklist() {
        let map = Dictionary(uniqueKeysWithValues: checklist.map { ($0.title, $0.status == .done) })
        UserDefaults.standard.set(map, forKey: "lucia.checklist.v1")
    }

    private func applySavedChecklist() {
        guard let saved = UserDefaults.standard.dictionary(forKey: "lucia.checklist.v1") as? [String: Bool] else { return }
        for index in checklist.indices {
            guard let done = saved[checklist[index].title] else { continue }
            if done {
                checklist[index].status = .done
            } else {
                checklist[index].status = checklist[index].actionLabel == nil ? .todo : .action
            }
        }
    }

    // MARK: Plan
    func selectStop(_ stop: RouteStop) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedStopID = selectedStopID == stop.id ? nil : stop.id
        }
        Haptics.tap()
    }

    func toggleMapEditMode() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            mapEditMode.toggle()
        }
        Haptics.tap()
        if mapEditMode {
            toast("Edit stops · drag the numbered pins", icon: "hand.draw.fill")
        }
    }

    func moveStop(_ id: UUID, toX x: CGFloat, toY y: CGFloat) {
        guard let index = stops.firstIndex(where: { $0.id == id }) else { return }
        stops[index].x = min(max(x, 0.06), 0.94)
        stops[index].y = min(max(y, 0.10), 0.90)
        markTripEdited()
    }

    func didFinishMovingStop() {
        markTripEdited()
        Haptics.success()
        toast("Stops updated · route redrawn", icon: "map.fill")
    }

    func applyRouteSuggestion() {
        let order = ["Tiananmen Square", "Forbidden City", "Shichahai", "Jingshan Park", "Nanluoguxiang", "Drum & Bell Towers"]
        let times = ["09:00", "09:40", "13:00", "14:30", "16:00", "17:00"]
        var reordered: [RouteStop] = []
        for (index, name) in order.enumerated() {
            if var stop = stops.first(where: { $0.name == name }) {
                stop.time = times[index]
                reordered.append(stop)
            }
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            if reordered.count == stops.count { stops = reordered }
            routeApplied = true
            aiSuggestionVisible = false
        }
        markTripEdited()
        Haptics.success()
        toast("Applied · route recalculated, 1.2 km shorter", icon: "arrow.triangle.swap")
    }

    func moveStops(from source: IndexSet, to destination: Int) {
        stops.move(fromOffsets: source, toOffset: destination)
        renumberStops()
        markTripEdited()
        toast("Order updated", icon: "arrow.up.arrow.down")
    }

    private func renumberStops() {
        var hour = 9
        var minute = 0
        for index in stops.indices {
            stops[index].time = String(format: "%02d:%02d", hour, minute)
            let duration = index == 1 ? 180 : (index == 3 ? 90 : 45)
            minute += duration + 15
            hour += minute / 60
            minute %= 60
        }
    }

    func copyRoute(named name: String) {
        routeName = name + " · Copy"
        routeApplied = false
        aiSuggestionVisible = true
        tab = .plan
        selectedStopID = stops.first?.id
        Haptics.success()
        toast("Copied to your own route", icon: "doc.on.doc.fill")
    }

    func shareRoute() {
        toast("Route link copied", icon: "link")
    }

    var routeSummary: String {
        let lines = stops.enumerated().map { index, stop in
            "\(index + 1). \(stop.name) · \(stop.time) · \(stop.duration)"
        }
        return "\(routeName)\n6 stops · 4.2 km · ~5 hr\n\n" + lines.joined(separator: "\n") + "\n\nFrom Pico · Beijing trip plan"
    }

    // MARK: Merged trip editor

    static let tripCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    static var defaultTripStart: Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 10
        components.day = 15
        components.hour = 12
        return tripCalendar.date(from: components) ?? Date()
    }

    private static let tripMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd"
        return formatter
    }()

    private static let tripWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let zhWeekdays: [String: String] = [
        "Mon": "周一", "Tue": "周二", "Wed": "周三",
        "Thu": "周四", "Fri": "周五", "Sat": "周六", "Sun": "周日"
    ]

    /// Month/day and short weekday for a trip day, counting from the editable start.
    func tripStamp(_ index: Int, from start: Date? = nil) -> (date: String, week: String) {
        let base = start ?? tripStartDate
        let date = Self.tripCalendar.date(byAdding: .day, value: index, to: base) ?? base
        return (Self.tripMonthDay.string(from: date), Self.tripWeekday.string(from: date))
    }

    func weekLabel(_ short: String) -> String {
        lang == .zh ? (Self.zhWeekdays[short] ?? short) : short
    }

    func tripDateRange(count: Int? = nil, from start: Date? = nil) -> String {
        let days = max(1, count ?? tripDayCount)
        return "\(tripStamp(0, from: start).date) – \(tripStamp(days - 1, from: start).date)"
    }

    func tripDatesLine(count: Int) -> String {
        "\(tripDateRange(count: count)) · \(lang == .zh ? "2 位旅行者" : "2 travelers")"
    }

    /// Localizes data-driven strings (place names, tags) that `Text` would render verbatim.
    func say(_ text: String) -> String {
        lang == .zh ? L10n.text(text, lang) : text
    }

    /// Localizes a composed trip meta line such as "6 stops · 4.2 km · ~5 hr".
    func tripMeta(_ meta: String) -> String {
        guard lang == .zh else { return meta }
        return meta.components(separatedBy: " · ").map { part in
            if part.hasSuffix(" stops"), let count = Int(part.dropLast(6)) {
                return "\(count) 站"
            }
            if part.hasSuffix(" km walk") {
                return part.replacingOccurrences(of: " km walk", with: " 公里步行")
            }
            if part.hasSuffix(" km on foot") {
                return part.replacingOccurrences(of: " km on foot", with: " 公里步行")
            }
            if part.hasSuffix(" km") {
                return part.replacingOccurrences(of: " km", with: " 公里")
            }
            if part.hasPrefix("~"), part.hasSuffix(" hr") {
                let hours = part.dropFirst().dropLast(3)
                return "约 \(hours) 小时"
            }
            if part == "~full day" || part == "full day" { return "约一整天" }
            if part == "private car" || part == "private car both ways" { return "往返专车" }
            if part.hasPrefix("Metro Line ") {
                return "地铁 \(part.dropFirst(11)) 号线"
            }
            return L10n.text(part, lang)
        }.joined(separator: " · ")
    }

    /// Moves the whole itinerary in place so edited stops and notes survive a date change.
    func setTripStart(_ date: Date) {
        let start = Self.tripCalendar.startOfDay(for: date)
        guard !Self.tripCalendar.isDate(start, inSameDayAs: tripStartDate) else { return }
        tripStartDate = start
        guard !tripDays.isEmpty else { return }
        for index in tripDays.indices {
            let stamp = tripStamp(index, from: start)
            tripDays[index].date = stamp.date
            tripDays[index].week = stamp.week
        }
        Haptics.success()
        toast(lang == .zh ? "日期已更新 · \(tripDatesLine(count: tripDays.count))" : "Dates moved · \(tripDatesLine(count: tripDays.count))", icon: "calendar")
    }

    var tripDayCount: Int { tripDays.isEmpty ? planLength : tripDays.count }

    var currentTripDay: TripDay? {
        tripDays.indices.contains(tripDay) ? tripDays[tripDay] : tripDays.first
    }

    var currentStops: [RouteStop] {
        tripDay == 0 ? stops : (currentTripDay?.stops ?? stops)
    }

    func ensureTripDays() {
        guard planBuilt else { return }
        if tripDays.count != planLength {
            tripDays = makeTripDays(stops: stops, count: planLength)
            tripDay = min(tripDay, max(0, tripDays.count - 1))
        }
    }

    func setCurrentStops(_ list: [RouteStop]) {
        if tripDay == 0 {
            stops = list
        } else if tripDays.indices.contains(tripDay) {
            tripDays[tripDay].stops = list
        }
    }

    func markTripEdited() {
        if tripSaved { tripDirty = true }
    }

    func selectTripDay(_ index: Int) {
        guard tripDays.indices.contains(index) else { return }
        Haptics.tap()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.86)) {
            tripDay = index
            tripEdit = false
            selectedStopID = nil
        }
    }

    func toggleTripEdit() {
        withAnimation(.spring(response: 0.34, dampingFraction: 0.84)) {
            tripEdit.toggle()
        }
        Haptics.tap()
        toast(
            tripEdit ? "Edit stops · drag pins or grab a stop" : "Edit done · times kept",
            icon: tripEdit ? "hand.draw.fill" : "checkmark.circle.fill"
        )
    }

    func moveTripStop(_ id: UUID, toX x: CGFloat, toY y: CGFloat) {
        var list = currentStops
        guard let index = list.firstIndex(where: { $0.id == id }) else { return }
        list[index].x = min(max(x, 0.06), 0.94)
        list[index].y = min(max(y, 0.10), 0.90)
        setCurrentStops(list)
    }

    func didFinishTripStopMove() {
        markTripEdited()
        Haptics.success()
        toast("Stop moved · route recalculated", icon: "map.fill")
    }

    func moveTripStops(from source: IndexSet, to destination: Int) {
        var list = currentStops
        let slots = list.map(\.time)
        list.move(fromOffsets: source, toOffset: destination)
        Self.applyTimeSlots(&list, slots: slots)
        setCurrentStops(list)
        markTripEdited()
        Haptics.success()
        toast("Order updated · route recalculated", icon: "arrow.up.arrow.down")
    }

    func shiftTripStop(_ id: UUID, up: Bool) {
        var list = currentStops
        guard let index = list.firstIndex(where: { $0.id == id }) else { return }
        let target = up ? index - 1 : index + 1
        guard list.indices.contains(target) else { return }
        let slots = list.map(\.time)
        list.swapAt(index, target)
        Self.applyTimeSlots(&list, slots: slots)
        setCurrentStops(list)
        markTripEdited()
        Haptics.tap()
        toast("Order updated · route recalculated", icon: "arrow.up.arrow.down")
    }

    func moveTripStopToIndex(_ id: UUID, to target: Int) {
        var list = currentStops
        guard let source = list.firstIndex(where: { $0.id == id }), source != target else { return }
        let slots = list.map(\.time)
        let stop = list.remove(at: source)
        list.insert(stop, at: min(max(target, 0), list.count))
        Self.applyTimeSlots(&list, slots: slots)
        setCurrentStops(list)
        markTripEdited()
        Haptics.success()
        toast("Order updated · route recalculated", icon: "arrow.up.arrow.down")
    }

    func deleteTripStop(_ id: UUID) {
        var list = currentStops
        guard list.count > 2, let index = list.firstIndex(where: { $0.id == id }) else { return }
        let name = list[index].name
        let slots = list.map(\.time)
        list.remove(at: index)
        Self.applyTimeSlots(&list, slots: slots)
        setCurrentStops(list)
        markTripEdited()
        Haptics.tap()
        toast("Removed \(name)", icon: "trash")
    }

    var availableTripSuggestions: [TripSuggestion] {
        let names = Set(currentStops.map(\.name))
        return tripSuggestions.filter { !names.contains($0.name) }
    }

    func addTripStop(_ suggestion: TripSuggestion) {
        var list = currentStops
        let time = Self.plusMinutes(list.last?.time ?? "09:00", 60)
        let duration = suggestion.meta.components(separatedBy: " · ").last ?? "45 min"
        list.append(
            RouteStop(
                name: suggestion.name,
                time: time,
                duration: duration,
                x: suggestion.x,
                y: suggestion.y,
                tag: "Pico pick",
                tagStyle: .accent
            )
        )
        setCurrentStops(list)
        markTripEdited()
        Haptics.success()
        toast("\(suggestion.name) added · route updated", icon: "mappin.and.ellipse")
    }

    func saveTripPlan() {
        tripSaved = true
        tripDirty = false
        Haptics.success()
        toast("Plan saved · start when you are ready", icon: "checkmark.seal.fill")
    }

    func startTrip() {
        tripSaved = true
        tripDirty = false
        tripEdit = false
        liveStop = 0
        Haptics.success()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.86)) {
            tripLive = true
        }
        toast("Trip started · first stop ahead", icon: "figure.walk")
    }

    func advanceLiveStop() {
        guard tripLive else { return }
        let count = currentStops.count
        Haptics.tap()
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            liveStop = min(liveStop + 1, count)
        }
        if liveStop >= count {
            Haptics.success()
            toast("Day complete · every stop covered", icon: "checkmark.seal.fill")
        } else {
            let next = currentStops[liveStop]
            toast("Next · \(next.name)", icon: "arrow.right")
        }
    }

    func endLiveTrip() {
        withAnimation(.easeOut(duration: 0.2)) {
            tripLive = false
            liveStop = 0
        }
        Haptics.tap()
        toast("Live trip ended · plan saved", icon: "xmark.circle")
    }

    func finishLiveDay() {
        if tripDay < tripDayCount - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                tripDay += 1
                tripLive = false
                liveStop = 0
                selectedStopID = nil
            }
            Haptics.success()
            toast("Day done · Day \(tripDay + 1) loaded", icon: "calendar")
        } else {
            withAnimation(.easeOut(duration: 0.2)) {
                tripLive = false
                liveStop = 0
            }
            Haptics.success()
            toast("Trip complete · plan saved", icon: "checkmark.seal.fill")
            tripSaved = true
            tripDirty = false
            recapSlide = 0
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(420))
                self?.recapOpen = true
            }
        }
    }

    func liveCoordinate(_ stop: RouteStop) -> String {
        String(format: "%.4f° N, %.4f° E", 39.92 - Double(stop.y) * 0.06, 116.38 + Double(stop.x) * 0.06)
    }

    func liveClock(_ stop: RouteStop) -> String {
        Self.plusMinutes(stop.time, 12)
    }

    var reorderStops: [RouteStop] {
        tab == .trip && planBuilt ? currentStops : stops
    }

    func moveReorderStops(from source: IndexSet, to destination: Int) {
        if tab == .trip && planBuilt {
            moveTripStops(from: source, to: destination)
        } else {
            moveStops(from: source, to: destination)
        }
    }

    static func plusMinutes(_ hhmm: String, _ minutes: Int) -> String {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2, let hour = Int(parts[0]), let minute = Int(parts[1]) else { return hhmm }
        let total = (hour * 60 + minute + minutes + 24 * 60) % (24 * 60)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private static func applyTimeSlots(_ list: inout [RouteStop], slots: [String]) {
        for index in list.indices where index < slots.count {
            list[index].time = slots[index]
        }
    }

    private static let dayCoordinates: [[CGPoint]] = [
        [CGPoint(x: 0.30, y: 0.82), CGPoint(x: 0.42, y: 0.64), CGPoint(x: 0.54, y: 0.48),
         CGPoint(x: 0.44, y: 0.32), CGPoint(x: 0.60, y: 0.24), CGPoint(x: 0.70, y: 0.40)],
        [CGPoint(x: 0.34, y: 0.86), CGPoint(x: 0.46, y: 0.70), CGPoint(x: 0.56, y: 0.54),
         CGPoint(x: 0.50, y: 0.36), CGPoint(x: 0.64, y: 0.28), CGPoint(x: 0.72, y: 0.48)],
        [CGPoint(x: 0.28, y: 0.78), CGPoint(x: 0.40, y: 0.62), CGPoint(x: 0.52, y: 0.44),
         CGPoint(x: 0.62, y: 0.30), CGPoint(x: 0.70, y: 0.50), CGPoint(x: 0.58, y: 0.68)],
        [CGPoint(x: 0.36, y: 0.84), CGPoint(x: 0.48, y: 0.66), CGPoint(x: 0.58, y: 0.50),
         CGPoint(x: 0.48, y: 0.34), CGPoint(x: 0.34, y: 0.44), CGPoint(x: 0.26, y: 0.62)],
        [CGPoint(x: 0.32, y: 0.80), CGPoint(x: 0.44, y: 0.62), CGPoint(x: 0.54, y: 0.46),
         CGPoint(x: 0.66, y: 0.32), CGPoint(x: 0.74, y: 0.50), CGPoint(x: 0.62, y: 0.70)]
    ]

    private func makeTripDays(stops: [RouteStop], count: Int) -> [TripDay] {
        typealias Seed = (
            title: String, meta: String, tag: String,
            style: TagStyle, note: String, stops: [(String, String, String)]
        )
        let seeds: [Seed] = [
            ("Central Axis · Palace & hutongs", "6 stops · 4.2 km · ~5 hr", "Today", .accent,
             "Palace booked for 09:00 · in at Meridian Gate, out at Shenwu Gate", []),
            ("Great Wall day · Badaling", "3 stops · private car · full day", "Car booked", .blue,
             "Bring your passport · windy up there, pack an extra layer",
             [("Hotel pickup", "07:30", "30 min"), ("Badaling Great Wall", "09:00", "3 hr"), ("Olympic Forest Park", "16:30", "1.5 hr")]),
            ("Imperial gardens · Palace & museum", "4 stops · Metro Line 4 · ~8 hr", "Tickets to book", .soft,
             "The National Museum needs a real-name booking; bring your passport",
             [("Summer Palace", "09:00", "2 hr"), ("Lunch in Wudaokou", "12:30", "1.5 hr"), ("National Museum of China", "14:00", "2 hr"), ("Qianmen Street", "18:00", "1.5 hr")]),
            ("Slow hutongs · departure", "4 stops · 3.1 km walk · ~4 hr", "Departure", .ok,
             "Flight 18:40 · be at the airport 2.5 hr early",
             [("Nanluoguxiang", "09:30", "45 min"), ("Drum & Bell Towers", "11:00", "45 min"), ("Daoxiangcun run", "13:00", "45 min"), ("Beijing Capital Airport", "16:00", "Flight")]),
            ("Temple of Heaven & Beihai", "4 stops · 5.1 km · ~6 hr", "Pico pick", .accent,
             "Enter the Temple of Heaven from the south gate · rent a boat if the weather holds",
             [("Temple of Heaven", "09:00", "1.5 hr"), ("Lunch in Qianmen", "12:30", "1.5 hr"), ("Beihai Park", "15:00", "1.5 hr"), ("Shichahai at dusk", "18:00", "1.5 hr")]),
            ("Museum morning · departure", "3 stops · 2.4 km · ~5 hr", "Departure", .ok,
             "Real-name booking needed for the museum · flight at 18:40",
             [("National Museum of China", "09:30", "2 hr"), ("Lunch in Qianmen", "12:30", "1.5 hr"), ("Beijing Capital Airport", "16:00", "Flight")])
        ]

        let total = min(max(count, 1), seeds.count)
        var days: [TripDay] = []
        for index in 0..<total {
            let seed = seeds[index]
            var dayStops: [RouteStop]
            if index == 0 {
                dayStops = stops
            } else {
                let coords = Self.dayCoordinates[(index - 1) % Self.dayCoordinates.count]
                dayStops = seed.stops.enumerated().map { position, item in
                    let point = coords[position % coords.count]
                    return RouteStop(
                        name: item.0,
                        time: item.1,
                        duration: item.2,
                        x: point.x,
                        y: point.y,
                        tag: position == 0 ? "Start" : "",
                        tagStyle: .soft
                    )
                }
            }
            let stamp = tripStamp(index)
            days.append(
                TripDay(
                    date: stamp.date,
                    week: stamp.week,
                    day: index + 1,
                    title: seed.title,
                    meta: seed.meta,
                    tag: seed.tag,
                    tagStyle: seed.style,
                    stops: dayStops,
                    note: seed.note
                )
            )
        }
        return days
    }

    // MARK: Forum
    func toggleSaved(_ place: ForumPlace) {
        if savedPlaces.contains(place.id) {
            savedPlaces.remove(place.id)
        } else {
            savedPlaces.insert(place.id)
            Haptics.tap()
        }
    }

    func toggleSavedPost(_ post: ForumPost) {
        if savedPostIDs.contains(post.id) {
            savedPostIDs.remove(post.id)
        } else {
            savedPostIDs.insert(post.id)
            Haptics.tap()
        }
        toast(savedPostIDs.contains(post.id) ? "Saved · find it in Me" : "Removed from saved", icon: "bookmark.fill")
    }

    // MARK: Attractions

    var bookedAttractionCount: Int { attractions.filter(\.booked).count }

    var attractionProgress: Double {
        attractions.isEmpty ? 0 : Double(bookedAttractionCount) / Double(attractions.count)
    }

    var pendingAttractions: [AttractionBooking] {
        attractions.filter { !$0.booked }
    }

    func bookAttraction(_ attraction: AttractionBooking) {
        guard let index = attractions.firstIndex(where: { $0.id == attraction.id }), !attractions[index].booked else { return }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
            attractions[index].booked = true
            attractions[index].code = Self.makeBookingCode()
        }
        Haptics.success()
        toast("Booked \(attraction.title) · scan your ID at the gate", icon: "ticket.fill")
    }

    func bookAllAttractions() {
        guard !pendingAttractions.isEmpty else { return }
        let count = pendingAttractions.count
        withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
            for index in attractions.indices where !attractions[index].booked {
                attractions[index].booked = true
                attractions[index].code = Self.makeBookingCode()
            }
        }
        Haptics.success()
        toast("Booked \(count) sights · passes ready", icon: "checkmark.seal.fill")
    }

    private static func makeBookingCode() -> String {
        "ROAMCHINA-" + String((0..<4).map { _ in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".randomElement()! })
    }

    func joinEvent() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            joinedEvent.toggle()
        }
        Haptics.success()
        toast(joinedEvent ? "Joined · added to your 10/18 plan" : "Left event", icon: joinedEvent ? "checkmark.circle.fill" : "xmark.circle")
    }

    func toggleJoin(_ event: LocalEvent) {
        if joinedEventIDs.contains(event.id) {
            joinedEventIDs.remove(event.id)
        } else {
            joinedEventIDs.insert(event.id)
            Haptics.success()
        }
        toast(
            joinedEventIDs.contains(event.id) ? "Joined · \(event.title)" : "Left event",
            icon: joinedEventIDs.contains(event.id) ? "checkmark.circle.fill" : "xmark.circle"
        )
    }

    func publishEvent(title: String, date: String, time: String, place: String, fee: String, note: String) {
        let event = LocalEvent(
            title: title,
            subtitle: note.isEmpty ? "Hosted by a community member · all welcome" : note,
            date: date,
            time: time,
            place: place,
            host: "@Wang Bo",
            fee: fee.isEmpty ? "Free" : fee,
            attendees: 1,
            isMine: true,
            tint: 1
        )
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            localEvents.insert(event, at: 0)
            forumPosts.insert(
                ForumPost(
                    author: "Wang Bo",
                    avatar: "W",
                    tint: 5,
                    time: "Just now",
                    kind: .event,
                    title: title,
                    body: note.isEmpty ? "Started by you · all welcome" : note,
                    tags: [date, fee.isEmpty ? "Free" : fee],
                    likes: "0",
                    saves: "0",
                    symbol: "sun.horizon.fill",
                    artTint: 3,
                    height: 150,
                    eventTitle: title,
                    comments: 0,
                    comment: "Started by you · all welcome",
                    isMine: true
                ),
                at: 0
            )
        }
        Haptics.success()
        toast("Event published · in community review", icon: "calendar.badge.plus")
    }

    // MARK: Assistant
    func openAssistant(_ context: String) {
        assistantContext = context
        assistantOpen = true
        Haptics.tap()
        if chatMessages.isEmpty {
            seedAssistant()
        }
    }

    var quickPrompts: [String] {
        if assistantContext.contains("Ticket") || assistantContext.contains("Forbidden City") {
            return ["How do I book the Forbidden City?", "Any tickets left?", "How do I get there?"]
        }
        if assistantContext.contains("Translate") {
            return ["How do I say 'doctor'?", "Make the text bigger", "How do I ask for a taxi?"]
        }
        if assistantContext.contains("Checklist") {
            return ["What's still missing?", "How do I set up a VPN?", "Which eSIM should I get?"]
        }
        switch tab {
        case .trip: return ["How do I book the Forbidden City?", "Which area should I stay in?", "What should I wear in October?"]
        case .plan: return ["Rework my route", "Any coffee nearby?", "Make a visual note"]
        case .forum: return ["Which duck place has no queue?", "What gifts should I bring?", "Any local events?"]
        case .translate: return ["How do I say 'doctor'?", "Call me a taxi", "Show staff a bigger text"]
        case .me: return ["How do offline packs work?", "How do I set up a VPN?", "Export my trip"]
        }
    }

    func seedAssistant() {
        if showPlanBuilder {
            chatMessages = [ChatMessage(role: .assistant, text: "Hi, I'm Pico. Tell me what kind of trip you like and I'll build your first Beijing plan — route order, timing and all.")]
            return
        }
        let text: String
        switch tab {
        case .trip:
            text = "Ask me anything about today's route — timing, tickets, food nearby, or a stop you want to swap."
        case .plan:
            text = "I can compare this route with another, trim the walking, or suggest a coffee stop. What would you like to change?"
        case .forum:
            text = "Ask me whether a community route fits your trip, or where to eat near any stop."
        case .translate:
            text = "Ask me to translate a phrase for a shop, a taxi, or a doctor. I'll keep it short enough to show on screen."
        case .me:
            text = "Ask me what to prepare before you fly — tickets, eSIM, VPN, or what to pack."
        }
        chatMessages = [ChatMessage(role: .assistant, text: text)]
    }

    func resetChat() {
        chatMessages = []
        seedAssistant()
    }

    func buildPlan() {
        guard let persona = quizPersona else {
            Haptics.tap()
            return
        }
        onboarding = false
        planBuilt = true
        assistantContext = "Plan · \(persona.fit) · \(planLength) days"
        routeName = "\(persona.fit) · New plan"
        tripDays = makeTripDays(stops: stops, count: planLength)
        tripDay = 0
        tripEdit = false
        tripSaved = false
        tripDirty = false
        tripLive = false
        liveStop = 0
        let note = quizNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let answers = "\(quizDays ?? "") · \(quizStyle ?? "") · \(quizTheme ?? "")"
        chatMessages.append(ChatMessage(role: .user, text: note.isEmpty ? answers : "\(answers) · \(note)"))
        chatThinking = true
        Haptics.tap()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_250_000_000)
            guard let self else { return }
            self.chatThinking = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                self.chatMessages.append(ChatMessage(role: .assistant, text: self.planNarrative(persona), card: .plan))
            }
            Haptics.success()
            self.firstRunFlow = false
            if self.assistantOpen {
                self.tab = .trip
                self.assistantOpen = false
                try? await Task.sleep(for: .milliseconds(360))
            }
            self.toast("Plan ready · \(self.planLength) days on your trip", icon: "sparkles")
        }
    }

    /// Rebuilt from the current quiz every time it is shown, so switching
    /// language also switches an already-delivered plan message.
    var planNarrativeText: String {
        guard let persona = quizPersona else { return "" }
        return planNarrative(persona)
    }

    private func planNarrative(_ persona: TravelPersona) -> String {
        let note = persona.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if lang == .zh {
            let detail: String
            switch quizStyle {
            case "Food first":
                detail = "午饭是 11:30 排队前的烤鸭，景点之间还留了咖啡空档。"
            case "Outdoors":
                detail = "上午都在户外——日出时的景山、长城山脊、北海划船。"
            case "Night owl":
                detail = "17:00 前看完景点，之后鼓楼和后海接着带你过夜。"
            case "Family friendly":
                detail = "每天只排两个重点，中间留足休息和找洗手间的时间，地铁优先、少走回头路。"
            case "Budget smart":
                detail = "门票按免费或低价优先，午饭挑本地小馆，交通全用地铁和步行。"
            default:
                detail = "两段长长的博物馆时间和一个茶馆下午，每天走路不超过 4 公里。"
            }
            let who = L10n.text(persona.title, lang)
            let noteLine = note.isEmpty ? "" : "你写的「\(note)」我也记下了，排路线时会先顾这个。"
            return "搞定。我给\(who)排了 \(planLength) 天的路线，第一天留给故宫。\(detail)\(noteLine)想改什么直接说。"
        }
        let detail: String
        switch quizStyle {
        case "Food first":
            detail = "Lunch is a duck stop before the 11:30 queue, with coffee gaps between sights."
        case "Outdoors":
            detail = "Mornings stay outside — Jingshan at sunrise, the Great Wall ridge walk, boats at Beihai."
        case "Night owl":
            detail = "Sights finish by 17:00, then the Drum Tower and Houhai carry you into the evening."
        case "Family friendly":
            detail = "Two highlights a day, with rest and bathroom breaks between them, and metro over long walks."
        case "Budget smart":
            detail = "Free and low-cost sights first, lunch at local noodle shops, metro and walking only."
        default:
            detail = "Two long museum stops and a teahouse afternoon, never more than 4 km of walking a day."
        }
        let noteLine = note.isEmpty ? "" : " I kept your note in mind: “\(note)”."
        return "Done. I built a \(planLength)-day route for \(persona.title), keeping the palace on day one. \(detail)\(noteLine) Adjust anything by just asking."
    }

    /// Handles one-off chat lines such as the quiz answer recap and the
    /// "Looking at" context, which are composed from English data at runtime.
    func chatDisplay(_ text: String) -> String {
        guard lang == .zh else { return text }
        let exact = L10n.text(text, lang)
        if exact != text { return exact }
        guard text.contains(" · ") else { return text }
        return text.components(separatedBy: " · ").map { part in
            if part.hasSuffix(" days"), let count = Int(part.dropLast(5)) {
                return "\(count) 天"
            }
            return L10n.text(part, lang)
        }.joined(separator: " · ")
    }

    func sendChat(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !chatThinking else { return }
        chatMessages.append(ChatMessage(role: .user, text: text))
        chatDraft = ""
        chatThinking = true
        let history = chatMessages
        Task { [weak self] in
            guard let self else { return }
            do {
                let reply = try await PicoService.reply(history: history, context: self.picoContext)
                self.chatThinking = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    self.chatMessages.append(ChatMessage(role: .assistant, text: reply))
                }
                Haptics.tap()
            } catch {
                self.chatThinking = false
                let fallback = "Pico couldn't reach the live model just now. Try once more in a moment."
                let key = error.localizedDescription.isEmpty ? fallback : error.localizedDescription
                withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                    self.chatMessages.append(ChatMessage(role: .assistant, text: L10n.text(key, self.lang)))
                }
            }
        }
    }

    var picoContext: PicoService.Context {
        let day = (tab == .trip && planBuilt) ? currentTripDay.map { "\($0.title) · \($0.date)" } : nil
        return PicoService.Context(
            tab: assistantContext,
            day: day,
            planBuilt: planBuilt,
            days: planBuilt ? tripDayCount : nil,
            style: quizStyle,
            theme: quizTheme,
            note: quizNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : String(quizNote.prefix(140)),
            stage: tripLive ? "Journey in progress" : (planBuilt ? "Plan saved" : "Planning the first trip"),
            language: lang == .zh ? "zh" : "en"
        )
    }

    // MARK: Translate
    func simulateListening() {
        guard !listening else { return }
        Haptics.tap()
        listening = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            guard let self else { return }
            self.listening = false
            let reply = LiveMessage(
                zh: "这附近有推荐的早餐吗？",
                en: "Any breakfast places around here?",
                isMine: false
            )
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                self.liveMessages.append(reply)
            }
            Haptics.success()
        }
    }

    func setPhotoSample(_ sample: PhotoSample) {
        guard photoSample != sample else { return }
        photoSample = sample
        withAnimation(.easeOut(duration: 0.2)) {
            photoScanned = false
        }
        Haptics.tap()
    }

    func scanPhoto() {
        guard !photoScanning else { return }
        Haptics.tap()
        photoScanned = false
        photoScanning = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_250_000_000)
            guard let self else { return }
            self.photoScanning = false
            withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                self.photoScanned = true
            }
            Haptics.success()
        }
    }

    func clearPhoto() {
        withAnimation(.easeOut(duration: 0.2)) {
            photoScanned = false
            photoScanning = false
        }
        Haptics.tap()
    }

    // MARK: Toast
    func toast(_ text: String, icon: String = "checkmark.circle.fill") {
        let newToast = Toast(text: text, icon: icon)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            toast = newToast
        }
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_400_000_000)
            guard let self, self.toast?.id == newToast.id else { return }
            withAnimation(.easeOut(duration: 0.2)) {
                self.toast = nil
            }
        }
    }

    // MARK: Seed data
    private static func makeChecklist() -> [ChecklistItem] {
        [
            ChecklistItem(title: "Passport valid 6+ months", meta: "Confirmed · expires 03/2027", category: .docs, phase: .before, status: .done, trailing: "Verified"),
            ChecklistItem(title: "Flights & hotel booked", meta: "Ticketed · Wangfujing, 3 nights", category: .docs, phase: .before, status: .done, trailing: "View"),
            ChecklistItem(title: "Travel insurance · active", meta: "Allianz · ¥800k cover", category: .docs, phase: .before, status: .done, trailing: "Active"),
            ChecklistItem(title: "Forbidden City tickets · 10/15 09:00", meta: "2 adults · ¥120 · 812 left", category: .tickets, phase: .before, status: .action, actionLabel: "Book", tag: "Selling fast", tagStyle: .warn),
            ChecklistItem(title: "Great Wall · 10/16 08:30", meta: "Badaling · cable car needs booking", category: .tickets, phase: .before, status: .action, actionLabel: "Book", tag: "To book", tagStyle: .neutral),
            ChecklistItem(title: "Summer Palace · 10/17 09:00", meta: "Combined ticket ¥60 / person", category: .tickets, phase: .before, status: .todo, actionLabel: "Buy"),
            ChecklistItem(title: "National Museum · 10/17 14:00", meta: "Free · real-name booking", category: .tickets, phase: .before, status: .todo, actionLabel: "Book"),
            ChecklistItem(title: "eSIM / China number", meta: "3 plans compared · from ¥29", category: .connectivity, phase: .arrival, status: .action, actionLabel: "Choose plan"),
            ChecklistItem(title: "VPN", meta: "Not on China's App Store", category: .connectivity, phase: .arrival, status: .action, actionLabel: "Guide", tag: "Install early", tagStyle: .warn),
            ChecklistItem(title: "Offline maps & phrases", meta: "Beijing · 86 emergency phrases", category: .connectivity, phase: .arrival, status: .done, trailing: "Downloaded"),
            ChecklistItem(title: "Alipay / WeChat Pay", meta: "VISA linked · ¥5,000 per payment", category: .transit, phase: .arrival, status: .done, trailing: "Done"),
            ChecklistItem(title: "Transit card / metro QR", meta: "Apple Wallet · active", category: .transit, phase: .arrival, status: .done, trailing: "Active")
        ]
    }

    private static func makeStops() -> [RouteStop] {
        [
            RouteStop(name: "Tiananmen Square", time: "09:00", duration: "30 min", x: 0.49, y: 0.86, tag: "Photo"),
            RouteStop(name: "Forbidden City", time: "09:40", duration: "3 hr", x: 0.52, y: 0.67, tag: "Booked", tagStyle: .ok),
            RouteStop(name: "Jingshan Park", time: "13:00", duration: "1 hr", x: 0.57, y: 0.56, tag: "Views"),
            RouteStop(name: "Shichahai", time: "15:00", duration: "1.5 hr", x: 0.37, y: 0.38, tag: "Pico pick", tagStyle: .accent),
            RouteStop(name: "Nanluoguxiang", time: "16:30", duration: "45 min", x: 0.61, y: 0.31, tag: "Coffee"),
            RouteStop(name: "Drum & Bell Towers", time: "17:30", duration: "45 min", x: 0.50, y: 0.20, tag: "Sunset")
        ]
    }

    private static func makeForumPosts() -> [ForumPost] {
        [
            ForumPost(author: "Xiaoman", avatar: "X", tint: 5, time: "2 hr ago", kind: .spot,
                      title: "Sunset at Jingshan's Wanchun Pavilion beats the photos",
                      body: "Get up there by 17:00 and the palace roofs turn gold. The east railing is the shot — claim it early.",
                      tags: ["Jingshan", "Sunset", "Viewpoint"], likes: "3.4k", saves: "862",
                      symbol: "sun.horizon.fill", artTint: 3, height: 174, photo: "post-n1", credit: "EditQ / CC BY-SA 4.0",
                      placeTitle: "Sunset at Jingshan", comment: "@Zhe: Went on Wednesday — the sun hit the ridge at 17:10."),
            ForumPost(author: "Ken", avatar: "K", tint: 4, time: "4 hr ago", kind: .route,
                      title: "The Central Axis in a day: Yongdingmen to the Drum Tower",
                      body: "6 stops, 4.2 km. Start at 3pm and you land at Jingshan for sunset. The metro is a backup the whole way.",
                      tags: ["Central Axis", "Walk", "Route"], likes: "2.1k", saves: "1.2k",
                      symbol: "point.topleft.down.to.point.bottomright.curvepath", artTint: 4, height: 120, photo: "post-n2", credit: "xiquinhosilva / CC BY 4.0",
                      routeIndex: 1, comment: "@Lina: Finished it — feet survived, two coffee stops helped."),
            ForumPost(author: "Zhe", avatar: "Z", tint: 3, time: "5 hr ago", kind: .restaurant,
                      title: "Siji Minfu before 11 — no queue, really",
                      body: "Dip the duck skin in sugar first; half a bird feeds two. After 3pm you rarely wait at all.",
                      tags: ["Duck", "Forbidden City", "Queue"], likes: "2.3k", saves: "708",
                      symbol: "fork.knife", artTint: 0, height: 146, photo: "post-n3", credit: "Mr Wabu / CC BY-SA 2.0",
                      placeTitle: "Siji Minfu · Forbidden City", comment: "@Zhou: Got there at 10:40 and walked straight in."),
            ForumPost(author: "Lina", avatar: "L", tint: 0, time: "Yesterday", kind: .restaurant,
                      title: "Qianmen hutong coffee, best light at 3pm",
                      body: "Metal Hands hides in a back lane; the two window tables are the quietest. The pour-over runs bright — pair it with a croissant.",
                      tags: ["Coffee", "Hutong", "Afternoon"], likes: "1.1k", saves: "433",
                      symbol: "cup.and.saucer.fill", artTint: 1, height: 162, photo: "post-n4", credit: "Arisepeter / CC BY-SA 4.0",
                      placeTitle: "Metal Hands · Qianmen", comment: "@Bei: Sat there two hours on Sunday, nobody rushed us."),
            ForumPost(author: "Zhou", avatar: "Z", tint: 2, time: "Yesterday", kind: .spot,
                      title: "Early morning at the Temple of Heaven, almost empty",
                      body: "Enter from the south gate; the Echo Wall is quietest before nine. Cypress shadows fall on red walls — every shot works.",
                      tags: ["Temple of Heaven", "Morning", "Architecture"], likes: "2.8k", saves: "610",
                      symbol: "building.columns.fill", artTint: 2, height: 130, photo: "post-n5", credit: "Balon Greyjoy / CC0",
                      placeTitle: "Temple of Heaven", comment: "@Hutong Files: Locals do tai chi then — keep your voice down."),
            ForumPost(author: "Hutong Files", avatar: "H", tint: 3, time: "2 days ago", kind: .event,
                      title: "Saturday night market at the Drum Tower: stall list updated",
                      body: "Handmade goods, vinyl and mulled wine; busiest after 19:00. Metro Line 8, Shichahai exit A.",
                      tags: ["Night market", "Drum & Bell Towers", "Weekend"], likes: "986", saves: "241",
                      symbol: "moon.stars.fill", artTint: 3, height: 154, photo: "post-n6", credit: "Marek Śliwecki / CC BY-SA 4.0",
                      eventTitle: "Hutong Night Market · Free entry", comment: "@Ken: Signed up — see you there."),
            ForumPost(author: "Zhao", avatar: "Z", tint: 1, time: "2 days ago", kind: .gift,
                      title: "Daoxiangcun loose pastries vs gift boxes: how locals buy",
                      body: "Loose pastries are sold by weight — fresher, and you can mix flavors. Boxes are for giving; no need for yourself.",
                      tags: ["Gifts", "Daoxiangcun", "Save money"], likes: "1.7k", saves: "529",
                      symbol: "gift.fill", artTint: 5, height: 138, photo: "post-n7", credit: "Zicheng zic / CC BY 4.0",
                      placeTitle: "Daoxiangcun · Local gifts", comment: "@Xiaoman: Get the date paste and ox-tongue pastry."),
            ForumPost(author: "Zhe", avatar: "Z", tint: 3, time: "3 days ago", kind: .route,
                      title: "Shichahai after dark: 5 stops, 3 small bars",
                      body: "Start at Yinding Bridge and follow the north shore to the Drum Tower. Quieter after nine; bring a jacket, it's windy.",
                      tags: ["Night", "Shichahai", "Bars"], likes: "860", saves: "377",
                      symbol: "figure.walk", artTint: 2, height: 126, photo: "post-n8", credit: "Morio / CC BY-SA 4.0",
                      routeIndex: 2, comment: "@Lina: The brewpub by Yinding Bridge is solid."),
            ForumPost(author: "Bei", avatar: "B", tint: 0, time: "3 days ago", kind: .gift,
                      title: "Corner-tower magnets are back — buy on the way in",
                      body: "The Shenwu Gate shop restocks in the morning and the corner-tower series sells out. Two per person — don't wait for closing.",
                      tags: ["Palace shop", "Magnets", "Limited"], likes: "604", saves: "188",
                      symbol: "sparkles", artTint: 0, height: 112, photo: "post-n9", credit: "Morio / CC BY-SA 4.0",
                      placeTitle: "Palace Museum Shop · Magnets", comment: "@Zhou: They had the sunset color yesterday. Go."),
            ForumPost(author: "May", avatar: "M", tint: 5, time: "4 days ago", kind: .restaurant,
                      title: "40 minutes in line at Man Heng Ji — worth it?",
                      body: "Hand-cut lamb with sesame dip; once the copper pot boils you know the wait paid off. Take a number before 17:00 and halve it.",
                      tags: ["Hotpot", "Niujie", "Queue"], likes: "1.9k", saves: "522",
                      symbol: "flame.fill", artTint: 3, height: 140, photo: "post-n10", credit: "ZhengZhou / CC BY-SA 4.0",
                      placeTitle: "Man Heng Ji · Niujie", comment: "@Zhao: Worth it. Order extra sweet garlic."),
            ForumPost(author: "Lina", avatar: "L", tint: 0, time: "5 days ago", kind: .spot,
                      title: "Boating at Beihai: the White Dagoba from the water",
                      body: "After 4pm the sun softens; a pedal boat for an hour is just right. They stop rentals when it's windy.",
                      tags: ["Beihai", "Boating", "Family"], likes: "2.1k", saves: "498",
                      symbol: "sailboat.fill", artTint: 1, height: 148, photo: "post-n11", credit: "Daniel Case / CC BY-SA 3.0",
                      placeTitle: "Beihai Park", comment: "@Bei: With kids, take the electric boat.")
        ]
    }

    private static func makeAttractions() -> [AttractionBooking] {
        [
            AttractionBooking(
                title: "Forbidden City", date: "10/15", day: 1, time: "09:00 – 12:00",
                price: "¥60 · 2 adults", symbol: "building.columns.fill", tint: 3,
                booked: true, code: "ROAMCHINA-7Q2K"
            ),
            AttractionBooking(
                title: "Badaling Great Wall", date: "10/16", day: 2, time: "08:30 meet",
                price: "¥40 · cable car included", symbol: "mountain.2.fill", tint: 2
            ),
            AttractionBooking(
                title: "Summer Palace", date: "10/17", day: 3, time: "09:00 – 12:00",
                price: "¥60 · combined ticket", symbol: "leaf.fill", tint: 4
            ),
            AttractionBooking(
                title: "National Museum of China", date: "10/17", day: 3, time: "14:00 – 16:30",
                price: "Free · real-name booking", symbol: "building.columns", tint: 1
            )
        ]
    }

    private static func makeLocalEvents() -> [LocalEvent] {
        [
            LocalEvent(
                title: "Hutong Night Market · Free entry",
                subtitle: "Handmade goods, vinyl and snacks from local stalls",
                date: "10/18 Sat",
                time: "18:00 – 22:00",
                place: "Drum & Bell Towers square · 35 min from hotel",
                host: "@Pico Community",
                fee: "Free",
                attendees: 128,
                tint: 0
            ),
            LocalEvent(
                title: "Baita Temple flea market",
                subtitle: "Old cameras, second-hand books and pour-over coffee, run by local collectors",
                date: "11/01 Sat",
                time: "13:00 – 19:00",
                place: "Baita Temple east lane · 20 min from hotel",
                host: "@Hutong Files",
                fee: "Free",
                attendees: 64,
                tint: 1
            ),
            LocalEvent(
                title: "Central Axis night ride · BYO bike",
                subtitle: "Yongdingmen to the Drum Tower with a guide on the old city gates",
                date: "11/02 Sun",
                time: "19:00",
                place: "Yongdingmen Park, north gate",
                host: "@Ken",
                fee: "¥20",
                attendees: 37,
                tint: 3
            )
        ]
    }
}

// MARK: - Speech

final class SpeechService {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String, language: String = "zh-CN") {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.46
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
}
