import BHContracts
import BHDesignSystem
import BHGameCore
import SwiftUI

/// Opgaveskærmen. **Én** side for hele opgaven.
///
/// ## Kortene er siden
///
/// Formen er lånt fra escape room-brætspil: gåden ligger i en bunke kort, man
/// breder ud på bordet. Hvert kort er et billede med lidt tekst i bunden.
/// Billedet er det primære og får hele bredden.
///
/// Der var før to skærme — en fortællende intro med en "Jeg er klar"-knap og
/// derefter spørgsmålet. Knappen er væk, fordi der ikke længere er noget at gå
/// videre til: alt ligger på samme side, og fortællingen begynder med det
/// samme.
///
/// ## Hvad der bevidst **ikke** står her
///
/// - **Opgavens titel.** Den står i navigationslinjen. To gange er én for meget.
/// - **Fiktionsmærkatet.** Det hørte til den gamle introskærm, hvor teksten
///   kunne forveksles med et historisk dokument. Kortene er billeder med
///   billedtekst, og mærkatet stjal plads fra det, siden handler om.
///
/// ## Kun svarkontrollen afhænger af svartypen
///
/// Alt andet kommer fra kontrakten. Skal denne fil ændres for at tilføje en
/// opgave, er formen brudt — se ``MissionShape``.
struct ChallengeView: View {
    let mission: Mission
    let step: Step

    @Environment(MissionEngine.self) private var engine
    @Environment(Router.self) private var router
    @Environment(AmbiencePlayer.self) private var ambience
    @Environment(NarrationPlayer.self) private var narration

    /// Samme ord på svarknappen i alle trintyper.
    ///
    /// "Åbn beskeden" hørte til Bølgens fortælling og gav ingen mening i en
    /// billedopgave. Én tekst betyder ét mindre spørgsmål om, hvad man skal.
    ///
    /// "Svar" frem for "Gæt": opgavedokumenterne slår fast, at ingen gætteri er
    /// nødvendigt — facit kan bevises. En knap, der hedder "Gæt", ville modsige
    /// den præmis, opgaverne er bygget på.
    static let submitLabel = "Svar"

    /// Ét id på svarknappen, uanset svartype.
    ///
    /// Der stod før `code.submit` og `text.submit`. To navne på den samme
    /// handling betyder, at en test skal vide, hvilken slags opgave den kigger
    /// på — og så er testene lige så uens som skærmene var.
    static let submitIdentifier = "challenge.submit"

    @State private var typedCode = ""
    @State private var typedText = ""
    @State private var selectedOptionId: String?
    @State private var zoomedCard: MissionCard?
    @FocusState private var codeFieldFocused: Bool
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BHSpacing.regular) {
                ForEach(mission.orderedCards) { card in
                    MissionCardView(card: card) { zoomedCard = card }
                }

                // Svar og hint i bunden — efter kortene, som i spillet.
                VStack(alignment: .leading, spacing: BHSpacing.snug) {
                    answerControl
                    feedback
                    hintButton
                }
                .padding(.top, BHSpacing.snug)
            }
            .padding(BHSpacing.regular)
        }
        .background(BHColor.canvas)
        .navigationTitle(mission.shortTitle)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $zoomedCard) { card in
            MissionCardZoomView(card: card) { zoomedCard = nil }
        }
        .task {
            await engine.viewStep(step, in: mission)
        }
        // Fortællingen begynder med det samme. Den er en del af oplevelsen,
        // ikke en valgmulighed — men den følger højttalerknappen i headeren,
        // så spilleren har ét sted at slå al lyd fra.
        .task(id: mission.id) {
            await narration.speak(
                engine.pack?.media(id: mission.narrationMediaId ?? ""),
                forMission: mission.id,
                isEnabled: ambience.isEnabled
            )
        }
        .onDisappear { narration.stop() }
        .onChange(of: narration.isSpeaking) { _, speaking in
            ambience.duck(speaking)
        }
    }

    // MARK: - Svaret

    /// Det eneste, der afhænger af svartypen.
    @ViewBuilder
    private var answerControl: some View {
        switch step {
        case .singleChoice(let choice):
            choices(choice)
        case .numericCode(let code):
            codeField(code)
        case .freeText(let text):
            textField(text)
        case .narrative, .unknown:
            EmptyView()
        }
    }

    /// Fire knapper. Antallet er fast — se ``MissionShape/choiceCount``.
    private func choices(_ choice: SingleChoiceStep) -> some View {
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

    /// Feltet navngives med fortællingens egne ord, så formularen underviser i
    /// reglen og ingen hjælpetekst er nødvendig (FR-011).
    private func codeField(_ code: NumericCodeStep) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            Text("Indtast koden")
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
                .accessibilityLabel("Indtast koden. \(code.length) cifre.")
                .accessibilityValue(typedCode.isEmpty ? "Tomt" : typedCode.map(String.init).joined(separator: " "))
                .accessibilityIdentifier("code.field")

            submitButton(isEnabled: !typedCode.isEmpty) { await answer(typedCode) }
        }
    }

    private func textField(_ step: FreeTextStep) -> some View {
        VStack(alignment: .leading, spacing: BHSpacing.snug) {
            TextField(step.placeholder ?? "", text: $typedText)
                .font(BHFont.heading)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($textFieldFocused)
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
                // Autokorrektur er slået fra med vilje. Den ville rette
                // spillerens gæt til noget andet, før svaret blev bedømt — og
                // `DanishTextNormalizer` klarer i forvejen store bogstaver,
                // mellemrum og danske tegn.
                .accessibilityLabel(step.question ?? step.title)
                .accessibilityIdentifier("text.field")

            submitButton(
                isEnabled: !typedText.trimmingCharacters(in: .whitespaces).isEmpty
            ) { await answer(typedText) }
        }
    }

    /// Én svarknap, ét id, én tekst — uanset hvad man har svaret i.
    private func submitButton(
        isEnabled: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        Button(Self.submitLabel) { Task { await action() } }
            .buttonStyle(.bhPrimary)
            .disabled(!isEnabled)
            .accessibilityIdentifier(Self.submitIdentifier)
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

        guard outcome.isCorrect else {
            // Kodefeltet tømmes efter et svar, der ikke var rigtigt.
            //
            // Uden dette er spilleren kørt fast: feltet holder præcis så mange
            // cifre, som koden er lang, så når der står tre, bliver alt nyt
            // tastetryk kasseret af længdegrænsen. Der skete ingenting, og den
            // eneste vej videre var at slette baglæns — hvilket intet på
            // skærmen fortalte. Det var netop dét, en test faldt over.
            //
            // Kun koden ryddes. Et fritekstsvar er spillerens egne ord, og de
            // skal kunne rettes til frem for at forsvinde.
            if case .numericCode = step { typedCode = "" }
            return
        }

        codeFieldFocused = false
        textFieldFocused = false
        guard let next = engine.nextStep(after: step, in: mission) else {
            await engine.complete(mission)
            router.replaceTop(with: .reward(missionId: mission.id))
            return
        }
        router.replaceTop(with: .step(missionId: mission.id, stepId: next.id))
    }
}
