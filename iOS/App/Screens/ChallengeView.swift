import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Opgavetrinnet — både valgspørgsmål og talkode.
///
/// ## Én skærm, to trintyper, nul opgavespecifik kode
///
/// Alt kommer fra kontrakten: spørgsmålet, afgrænsningen, svarmulighederne,
/// bevis­kortene og feltets etiketter. Det er dét, der gør Fjordenhus til en ren
/// indholdsleverance — hvis denne fil skal ændres for at tilføje en opgave, har
/// feature 001 fejlet (US2).
struct ChallengeView: View {
    let mission: Mission
    let step: Step

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router

    @State private var typedCode = ""
    @State private var selectedOptionId: String?
    @FocusState private var codeFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.loose) {
                switch step {
                case .singleChoice(let choice):
                    singleChoice(choice)
                case .numericCode(let code):
                    numericCode(code)
                case .narrative, .unknown:
                    EmptyView()
                }

                feedback
                hintButton
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(mission.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await engine.viewStep(step, in: mission)
        }
    }

    // MARK: - Valgspørgsmål

    @ViewBuilder
    private func singleChoice(_ choice: SingleChoiceStep) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            if let eyebrow = choice.eyebrow {
                Text(eyebrow)
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.accent)
                    .accessibilityLabel(eyebrow.lowercased())
            }
            Text(choice.title)
                .font(BHFont.title)
                .foregroundStyle(BHColor.ink)
            Text(choice.question)
                .font(BHFont.heading)
                .foregroundStyle(BHColor.ink)
                .fixedSize(horizontal: false, vertical: true)

            // Afgrænsningen: hvad skal ignoreres (FR-009).
            Text(choice.instruction)
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)

        VStack(spacing: BHSpacing.snug) {
            ForEach(choice.options) { option in
                Button {
                    selectedOptionId = option.id
                    Task { await answer(option.label) }
                } label: {
                    HStack {
                        Text(option.label)
                            .font(BHFont.heading)
                        Spacer()
                        if selectedOptionId == option.id {
                            Image(systemName: "checkmark.circle.fill")
                                .accessibilityHidden(true)
                        }
                    }
                    .foregroundStyle(BHColor.ink)
                    .padding(BHSpacing.regular)
                    .frame(maxWidth: .infinity, minHeight: BHMetrics.primaryButtonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                            .fill(BHColor.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                            .strokeBorder(
                                selectedOptionId == option.id ? BHColor.accent : BHColor.separator,
                                lineWidth: selectedOptionId == option.id ? 2 : 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.label)
                .accessibilityAddTraits(selectedOptionId == option.id ? [.isButton, .isSelected] : .isButton)
                .accessibilityIdentifier("option.\(option.label)")
            }
        }
    }

    // MARK: - Talkode

    @ViewBuilder
    private func numericCode(_ code: NumericCodeStep) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            if let eyebrow = code.eyebrow {
                Text(eyebrow)
                    .font(BHFont.eyebrow)
                    .foregroundStyle(BHColor.accent)
                    .accessibilityLabel(eyebrow.lowercased())
            }
            Text(code.title)
                .font(BHFont.title)
                .foregroundStyle(BHColor.ink)
            Text(code.instruction)
                .font(BHFont.body)
                .foregroundStyle(BHColor.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)

        // FR-010: deltallene vises igen, så ingen skal huske dem hjem fra
        // trin 2 — heller ikke den yngste i familien, der taster koden.
        VStack(spacing: BHSpacing.snug) {
            ForEach(code.evidenceCards) { card in
                evidenceCard(card)
            }
        }

        codeField(code)
    }

    private func evidenceCard(_ card: EvidenceCard) -> some View {
        BHCard {
            HStack(alignment: .top, spacing: BHSpacing.regular) {
                Text(card.displayValue)
                    .font(BHFont.code)
                    .foregroundStyle(BHColor.accent)
                    .frame(minWidth: BHMetrics.minimumTapTarget)

                VStack(alignment: .leading, spacing: BHSpacing.hairline) {
                    Text(card.label)
                        .font(BHFont.eyebrow)
                        .foregroundStyle(BHColor.inkMuted)
                    Text(card.title)
                        .font(BHFont.heading)
                        .foregroundStyle(BHColor.ink)
                    Text(card.description)
                        .font(BHFont.body)
                        .foregroundStyle(BHColor.inkMuted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(card.supportingText)
                        .font(BHFont.caption)
                        .foregroundStyle(BHColor.inkMuted)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.label): \(card.displayValue). \(card.title). \(card.description)")
    }

    /// Feltet navngives med fortællingens egne ord, så formularen underviser i
    /// reglen og ingen hjælpetekst er nødvendig (FR-011).
    private func codeField(_ code: NumericCodeStep) -> some View {
        let fieldNames = code.evidenceCards.map(\.label).joined(separator: " → ")

        return VStack(alignment: .leading, spacing: BHSpacing.snug) {
            Text(fieldNames)
                .font(BHFont.eyebrow)
                .foregroundStyle(BHColor.inkMuted)

            TextField("", text: $typedCode)
                .font(BHFont.code)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .focused($codeFieldFocused)
                .padding(BHSpacing.regular)
                .frame(minHeight: BHMetrics.primaryButtonHeight)
                .background(
                    RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                        .fill(BHColor.surface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                        .strokeBorder(BHColor.separator, lineWidth: 1)
                )
                .onChange(of: typedCode) { _, new in
                    // Feltet accepterer kun cifre og aldrig flere, end koden er lang.
                    let digits = new.filter(\.isNumber)
                    typedCode = String(digits.prefix(code.length))
                }
                // Container-label, så VoiceOver annoncerer feltets betydning og
                // ikke bare "tekstfelt" (FR-040).
                .accessibilityLabel("Koden. \(code.length) cifre, i rækkefølgen \(fieldNames)")
                .accessibilityValue(typedCode.isEmpty ? "Tomt" : typedCode.map(String.init).joined(separator: " "))
                .accessibilityIdentifier("code.field")

            Button("Åbn beskeden") {
                Task { await answer(typedCode) }
            }
            .buttonStyle(.bhPrimary)
            .disabled(typedCode.isEmpty)
            .accessibilityIdentifier("code.submit")

            // Et forkert tastet ciffer skal kunne fortrydes uden at slette
            // bagfra ét ad gangen — særligt med handsker på ved en havnekant.
            if !typedCode.isEmpty {
                Button("Ryd") {
                    typedCode = ""
                }
                .buttonStyle(.bhSecondary)
                .accessibilityIdentifier("code.clear")
                .accessibilityHint("Tømmer kodefeltet")
            }
        }
    }

    // MARK: - Feedback

    @ViewBuilder
    private var feedback: some View {
        if let outcome = engine.lastOutcome, let message = outcome.feedback {
            Label(message, systemImage: symbol(for: outcome))
                .font(BHFont.body)
                .foregroundStyle(colour(for: outcome))
                .labelStyle(.titleAndIcon)
                .padding(BHSpacing.regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: BHRadius.control, style: .continuous)
                        .fill(colour(for: outcome).opacity(0.12))
                )
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.updatesFrequently)
        }
    }

    /// Symbolet bærer betydningen sammen med teksten. Farven er kun en
    /// forstærkning (FR-039).
    private func symbol(for outcome: AnswerOutcome) -> String {
        switch outcome {
        case .correct: "checkmark.circle.fill"
        case .nearMiss: "arrow.triangle.turn.up.right.circle.fill"
        case .incorrect: "arrow.counterclockwise.circle.fill"
        case .malformed: "pencil.circle.fill"
        }
    }

    private func colour(for outcome: AnswerOutcome) -> Color {
        switch outcome {
        case .correct: BHColor.success
        case .nearMiss, .incorrect: BHColor.caution
        case .malformed: BHColor.inkMuted
        }
    }

    // MARK: - Hints

    @ViewBuilder
    private var hintButton: some View {
        if !engine.hints(for: step, in: mission).isEmpty {
            Button("Få et hint") {
                router.presentedSheet = .hints(missionId: mission.id, stepId: step.id)
            }
            .buttonStyle(.bhSecondary)
            .accessibilityIdentifier("hints.open")
        }
    }

    // MARK: - Bedømmelse

    private func answer(_ input: String) async {
        let outcome = await engine.submit(input, for: step, in: mission)
        guard outcome.isCorrect else { return }

        codeFieldFocused = false
        guard let next = engine.nextStep(after: step, in: mission) else {
            await engine.complete(mission)
            router.replaceTop(with: .reward(missionId: mission.id))
            return
        }
        router.replaceTop(with: .step(missionId: mission.id, stepId: next.id))
    }
}
