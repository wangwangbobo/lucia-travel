import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Palette.bg.ignoresSafeArea()

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomControls

            if let toast = model.toast {
                ToastBanner(toast: toast)
                    .padding(.leading, 20)
                    .padding(.bottom, 104)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsHitTesting(false)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(6)
            }
        }
        .fullScreenCover(isPresented: $model.checklistOpen) {
            ChecklistView()
                .environmentObject(model)
                .preferredColorScheme(.light)
        }
        .sheet(isPresented: $model.assistantOpen) {
            AssistantView()
                .environmentObject(model)
                .preferredColorScheme(.light)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
        .sheet(isPresented: $model.notesOpen) {
            NotesPoster()
                .environmentObject(model)
                .preferredColorScheme(.light)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(30)
                .presentationBackground(Palette.bg)
        }
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
            if model.tab != .plan {
                AssistantOrb()
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 2)
        .zIndex(5)
    }
}
