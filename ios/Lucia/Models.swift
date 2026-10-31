import Foundation
import CoreGraphics

// MARK: - Navigation

enum Tab: String, CaseIterable, Identifiable {
    case trip, plan, forum, translate, me

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trip: return "行程"
        case .plan: return "计划"
        case .forum: return "论坛"
        case .translate: return "翻译"
        case .me: return "我的"
        }
    }

    var icon: String {
        switch self {
        case .trip: return "house"
        case .plan: return "map"
        case .forum: return "safari"
        case .translate: return "character.bubble"
        case .me: return "person"
        }
    }

    var assistantContext: String {
        switch self {
        case .trip: return "行程 · 10/15 故宫"
        case .plan: return "计划 · 北京中轴线"
        case .forum: return "论坛 · 餐厅与路线"
        case .translate: return "翻译 · 应急语句"
        case .me: return "我的 · 订单与离线包"
        }
    }

    var badge: Int {
        switch self {
        case .trip: return 2
        case .plan: return 1
        default: return 0
        }
    }
}

// MARK: - Checklist

enum ChecklistCategory: String, CaseIterable, Identifiable {
    case docs, connectivity, tickets, transit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .docs: return "证件票务"
        case .connectivity: return "网络通讯"
        case .tickets: return "门票预约"
        case .transit: return "支付交通"
        }
    }

    var short: String {
        switch self {
        case .docs: return "证件"
        case .connectivity: return "网络"
        case .tickets: return "门票"
        case .transit: return "交通"
        }
    }
}

enum ChecklistPhase: String, CaseIterable, Identifiable {
    case before, arrival

    var id: String { rawValue }

    var title: String {
        switch self {
        case .before: return "出发前"
        case .arrival: return "落地当天"
        }
    }
}

enum ChecklistStatus {
    case todo, action, done
}

struct ChecklistItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var meta: String
    var category: ChecklistCategory
    var phase: ChecklistPhase
    var status: ChecklistStatus
    var actionLabel: String?
    var tag: String?
    var tagStyle: TagStyle
    var trailing: String?

    init(
        id: UUID = UUID(),
        title: String,
        meta: String,
        category: ChecklistCategory,
        phase: ChecklistPhase,
        status: ChecklistStatus,
        actionLabel: String? = nil,
        tag: String? = nil,
        tagStyle: TagStyle = .neutral,
        trailing: String? = nil
    ) {
        self.id = id
        self.title = title
        self.meta = meta
        self.category = category
        self.phase = phase
        self.status = status
        self.actionLabel = actionLabel
        self.tag = tag
        self.tagStyle = tagStyle
        self.trailing = trailing
    }
}

// MARK: - Route

struct RouteStop: Identifiable, Equatable {
    let id: UUID
    var name: String
    var time: String
    var duration: String
    var x: CGFloat
    var y: CGFloat
    var tag: String?
    var tagStyle: TagStyle
    var selected: Bool = false

    init(
        id: UUID = UUID(),
        name: String,
        time: String,
        duration: String,
        x: CGFloat,
        y: CGFloat,
        tag: String? = nil,
        tagStyle: TagStyle = .neutral
    ) {
        self.id = id
        self.name = name
        self.time = time
        self.duration = duration
        self.x = x
        self.y = y
        self.tag = tag
        self.tagStyle = tagStyle
    }
}

enum MapLayer: String, CaseIterable, Identifiable {
    case mine, community, crowd

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mine: return "我的路线"
        case .community: return "社区 3"
        case .crowd: return "客流"
        }
    }
}

// MARK: - Translate

enum Scenario: String, CaseIterable, Identifiable {
    case route, dining, medical, taxi, shopping, emergency

    var id: String { rawValue }

    var title: String {
        switch self {
        case .route: return "找路"
        case .dining: return "就餐"
        case .medical: return "就医"
        case .taxi: return "打车"
        case .shopping: return "购物"
        case .emergency: return "紧急求助"
        }
    }

    var icon: String {
        switch self {
        case .route: return "location"
        case .dining: return "fork.knife"
        case .medical: return "cross.case"
        case .taxi: return "car"
        case .shopping: return "bag"
        case .emergency: return "exclamationmark.shield"
        }
    }
}

struct Phrase: Identifiable, Equatable, Hashable {
    let id: UUID
    var zh: String
    var en: String
    var scenario: Scenario

    init(id: UUID = UUID(), zh: String, en: String, scenario: Scenario) {
        self.id = id
        self.zh = zh
        self.en = en
        self.scenario = scenario
    }
}

struct LiveMessage: Identifiable, Equatable {
    let id: UUID
    var zh: String
    var en: String
    var isMine: Bool

    init(id: UUID = UUID(), zh: String, en: String, isMine: Bool) {
        self.id = id
        self.zh = zh
        self.en = en
        self.isMine = isMine
    }
}

enum TranslateMode: String, CaseIterable, Identifiable {
    case live, offline, photo
    var id: String { rawValue }
    var title: String {
        switch self {
        case .live: return "实时对话"
        case .offline: return "应急语句"
        case .photo: return "拍照翻译"
        }
    }
}

enum PhotoSample: String, CaseIterable, Identifiable {
    case menu, sign

    var id: String { rawValue }
    var title: String {
        switch self {
        case .menu: return "菜单招牌"
        case .sign: return "路牌"
        }
    }

    var icon: String {
        switch self {
        case .menu: return "menucard"
        case .sign: return "signpost.right"
        }
    }
}

struct PhotoTranslation: Identifiable, Equatable {
    let id = UUID()
    var zh: String
    var en: String
}

// MARK: - Forum

enum ForumFilter: String, CaseIterable, Identifiable {
    case all, restaurant, spot, route, gift, event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部"
        case .restaurant: return "餐厅"
        case .spot: return "景点"
        case .route: return "路线"
        case .gift: return "伴手礼"
        case .event: return "活动"
        }
    }
}

struct ForumRoute: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var meta: String
    var tags: [String]
    var stops: Int
    var distance: String
    var likes: String
}

struct ForumPlace: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var price: String
    var tags: [String]
    var kind: ForumFilter
    var likes: String
    var symbol: String
    var tint: Int
    var heat: Int = 0
    var area: String = ""
    var note: String = ""
    var bestTime: String = ""
}

struct ForumEvent: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var date: String
    var place: String
    var attendees: Int
}

struct SimilarRoute: Identifiable {
    let id = UUID()
    var title: String
    var author: String
    var match: Int
    var stops: Int
    var distance: String
    var duration: String
    var tags: [String]
    var highlight: String
}

struct LocalEvent: Identifiable, Equatable {
    let id: UUID
    var title: String
    var subtitle: String
    var date: String
    var time: String
    var place: String
    var host: String
    var fee: String
    var attendees: Int
    var isMine: Bool
    var tint: Int

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        date: String,
        time: String,
        place: String,
        host: String,
        fee: String,
        attendees: Int,
        isMine: Bool = false,
        tint: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.time = time
        self.place = place
        self.host = host
        self.fee = fee
        self.attendees = attendees
        self.isMine = isMine
        self.tint = tint
    }
}

// MARK: - Chat

enum ChatRole {
    case assistant, user
}

enum AssistantCardKind {
    case ticket, hotels, checklist, route, translate
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    var role: ChatRole
    var text: String
    var card: AssistantCardKind?

    init(id: UUID = UUID(), role: ChatRole, text: String, card: AssistantCardKind? = nil) {
        self.id = id
        self.role = role
        self.text = text
        self.card = card
    }
}

// MARK: - Toast

struct Toast: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var icon: String
}
