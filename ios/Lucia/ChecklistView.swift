import SwiftUI

struct ChecklistView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var category: ChecklistCategory? = nil

    var body: some View {
        ZStack {
            Palette.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    topBar
                    titleBlock
                    summaryCard
                    categoryRow
                    groups
                    aiCard
                    shareRow
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 44)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = model.toast {
                ToastBanner(toast: toast)
                    .padding(.bottom, 108)
                    .allowsHitTesting(false)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var topBar: some View {
        HStack {
            IconCircleButton(icon: "chevron.left", size: 37) {
                dismiss()
            }
            Spacer()
            Eyebrow(text: "行前清单 / PREP")
            Spacer()
            Button {
                model.openAssistant("清单 · 行前准备")
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 37, height: 37)
                    .background(Circle().fill(Palette.lime))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
            .buttonStyle(PressableButtonStyle())
            .accessibilityLabel("问问 Lucia")
            ShareLink(item: model.checklistSummary) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 37, height: 37)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.2))
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Eyebrow(text: "MAKE IT EASY")
                StickerLabel(text: "3 DAYS TO GO", fill: Palette.mustard, rotation: 3)
            }
            Group {
                if model.remaining == 0 {
                    Text("都准备好了")
                } else {
                    Text("还有 ") + Text("\(model.remaining) 件小事").foregroundColor(Palette.accent)
                }
            }
            .font(.system(size: 34, weight: .black))
            .tracking(-0.7)
            .foregroundStyle(Palette.ink)
            Text("按出发前和落地当天排好，做完打勾就行。")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Palette.ink2)
        }
        .padding(.top, 2)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("出发进度")
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundStyle(Palette.ink2)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(model.doneCount)")
                            .font(.system(size: 38, weight: .black).width(.condensed))
                            .foregroundStyle(Palette.ink)
                        Text("/ \(model.totalCount) 项")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Palette.ink2)
                    }
                }
                Spacer()
                ProgressRingView(
                    progress: model.progress,
                    label: "\(Int(model.progress * 100))%",
                    size: 58,
                    lineWidth: 4.5,
                    track: Palette.paper.opacity(0.65),
                    tint: Palette.ink,
                    labelColor: Palette.ink
                )
            }

            LinearProgressBar(progress: model.progress, tint: Palette.ink, track: Palette.paper.opacity(0.65))

            HStack(spacing: 8) {
                Text("距出发 3 天 · 已按优先级排好")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink2)
                Spacer()
                Button {
                    model.aiRecheck()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9, weight: .bold))
                        Text("AI 复查")
                            .font(.system(size: 10.5, weight: .bold))
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 11)
                    .frame(height: 29)
                    .background(Capsule().fill(Palette.paper))
                    .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Palette.lime)
                .shadow(color: Palette.ink.opacity(0.16), radius: 0, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Palette.ink, lineWidth: 1.4)
        )
    }

    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                Chip(title: "全部", selected: category == nil, count: "\(model.totalCount)") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        category = nil
                    }
                }
                ForEach(ChecklistCategory.allCases) { item in
                    let stats = model.categoryStats(item)
                    Chip(title: item.title, selected: category == item, count: "\(stats.done)/\(stats.total)") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            category = (category == item) ? nil : item
                        }
                    }
                }
            }
            .padding(.vertical, 1)
        }
    }

    private var groups: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(ChecklistPhase.allCases) { phase in
                let entries = filtered(phase)
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(phase.title)
                                .font(.system(size: 15, weight: .heavy))
                                .foregroundStyle(Palette.ink)
                            Text("\(model.phaseDone(phase)) / \(model.items(in: phase).count)")
                                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Palette.ink3)
                            Spacer()
                            if phase == .before {
                                Text("出发前 3 天")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(Palette.accent)
                            }
                        }
                        .padding(.horizontal, 2)

                        VStack(spacing: 0) {
                            ForEach(entries) { item in
                                itemRow(item)
                                if item.id != entries.last?.id {
                                    SoftDivider().padding(.leading, 34)
                                }
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
            }
        }
    }

    private func itemRow(_ item: ChecklistItem) -> some View {
        let done = item.status == .done
        return HStack(alignment: .top, spacing: 10) {
            Button {
                model.toggle(item)
            } label: {
                ZStack {
                    Circle()
                        .strokeBorder(done ? Palette.ink : Palette.ink.opacity(0.55), lineWidth: 1.3)
                        .frame(width: 22, height: 22)
                    if done {
                        Circle()
                            .fill(Palette.lime)
                            .frame(width: 22, height: 22)
                        Circle()
                            .strokeBorder(Palette.ink, lineWidth: 1.2)
                            .frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(Palette.ink)
                    } else if item.status == .action {
                        Circle()
                            .fill(Palette.accent)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(done ? Palette.ink3 : Palette.ink)
                    .strikethrough(done, color: Palette.ink3)
                    .multilineTextAlignment(.leading)
                Text(item.meta)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.ink3)
                if let tag = item.tag {
                    TagView(text: tag, style: item.tagStyle)
                        .padding(.top, 1)
                }
            }

            Spacer(minLength: 4)

            if done, let trailing = item.trailing {
                Text(trailing)
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundStyle(Palette.ink3)
                    .padding(.top, 3)
            } else if let action = item.actionLabel {
                Button {
                    Haptics.tap()
                    handleAction(item)
                } label: {
                    Text(action)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 10)
                        .frame(height: 27)
                        .background(Capsule().fill(Palette.accentSoft))
                        .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1))
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.vertical, 9)
    }

    private var aiCard: some View {
        HStack(spacing: 11) {
            ZStack {
                Circle().fill(Palette.lime)
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Palette.ink)
            }
            .frame(width: 37, height: 37)
            .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))

            VStack(alignment: .leading, spacing: 3) {
                Text("让 Lucia 再检查一遍")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundStyle(Palette.ink)
                Text("对照天气、闭馆日和余票，重排待办顺序。")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.ink2)
            }
            Spacer(minLength: 0)

            Button {
                model.openAssistant("清单 · 帮我复查")
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(Palette.ink)
                    .frame(width: 31, height: 31)
                    .background(Circle().fill(Palette.paper))
                    .overlay(Circle().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle())
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 19, style: .continuous).fill(Palette.limeSoft))
        .dashedBorder(color: Palette.ink.opacity(0.5), radius: 19)
    }

    private var shareRow: some View {
        HStack(spacing: 8) {
            ShareLink(item: model.checklistSummary) {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 10, weight: .bold))
                    Text("分享清单")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 41)
                .background(Capsule().fill(Palette.paper))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }

            Button {
                model.toast("已生成新的行前清单", icon: "doc.badge.plus")
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10, weight: .bold))
                    Text("重新生成")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Palette.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 41)
                .background(Capsule().fill(Palette.mustardSoft))
                .overlay(Capsule().strokeBorder(Palette.ink, lineWidth: 1.1))
            }
            .buttonStyle(PressableButtonStyle())
        }
    }

    private func filtered(_ phase: ChecklistPhase) -> [ChecklistItem] {
        let items = model.items(in: phase)
        guard let category else { return items }
        return items.filter { $0.category == category }
    }

    private func handleAction(_ item: ChecklistItem) {
        if item.title.hasPrefix("故宫门票") {
            model.bookForbiddenCity()
        } else {
            model.openAssistant("清单 · \(item.title)")
        }
    }
}
