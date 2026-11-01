import Foundation
import CoreGraphics

// MARK: - Language

enum AppLanguage: String, CaseIterable, Identifiable {
    case en, zh

    var id: String { rawValue }

    var locale: Locale { Locale(identifier: self == .zh ? "zh-Hans" : "en") }
    var label: String { self == .en ? "EN" : "中文" }
    var other: AppLanguage { self == .en ? .zh : .en }
}

/// Manual lookup for strings built at runtime (toasts, data-driven labels).
enum L10n {
    private static let zhBundle: Bundle? = {
        guard let path = Bundle.main.path(forResource: "zh-Hans", ofType: "lproj") else { return nil }
        return Bundle(path: path)
    }()

    static func text(_ key: String, _ lang: AppLanguage) -> String {
        guard lang == .zh, let bundle = zhBundle else { return key }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}

// MARK: - Navigation

enum Tab: String, CaseIterable, Identifiable {
    case trip, plan, forum, translate, me

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trip: return "Trip"
        case .plan: return "Plan"
        case .forum: return "Community"
        case .translate: return "Translate"
        case .me: return "Me"
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
        case .trip: return "Trip · Forbidden City"
        case .plan: return "Plan · Central Axis"
        case .forum: return "Forum · Food & routes"
        case .translate: return "Translate · Emergency phrases"
        case .me: return "Me · Bookings & offline packs"
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
        case .docs: return "Documents"
        case .connectivity: return "Connectivity"
        case .tickets: return "Tickets"
        case .transit: return "Transit"
        }
    }

    var short: String {
        switch self {
        case .docs: return "Docs"
        case .connectivity: return "Data"
        case .tickets: return "Tickets"
        case .transit: return "Transit"
        }
    }
}

enum ChecklistPhase: String, CaseIterable, Identifiable {
    case before, arrival

    var id: String { rawValue }

    var title: String {
        switch self {
        case .before: return "Before you fly"
        case .arrival: return "Arrival day"
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
        case .mine: return "My route"
        case .community: return "Community 3"
        case .crowd: return "Crowds"
        }
    }
}

// MARK: - Trip plan (merged editor + live trip)

struct TripDay: Identifiable {
    let id: UUID
    var date: String
    var week: String
    var day: Int
    var title: String
    var meta: String
    var tag: String
    var tagStyle: TagStyle
    var stops: [RouteStop]
    var note: String

    init(
        id: UUID = UUID(),
        date: String,
        week: String,
        day: Int,
        title: String,
        meta: String,
        tag: String,
        tagStyle: TagStyle,
        stops: [RouteStop],
        note: String
    ) {
        self.id = id
        self.date = date
        self.week = week
        self.day = day
        self.title = title
        self.meta = meta
        self.tag = tag
        self.tagStyle = tagStyle
        self.stops = stops
        self.note = note
    }

    var shortTitle: String {
        title.components(separatedBy: "·").first?.trimmingCharacters(in: .whitespaces) ?? title
    }
}

struct TripSuggestion: Identifiable {
    let id = UUID()
    var name: String
    var meta: String
    var x: CGFloat
    var y: CGFloat
}

// MARK: - Translate

enum Scenario: String, CaseIterable, Identifiable {
    case route, dining, medical, taxi, shopping, emergency

    var id: String { rawValue }

    var title: String {
        switch self {
        case .route: return "Directions"
        case .dining: return "Dining"
        case .medical: return "Medical"
        case .taxi: return "Taxi"
        case .shopping: return "Shopping"
        case .emergency: return "Emergency"
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
        case .live: return "Live"
        case .offline: return "Offline"
        case .photo: return "Camera"
        }
    }
}

enum PhotoSample: String, CaseIterable, Identifiable {
    case menu, sign

    var id: String { rawValue }
    var title: String {
        switch self {
        case .menu: return "Menu"
        case .sign: return "Street sign"
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
        case .all: return "All"
        case .restaurant: return "Food"
        case .spot: return "Sights"
        case .route: return "Routes"
        case .gift: return "Gifts"
        case .event: return "Events"
        }
    }
}

enum ForumPostKind: String, CaseIterable, Identifiable {
    case all, restaurant, spot, route, gift, event

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .restaurant: return "Food"
        case .spot: return "Sights"
        case .route: return "Routes"
        case .gift: return "Gifts"
        case .event: return "Events"
        }
    }

    var label: String {
        switch self {
        case .all: return "ALL"
        case .restaurant: return "EAT"
        case .spot: return "SEE"
        case .route: return "WALK"
        case .gift: return "GIFT"
        case .event: return "EVENT"
        }
    }

    var forumFilter: ForumFilter {
        switch self {
        case .all: return .all
        case .restaurant: return .restaurant
        case .spot: return .spot
        case .route: return .route
        case .gift: return .gift
        case .event: return .event
        }
    }
}

struct ForumPost: Identifiable {
    let id: UUID
    var author: String
    var avatar: String
    var tint: Int
    var time: String
    var kind: ForumPostKind
    var title: String
    var body: String
    var tags: [String]
    var likes: String
    var saves: String
    var symbol: String
    var artTint: Int
    var height: CGFloat
    var photo: String?
    var credit: String?
    var placeTitle: String?
    var routeIndex: Int?
    var eventTitle: String?
    var comments: Int
    var comment: String
    var isMine: Bool

    init(
        id: UUID = UUID(),
        author: String,
        avatar: String,
        tint: Int,
        time: String,
        kind: ForumPostKind,
        title: String,
        body: String,
        tags: [String],
        likes: String,
        saves: String,
        symbol: String,
        artTint: Int,
        height: CGFloat,
        photo: String? = nil,
        credit: String? = nil,
        placeTitle: String? = nil,
        routeIndex: Int? = nil,
        eventTitle: String? = nil,
        comments: Int = 28,
        comment: String = "",
        isMine: Bool = false
    ) {
        self.id = id
        self.author = author
        self.avatar = avatar
        self.tint = tint
        self.time = time
        self.kind = kind
        self.title = title
        self.body = body
        self.tags = tags
        self.likes = likes
        self.saves = saves
        self.symbol = symbol
        self.artTint = artTint
        self.height = height
        self.photo = photo
        self.credit = credit
        self.placeTitle = placeTitle
        self.routeIndex = routeIndex
        self.eventTitle = eventTitle
        self.comments = comments
        self.comment = comment
        self.isMine = isMine
    }
}

// MARK: - Attractions

struct AttractionBooking: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: String
    var day: Int
    var time: String
    var price: String
    var symbol: String
    var tint: Int
    var booked: Bool
    var code: String?

    init(
        id: UUID = UUID(),
        title: String,
        date: String,
        day: Int = 1,
        time: String,
        price: String,
        symbol: String,
        tint: Int,
        booked: Bool = false,
        code: String? = nil
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.day = day
        self.time = time
        self.price = price
        self.symbol = symbol
        self.tint = tint
        self.booked = booked
        self.code = code
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
    case ticket, hotels, checklist, route, translate, plan
}

struct TravelPersona {
    let title: String
    let icon: String
    let meta: String
    let fit: String
    var note: String = ""
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
