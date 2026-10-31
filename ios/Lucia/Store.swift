import SwiftUI
import AVFoundation

@MainActor
final class AppModel: ObservableObject {

    // MARK: Navigation
    @Published var tab: Tab = .trip
    @Published var checklistOpen = false
    @Published var assistantOpen = false
    @Published var assistantContext = Tab.trip.assistantContext
    @Published var notesOpen = false

    // MARK: Trip
    @Published var reminderDismissed = false
    @Published var checklist: [ChecklistItem]
    @Published var toast: Toast?

    // MARK: Plan
    @Published var routeName = "北京中轴线 · 草稿"
    @Published var stops: [RouteStop]
    @Published var selectedStopID: UUID?
    @Published var layer: MapLayer = .mine
    @Published var aiSuggestionVisible = true
    @Published var routeApplied = false
    @Published var mapEditMode = false

    // MARK: Forum
    @Published var forumFilter: ForumFilter = .all
    @Published var forumSearch = ""
    @Published var joinedEvent = false
    @Published var joinedEventIDs: Set<UUID> = []
    @Published var savedPlaces: Set<UUID> = []
    @Published var localEvents: [LocalEvent]

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

    // MARK: Chat
    @Published var chatMessages: [ChatMessage] = []
    @Published var chatDraft = ""
    @Published var chatThinking = false

    // MARK: Static demo content
    let forumRoutes: [ForumRoute] = [
        ForumRoute(title: "2 天胡同慢走 · 8 站", author: "@Lina", meta: "4.8 分 · 收藏 1.2k", tags: ["轻松", "咖啡", "拍照"], stops: 8, distance: "6.4 km", likes: "1.2k"),
        ForumRoute(title: "北京中轴线 · 半日", author: "@Ken", meta: "4.9 分 · 收藏 2.1k", tags: ["经典", "步行", "日落"], stops: 6, distance: "4.2 km", likes: "2.1k"),
        ForumRoute(title: "鼓楼到后海 · 夜走", author: "@阿哲", meta: "4.7 分 · 收藏 968", tags: ["夜游", "酒吧", "轻松"], stops: 5, distance: "3.8 km", likes: "968")
    ]

    let forumPlaces: [ForumPlace] = [
        ForumPlace(title: "四季民福 · 故宫店", subtitle: "11:00 前到不排队 · 烤鸭", price: "¥150", tags: ["家庭", "本地人常去"], kind: .restaurant, likes: "2.3k", symbol: "fork.knife", tint: 0, heat: 96, area: "东城 · 故宫", note: "下午三点以后去几乎不用等位，鸭皮还是脆的。", bestTime: "11:00 前 / 15:00 后"),
        ForumPlace(title: "满恒记 · 牛街", subtitle: "手切鲜羊肉 · 铜锅涮肉", price: "¥95", tags: ["本地", "排队"], kind: .restaurant, likes: "1.9k", symbol: "flame", tint: 6, heat: 93, area: "西城 · 牛街", note: "手切羊肉配麻酱，本地人排队也愿意等。", bestTime: "17:00 前取号"),
        ForumPlace(title: "胖妹面庄 · 北新桥", subtitle: "小面 · 现炸酥肉", price: "¥45", tags: ["本地", "快吃"], kind: .restaurant, likes: "886", symbol: "takeoutbag.and.cup.and.straw", tint: 1, heat: 88, area: "东城 · 北新桥", note: "小面要少辣，酥肉现炸的最好吃。", bestTime: "工作日 14:00"),
        ForumPlace(title: "Metal Hands · 前门", subtitle: "胡同咖啡 · 自家烘焙", price: "¥45", tags: ["咖啡", "安静"], kind: .restaurant, likes: "1.1k", symbol: "cup.and.saucer.fill", tint: 5, heat: 81, area: "东城 · 前门", note: "巷子里的安静咖啡馆，下午光线最好。", bestTime: "15:00–17:00"),
        ForumPlace(title: "稻香村 · 本地人伴手礼", subtitle: "避开网红款 · 8 件", price: "¥50–120", tags: ["伴手礼", "可托运"], kind: .gift, likes: "1.7k", symbol: "gift", tint: 2, heat: 86, area: "各城区门店", note: "散装点心比礼盒更值得买，记得要新鲜日期。", bestTime: "上午补货"),
        ForumPlace(title: "故宫文创 · 冰箱贴", subtitle: "角楼系列 · 限定色", price: "¥39", tags: ["轻便", "限定"], kind: .gift, likes: "604", symbol: "sparkles", tint: 3, heat: 78, area: "故宫 · 神武门", note: "角楼冰箱贴经常断货，进门先买。", bestTime: "开馆后 1 小时"),
        ForumPlace(title: "同仁堂 · 酸梅汤原料", subtitle: "煮一壶老北京的夏天", price: "¥38", tags: ["可托运", "轻便"], kind: .gift, likes: "512", symbol: "leaf", tint: 7, heat: 74, area: "东城 · 大栅栏", note: "夏天煮一壶，比瓶装饮料更像北京。", bestTime: "任何时间"),
        ForumPlace(title: "景山看日落", subtitle: "17:00 前上山 · 万春亭", price: "免费", tags: ["日落", "俯拍故宫"], kind: .spot, likes: "3.4k", symbol: "sun.horizon", tint: 4, heat: 94, area: "东城 · 景山", note: "17:00 前上万春亭，能拍到故宫全景。", bestTime: "日落前 40 分钟"),
        ForumPlace(title: "天坛公园", subtitle: "回音壁 · 古柏与祈年殿", price: "¥34", tags: ["建筑", "人少"], kind: .spot, likes: "2.8k", symbol: "building.columns", tint: 8, heat: 90, area: "东城 · 天坛", note: "从南门进，回音壁人少的时候最有意思。", bestTime: "开园后 1 小时"),
        ForumPlace(title: "北海公园", subtitle: "划船看白塔 · 亲子友好", price: "¥10", tags: ["亲子", "划船"], kind: .spot, likes: "2.1k", symbol: "sailboat", tint: 9, heat: 82, area: "西城 · 北海", note: "租一条船，从湖上看白塔最舒服。", bestTime: "15:00 后")
    ]

    let forumEvent = ForumEvent(
        title: "胡同夜市 · 免费入场",
        subtitle: "手作、黑胶与小吃，本地摊主出摊",
        date: "10/18 周六 · 18:00",
        place: "钟鼓楼广场 · 距酒店 35 分钟",
        attendees: 128
    )

    let similarRoutes: [SimilarRoute] = [
        SimilarRoute(
            title: "北京中轴线 · 经典半日",
            author: "@Ken",
            match: 94,
            stops: 6,
            distance: "4.2 km",
            duration: "约 5 小时",
            tags: ["经典", "步行", "日落"],
            highlight: "和你的 6 个点位重合 5 个，故宫段顺序一致。"
        ),
        SimilarRoute(
            title: "胡同咖啡慢走 · 8 站",
            author: "@Lina",
            match: 87,
            stops: 8,
            distance: "6.4 km",
            duration: "约一整天",
            tags: ["咖啡", "拍照", "轻松"],
            highlight: "把南锣鼓巷换成 3 家咖啡店，适合下午出发。"
        ),
        SimilarRoute(
            title: "景山落日 + 什刹海夜走",
            author: "@阿哲",
            match: 79,
            stops: 5,
            distance: "3.8 km",
            duration: "约 3 小时",
            tags: ["夜游", "日落", "本地"],
            highlight: "保留你的景山日落，回程沿什刹海走，少一次折返。"
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
        applySavedChecklist()
        applyLaunchScreen()
    }

    // Enables screenshot QA: `simctl launch ... ai.lucia.travel -plan`
    private func applyLaunchScreen() {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-plan") || args.contains("-similar") { tab = .plan }
        if args.contains("-mapedit") {
            tab = .plan
            mapEditMode = true
            aiSuggestionVisible = false
            selectedStopID = stops.first(where: { $0.name == "故宫博物院" })?.id
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
        if args.contains("-assistant") {
            assistantContext = tab.assistantContext
            seedAssistant()
            assistantOpen = true
        }
        if args.contains("-place") || args.contains("-compose") { tab = .forum }
        if args.contains("-reorder") { tab = .plan }
        if args.contains("-bigtype") {
            tab = .translate
            translateMode = .offline
        }
        #endif
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
        toast("已完成 · \(item.title)", icon: "checkmark.seal.fill")
    }

    func bookForbiddenCity() {
        if let index = checklist.firstIndex(where: { $0.title.hasPrefix("故宫门票") }) {
            withAnimation { checklist[index].status = .done }
            persistChecklist()
        }
        Haptics.success()
        toast("已锁定 10/15 09:00 · 成人 ×2", icon: "ticket.fill")
    }

    func aiRecheck() {
        let open = checklist.filter { $0.status != .done }.count
        Haptics.success()
        if open == 0 {
            toast("12 项全部核对完成", icon: "checkmark.seal.fill")
        } else {
            toast("复查完成 · \(open) 项待处理，已排好顺序", icon: "sparkles")
        }
    }

    func addToChecklist(title: String, meta: String, category: ChecklistCategory = .tickets, phase: ChecklistPhase = .before) {
        guard !checklist.contains(where: { $0.title == title }) else {
            toast("清单里已有这一项", icon: "checkmark.circle.fill")
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
                    actionLabel: "查看",
                    tag: "新增",
                    tagStyle: .accent
                )
            )
        }
        Haptics.success()
        persistChecklist()
        toast("已加入行前清单", icon: "text.badge.plus")
    }

    var checklistSummary: String {
        let lines = checklist.map { item -> String in
            "\(item.status == .done ? "✓" : "○") \(item.title) — \(item.meta)"
        }
        return "Lucia · 北京 4 天 3 晚 行前清单\n进度 \(doneCount)/\(totalCount)\n\n" + lines.joined(separator: "\n")
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
            toast("编辑点位 · 直接拖动地图上的编号", icon: "hand.draw.fill")
        }
    }

    func moveStop(_ id: UUID, toX x: CGFloat, toY y: CGFloat) {
        guard let index = stops.firstIndex(where: { $0.id == id }) else { return }
        stops[index].x = min(max(x, 0.06), 0.94)
        stops[index].y = min(max(y, 0.10), 0.90)
    }

    func didFinishMovingStop() {
        Haptics.success()
        toast("点位已更新 · 路线已重新连好", icon: "map.fill")
    }

    func applyRouteSuggestion() {
        let order = ["天安门广场", "故宫博物院", "什刹海", "景山公园", "南锣鼓巷", "钟鼓楼"]
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
        Haptics.success()
        toast("已应用 · 路线重算完成，少走 1.2 km", icon: "arrow.triangle.swap")
    }

    func moveStops(from source: IndexSet, to destination: Int) {
        stops.move(fromOffsets: source, toOffset: destination)
        renumberStops()
        toast("顺序已更新", icon: "arrow.up.arrow.down")
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
        routeName = name + " · 副本"
        routeApplied = false
        aiSuggestionVisible = true
        tab = .plan
        selectedStopID = stops.first?.id
        Haptics.success()
        toast("已套用并生成独立副本", icon: "doc.on.doc.fill")
    }

    func shareRoute() {
        toast("路线分享链接已复制", icon: "link")
    }

    var routeSummary: String {
        let lines = stops.enumerated().map { index, stop in
            "\(index + 1). \(stop.name) · \(stop.time) · \(stop.duration)"
        }
        return "\(routeName)\n6 站 · 4.2 km · 约 5 小时\n\n" + lines.joined(separator: "\n") + "\n\n来自 Lucia · 北京旅行计划"
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

    func joinEvent() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            joinedEvent.toggle()
        }
        Haptics.success()
        toast(joinedEvent ? "已报名 · 已同步 10/18 行程" : "已取消报名", icon: joinedEvent ? "checkmark.circle.fill" : "xmark.circle")
    }

    func toggleJoin(_ event: LocalEvent) {
        if joinedEventIDs.contains(event.id) {
            joinedEventIDs.remove(event.id)
        } else {
            joinedEventIDs.insert(event.id)
            Haptics.success()
        }
        toast(
            joinedEventIDs.contains(event.id) ? "已报名 · \(event.title)" : "已取消报名",
            icon: joinedEventIDs.contains(event.id) ? "checkmark.circle.fill" : "xmark.circle"
        )
    }

    func publishEvent(title: String, date: String, time: String, place: String, fee: String, note: String) {
        let event = LocalEvent(
            title: title,
            subtitle: note.isEmpty ? "社区成员发起 · 欢迎来玩" : note,
            date: date,
            time: time,
            place: place,
            host: "@王博",
            fee: fee.isEmpty ? "免费" : fee,
            attendees: 1,
            isMine: true,
            tint: 1
        )
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            localEvents.insert(event, at: 0)
        }
        Haptics.success()
        toast("活动已发布 · 已进入社区审核", icon: "calendar.badge.plus")
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
        if assistantContext.contains("门票") || assistantContext.contains("故宫") {
            return ["故宫怎么预约", "还有余票吗", "附近怎么走"]
        }
        if assistantContext.contains("翻译") {
            return ["就医怎么说", "帮我放大", "打车怎么说"]
        }
        if assistantContext.contains("清单") {
            return ["还差什么", "VPN 怎么弄", "eSIM 选哪个"]
        }
        switch tab {
        case .trip: return ["故宫门票怎么约", "住哪个区域方便", "10 月穿什么"]
        case .plan: return ["帮我重排路线", "附近有咖啡吗", "生成可视化笔记"]
        case .forum: return ["哪家烤鸭不排队", "带什么伴手礼", "有本地活动吗"]
        case .translate: return ["就医怎么说", "帮我叫车", "放大给店员看"]
        case .me: return ["离线包怎么用", "怎么开 VPN", "导出我的行程"]
        }
    }

    func seedAssistant() {
        let context = assistantContext
        var card: AssistantCardKind? = nil
        let text: String

        if context.contains("门票") || context.contains("故宫") {
            text = "故宫 10/15 上午还有 812 张余票，成人 ¥60，实名预约、刷身份证入场。要我直接锁定 09:00 的 2 个名额吗？"
            card = .ticket
        } else if context.contains("翻译") {
            text = "就医场景我准备了 4 句，最常用的是「我食物过敏，需要去医院」。你可以放大给店员看，或者让我读出来。"
            card = .translate
        } else if context.contains("清单") {
            text = "我对照天气、闭馆日和余票重新排了一遍：先办 eSIM 和 VPN，再约故宫与长城。新增的 3 项已经放进清单。"
            card = .checklist
        } else {
            switch tab {
            case .trip:
                text = "早上好，王博。我看过你 10/15–18 的行程：白天 22℃、早晚 11℃，故宫周一闭馆，建议把故宫放在 15 号上午。要先锁门票，还是先重排路线？"
                card = .route
            case .plan:
                text = "这版中轴线目前 5.2 km，什刹海排在故宫后面会折返一次。把什刹海挪到 13:00、景山挪到 14:30，能少走 1.2 km。要直接应用吗？"
                card = .route
            case .forum:
                text = "社区里「北京中轴线 · 半日」和你现在的路线重合 4 站，可以直接套用成副本。需要我再对比一下两家烤鸭店吗？"
                card = .route
            case .translate:
                text = "离线语句库已经下载好，86 句覆盖找路、就餐、就医和打车。需要我把就医的 4 句放大，还是先听一遍发音？"
                card = .translate
            case .me:
                text = "你的北京离线包已下载。出发前建议再确认 VPN 和 eSIM——这两项最容易在落地后卡住，需要我一步步带你设置吗？"
                card = .checklist
            }
        }
        chatMessages = [ChatMessage(role: .assistant, text: text, card: card)]
    }

    func resetChat() {
        chatMessages = []
        seedAssistant()
    }

    func sendChat(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        chatMessages.append(ChatMessage(role: .user, text: text))
        chatDraft = ""
        chatThinking = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 700_000_000)
            guard let self else { return }
            self.chatThinking = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) {
                self.chatMessages.append(self.reply(to: text))
            }
            Haptics.tap()
        }
    }

    private func reply(to text: String) -> ChatMessage {
        if text.contains("票") || text.contains("预约") || text.contains("故宫") {
            return ChatMessage(role: .assistant, text: "故宫 10/15 上午还有 812 张余票，成人 ¥60。实名预约后刷身份证入场，我把 09:00 两个成人的时段记在清单里，先锁定吗？", card: .ticket)
        }
        if text.contains("酒店") || text.contains("住") || text.contains("民宿") {
            return ChatMessage(role: .assistant, text: "按你的景点分布，王府井最均衡：到故宫步行 12 分钟，去南锣鼓巷地铁 2 站。我按预算筛了三个区域，可以参考：", card: .hotels)
        }
        if text.contains("天气") || text.contains("穿") || text.contains("冷") || text.contains("热") {
            return ChatMessage(role: .assistant, text: "10/15–17 北京白天 22℃、早晚 11℃，建议薄外套 + 长裤，故宫石板路多带一双软底鞋。18 号可能有小雨，我会在前一晚提醒你。")
        }
        if text.contains("路线") || text.contains("重排") || text.contains("怎么走") || text.contains("绕") {
            return ChatMessage(role: .assistant, text: "我按「少折返」重排了：天安门 → 故宫 → 什刹海 → 景山 → 南锣鼓巷 → 钟鼓楼。能少走 1.2 km，日落刚好在钟鼓楼。", card: .route)
        }
        if text.contains("清单") || text.contains("准备") || text.contains("VPN") || text.contains("eSIM") || text.contains("电话") {
            return ChatMessage(role: .assistant, text: "行前清单里还差 6 项。我挑出最容易卡住的三项：eSIM 套餐、VPN 安装、故宫门票。要一并加进清单吗？", card: .checklist)
        }
        if text.contains("翻译") || text.contains("怎么说") || text.contains("说") || text.contains("英语") {
            return ChatMessage(role: .assistant, text: "我把这句整理成了可以直接给店员看的中英对照，也能播放中文语音。", card: .translate)
        }
        if text.contains("吃") || text.contains("餐") || text.contains("烤鸭") || text.contains("咖啡") {
            return ChatMessage(role: .assistant, text: "四季民福故宫店 11:00 前到基本不排队；想快一点可以去胖妹面庄，人均 ¥45。两家都在你 15 号的路线附近。")
        }
        if text.contains("医院") || text.contains("过敏") || text.contains("紧急") || text.contains("就医") {
            return ChatMessage(role: .assistant, text: "别担心。离线就医语句里有 4 句可以直接放大给医生看，急救电话是 120。需要我把最近的医院也标在地图上吗？")
        }
        return ChatMessage(role: .assistant, text: "我可以帮你查余票、排路线、加清单、翻语句，或者解释附近的吃喝。你想先处理哪一件？")
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
            ChecklistItem(title: "护照有效期 ≥ 6 个月", meta: "已确认 · 2027/03 到期", category: .docs, phase: .before, status: .done, trailing: "已核验"),
            ChecklistItem(title: "往返机票 & 酒店", meta: "已出票 · 王府井 3 晚", category: .docs, phase: .before, status: .done, trailing: "查看"),
            ChecklistItem(title: "旅行保险 · 生效中", meta: "安联 · 保额 ¥80 万", category: .docs, phase: .before, status: .done, trailing: "已生效"),
            ChecklistItem(title: "故宫门票 · 10/15 09:00", meta: "成人 ×2 · ¥120 · 余票 812", category: .tickets, phase: .before, status: .action, actionLabel: "去预约", tag: "余票紧张", tagStyle: .warn),
            ChecklistItem(title: "长城 · 10/16 08:30", meta: "八达岭 · 需预约缆车", category: .tickets, phase: .before, status: .action, actionLabel: "预约", tag: "待预约", tagStyle: .neutral),
            ChecklistItem(title: "颐和园 · 10/17 09:00", meta: "联票 ¥60 / 人", category: .tickets, phase: .before, status: .todo, actionLabel: "购票"),
            ChecklistItem(title: "国家博物馆 · 10/17 14:00", meta: "免费 · 需实名预约", category: .tickets, phase: .before, status: .todo, actionLabel: "预约"),
            ChecklistItem(title: "eSIM / 中国手机号", meta: "3 家方案对比 · 从 ¥29 起", category: .connectivity, phase: .arrival, status: .action, actionLabel: "选套餐"),
            ChecklistItem(title: "VPN", meta: "境内应用商店无法下载", category: .connectivity, phase: .arrival, status: .action, actionLabel: "教程", tag: "提前装", tagStyle: .warn),
            ChecklistItem(title: "离线地图与翻译包", meta: "北京 · 86 句应急表达", category: .connectivity, phase: .arrival, status: .done, trailing: "已下载"),
            ChecklistItem(title: "支付宝 / 微信支付", meta: "已绑定 VISA · 单笔 ≤ ¥5,000", category: .transit, phase: .arrival, status: .done, trailing: "已完成"),
            ChecklistItem(title: "交通卡 / 地铁乘车码", meta: "Apple 钱包 · 已开通", category: .transit, phase: .arrival, status: .done, trailing: "已开通")
        ]
    }

    private static func makeStops() -> [RouteStop] {
        [
            RouteStop(name: "天安门广场", time: "09:00", duration: "30 分钟", x: 0.49, y: 0.86, tag: "拍照"),
            RouteStop(name: "故宫博物院", time: "09:40", duration: "3 小时", x: 0.52, y: 0.67, tag: "已订", tagStyle: .ok),
            RouteStop(name: "景山公园", time: "13:00", duration: "1 小时", x: 0.57, y: 0.56, tag: "登高"),
            RouteStop(name: "什刹海", time: "15:00", duration: "1.5 小时", x: 0.37, y: 0.38, tag: "AI 建议", tagStyle: .accent),
            RouteStop(name: "南锣鼓巷", time: "16:30", duration: "45 分钟", x: 0.61, y: 0.31, tag: "咖啡"),
            RouteStop(name: "钟鼓楼", time: "17:30", duration: "45 分钟", x: 0.50, y: 0.20, tag: "日落")
        ]
    }

    private static func makeLocalEvents() -> [LocalEvent] {
        [
            LocalEvent(
                title: "胡同夜市 · 免费入场",
                subtitle: "手作、黑胶与小吃，本地摊主出摊",
                date: "10/18 周六",
                time: "18:00 – 22:00",
                place: "钟鼓楼广场 · 距酒店 35 分钟",
                host: "@Lucia 社区",
                fee: "免费",
                attendees: 128,
                tint: 0
            ),
            LocalEvent(
                title: "白塔寺旧物市集",
                subtitle: "老相机、旧书与手冲咖啡，摊主多是本地藏家",
                date: "11/01 周六",
                time: "13:00 – 19:00",
                place: "白塔寺东夹道 · 距酒店 20 分钟",
                host: "@胡同档案",
                fee: "免费",
                attendees: 64,
                tint: 1
            ),
            LocalEvent(
                title: "中轴线夜骑 · 自备车",
                subtitle: "从永定门骑到钟鼓楼，领队讲城楼故事",
                date: "11/02 周日",
                time: "19:00",
                place: "永定门公园北门",
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
