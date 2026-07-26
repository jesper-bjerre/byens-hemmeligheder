import BHDesignSystem
import SwiftUI

/// Spillets egen forklaring, vist **umiddelbart før** OS-prompten (FR-030).
///
/// Aldrig ved opstart. En systemprompt, der dukker op, før spilleren ved hvorfor,
/// bliver afvist — og et afslag på position er meget sværere at få omgjort end
/// et velbegrundet ja. Derfor kommer denne skærm først, i spillets stemme, og
/// først når spilleren faktisk er på vej ud af døren.
struct PermissionPrimerView: View {
    @Environment(MissionEngine.self) private var engine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: BHSpacing.loose) {
            Image(systemName: "location.viewfinder")
                .font(.largeTitle)
                .imageScale(.large)
                .foregroundStyle(BHColor.accent)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                Text("Stedet er spillet")
                    .font(BHFont.title)
                    .foregroundStyle(BHColor.ink)

                Text("Opgaverne kan ikke løses hjemmefra. Appen bruger din position til at se, at du står det rigtige sted — og til intet andet.")
                    .font(BHFont.body)
                    .foregroundStyle(BHColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)

            VStack(alignment: .leading, spacing: BHSpacing.snug) {
                promise("Din position forlader aldrig telefonen.", "iphone.and.arrow.forward.outward")
                promise("Der gemmes ingen rute og ingen historik.", "map")
                promise("Appen bruger kun position, mens den er åben.", "app.badge")
                promise("Der er ingen konto og ingen tredjeparter.", "person.crop.circle.badge.xmark")
            }
            .accessibilityElement(children: .contain)

            Spacer(minLength: BHSpacing.regular)

            VStack(spacing: BHSpacing.snug) {
                Button("Ja, brug min position") {
                    engine.requestLocationAuthorization()
                    dismiss()
                }
                .buttonStyle(.bhPrimary)

                Button("Ikke nu") {
                    dismiss()
                }
                .buttonStyle(.bhSecondary)
            }
        }
        .padding(BHSpacing.loose)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BHColor.canvas)
        .presentationDetents([.large])
    }

    private func promise(_ text: String, _ symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(BHFont.body)
            .foregroundStyle(BHColor.ink)
            .labelStyle(.titleAndIcon)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
