import BHDesignSystem
import BHGameCore
import SwiftUI

/// Arket, der forklarer en positionstilstand og altid tilbyder en handling.
struct PresenceProblemSheet: View {
    let content: PresenceProblemContent

    @Environment(MissionEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.loose) {
            Image(systemName: content.symbol)
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(BHColor.accent)
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                Text(content.title)
                    .font(BHFont.title)
                    .foregroundStyle(BHColor.ink)
                Text(content.message)
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: BHSpacing.regular)

            VStack(spacing: BHSpacing.snug) {
                Button(content.primaryAction.label) {
                    perform(content.primaryAction)
                }
                .buttonStyle(.bhPrimary)

                if let secondary = content.secondaryAction {
                    Button(secondary.label) {
                        perform(secondary)
                    }
                    .buttonStyle(.bhSecondary)
                }
            }
        }
        .padding(BHSpacing.loose)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BHColor.canvas)
        .presentationDetents([.medium, .large])
    }

    private func perform(_ action: PresenceProblemContent.Action) {
        switch action {
        case .requestAuthorization:
            engine.requestLocationAuthorization()
        case .requestFullAccuracy:
            engine.requestFullAccuracy()
        case .openSettings:
            #if os(iOS)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                openURL(url)
            }
            #endif
        case .confirmManually:
            Task {
                await engine.acceptSoftOverride()
                dismiss()
            }
        case .dismiss:
            dismiss()
        }
    }
}
