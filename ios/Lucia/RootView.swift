import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Palette.bg.ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .top, spacing: 0) {
                    HStack {
                        Spacer()
                        LanguagePill()
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 2)
                    .padding(.bottom, 2)
                }

            bottomControls

            if let toast = model.toast {
                ToastBanner(toast: toast)
                    .padding(.leading, 20)
                    .padding(.bottom, model.tab == .trip && model.planBuilt ? 158 : 104)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsHitTesting(false)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(6)
            }
        }
        .environment(\.locale, model.lang.locale)
        .fullScreenCover(isPresented: firstRunOpen) {
            AssistantView()
                .environmentObject(model)
                .environment(\.locale, model.lang.locale)
                .preferredColorScheme(.light)
        }
        .sheet(isPresented: assistantSheetOpen) {
            AssistantView()
                .environmentObject(model)
                .environment(\.locale, model.lang.locale)
                .preferredColorScheme(.light)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .fullScreenCover(isPresented: $model.checklistOpen) {
            ChecklistView()
                .environmentObject(model)
                .environment(\.locale, model.lang.locale)
                .preferredColorScheme(.light)
        }
        .sheet(isPresented: $model.notesOpen) {
            NotesPoster()
                .environmentObject(model)
                .environment(\.locale, model.lang.locale)
                .preferredColorScheme(.light)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .fullScreenCover(isPresented: $model.recapOpen) {
            TripRecapView()
                .environmentObject(model)
                .environment(\.locale, model.lang.locale)
                .preferredColorScheme(.dark)
        }
        .task {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-noassistant") { return }
            #endif
            guard model.onboarding, !model.assistantOpen, !model.recapOpen else { return }
            try? await Task.sleep(for: .milliseconds(450))
            guard !model.assistantOpen, !model.notesOpen, !model.checklistOpen, !model.recapOpen else { return }
            if model.chatMessages.isEmpty {
                model.seedAssistant()
            }
            model.assistantOpen = true
        }
    }

    /// First-run planning is a full-screen, non-dismissible flow: the user has to
    /// answer the three questions and tap Generate plan.
    private var firstRunOpen: Binding<Bool> {
        Binding(
            get: { model.assistantOpen && (model.showPlanBuilder || model.firstRunFlow) },
            set: { newValue in
                guard !newValue else { return }
                model.assistantOpen = false
            }
        )
    }

    private var assistantSheetOpen: Binding<Bool> {
        Binding(
            get: { model.assistantOpen && !model.showPlanBuilder && !model.firstRunFlow },
            set: { newValue in
                guard !newValue else { return }
                model.assistantOpen = false
            }
        )
    }

    @ViewBuilder
    private var content: some View {
        switch model.tab {
        case .trip:
            TripView()
        case .plan:
            PlanView()
        case .forum:
            ForumView()
        case .translate:
            TranslateView()
        case .me:
            MeView()
        }
    }

    private var bottomControls: some View {
        HStack(alignment: .center, spacing: 8) {
            FloatingTabBar()
            AssistantOrb()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 2)
        .zIndex(5)
    }
}
