import BHContracts
import Foundation

/// De kanoniske eksemplarer, golden-filerne er bygget af.
///
/// Værdierne er faste og indeholder med vilje **ingen** `Date()`, `UUID()` eller
/// andet, der ændrer sig mellem to kørsler. En golden-fil, der ikke er
/// deterministisk, fejler tilfældigt og bliver slået fra inden for en uge.
///
/// Hvert felt er udfyldt med noget forskelligt fra nabofelterne. Var
/// `title` og `shortTitle` begge `"Titel"`, ville en ombytning af de to være
/// usynlig i diffen — og det er præcis den slags fejl, testen skal fange.
enum GoldenSamples {

    static let date = Date(timeIntervalSince1970: 1_800_000_000)
    static let uuid = UUID(uuidString: "0E7C0A2E-7C6E-4C9E-9E3F-1B2A3C4D5E6F")!

    // MARK: - Indholdsmodellen

    static let area = Area(
        id: "area.vejle-havn",
        name: "Vejle Havn",
        postalCode: "7100"
    )

    static let vantagePoint = VantagePoint(
        latitude: 55.7089,
        longitude: 9.5481,
        bearingDegrees: 118,
        instruction: "Stå på promenaden, så hele bygningen er synlig."
    )

    static let safety = Safety(
        flags: [.known(.water), .known(.cyclePath)],
        notes: "Åben vandkant og cyklister tæt på."
    )

    static let accessibility = Accessibility(
        surface: "Fast belægning",
        incline: "Fladt",
        steps: false,
        wheelchair: .known(.partial),
        stroller: .known(.yes),
        distanceFromAccessMetres: 35,
        notes: "Endnu ikke opmålt i felten."
    )

    static let location = Location(
        id: "loc.vejle-havn.boelgen",
        areaId: "area.vejle-havn",
        name: "Bølgen",
        address: "Havneøen, 7100 Vejle",
        latitude: 55.7083,
        longitude: 9.5497,
        activationRadiusMetres: 45,
        maxAcceptableAccuracyMetres: 40,
        dwellSeconds: 20,
        accuracyProfile: .known(.urbanCanyon),
        vantagePoint: vantagePoint,
        publicAccess: true,
        safety: safety,
        accessibility: accessibility,
        fieldVerified: false,
        lastPhysicallyVerified: nil
    )

    static let answerRule = AnswerRule(
        kind: .known(.digitsOnly),
        canonicalAnswer: "592",
        acceptedAnswers: ["592", "5 9 2", "5-9-2"],
        nearMissResponses: [
            NearMissResponse(answer: "529", feedback: "Rækkefølgen er forkert.")
        ],
        genericIncorrectFeedback: "Find de tre delresultater hver for sig."
    )

    static let hint = Hint(
        id: "hint.boelgen.1",
        order: 1,
        penaltyPercent: 3,
        title: "Hvor",
        text: "Tæl de store hvide toppe."
    )

    static let evidenceCard = EvidenceCard(
        id: "card.boelgen.oejet",
        symbol: "eye",
        label: "Øjet",
        title: "Bølgetoppene",
        description: "Fem hvide bølgeformede hoveddele.",
        supportingText: "Talt på stedet.",
        displayValue: "5"
    )

    static let narrativeStep = NarrativeStep(
        id: "step.boelgen.intro",
        order: 1,
        title: "Den femte besked",
        body: "En glemt besked ved fjorden.",
        continueLabel: "Jeg er klar"
    )

    static let singleChoiceStep = SingleChoiceStep(
        id: "step.boelgen.oejet",
        order: 2,
        eyebrow: "SPOR 1 AF 3",
        title: "Øjet",
        question: "Hvor mange bølgetoppe kan du se?",
        instruction: "Tæl kun de store hvide toppe.",
        options: [
            ChoiceOption(id: "opt.4", label: "4"),
            ChoiceOption(id: "opt.5", label: "5"),
        ],
        answerRule: AnswerRule(
            kind: .known(.exact),
            canonicalAnswer: "5",
            acceptedAnswers: ["5"],
            nearMissResponses: [],
            genericIncorrectFeedback: "Tæl toppene igen."
        ),
        correctFeedback: "Rigtigt.",
        hintIds: ["hint.boelgen.1"]
    )

    static let numericCodeStep = NumericCodeStep(
        id: "step.boelgen.koden",
        order: 5,
        eyebrow: "SAML KODEN",
        title: "Åbn beskeden",
        instruction: "Sæt tallene sammen.",
        length: 3,
        evidenceCards: [evidenceCard],
        answerRule: answerRule,
        hintIds: ["hint.boelgen.1"]
    )

    static let freeTextStep = FreeTextStep(
        id: "step.vera.gaaden",
        order: 2,
        eyebrow: "VERAS GÅDE",
        title: "Hvad er jeg?",
        question: "Jeg gemmer mig under jorden, men mit grønne hår kan ses.",
        instruction: "Skriv svaret som ét ord.",
        placeholder: "Skriv dit svar",
        answerRule: AnswerRule(
            kind: .known(.exact),
            canonicalAnswer: "gulerod",
            acceptedAnswers: ["gulerod", "en gulerod"],
            nearMissResponses: [
                NearMissResponse(answer: "kartoffel", feedback: "Den er ikke orange.")
            ],
            genericIncorrectFeedback: "Tænk på noget orange under jorden."
        ),
        hintIds: ["hint.vera.1"]
    )

    static let completion = Completion(
        headline: "Beskeden er åben",
        subheadline: "Du samlede den femte besked",
        messageLabel: "Den femte besked",
        message: "Nu står alle fem bølger ved fjorden.",
        historyFact: "De første to stod færdige i 2009."
    )

    static let mission = Mission(
        id: "mission.boelgen.den-femte-besked",
        slug: "boelgen-den-femte-besked",
        locationId: "loc.vejle-havn.boelgen",
        title: "Bølgen – Den femte besked",
        shortTitle: "Den femte besked",
        teaser: "En glemt besked ved fjorden.",
        status: .known(.fieldTestReady),
        difficulty: 3,
        estimatedMinutes: 10,
        basePoints: 100,
        tags: ["arkitektur", "observation"],
        fictionLabel: "Fiktiv mission baseret på Bølgens byggehistorie.",
        heroMediaId: nil,
        sourceIds: ["source.visitvejle.boelgen"],
        steps: [.narrative(narrativeStep), .singleChoice(singleChoiceStep), .numericCode(numericCodeStep)],
        hints: [
            hint,
            Hint(id: "hint.boelgen.2", order: 2, penaltyPercent: 4, title: "Hvordan", text: "Følg rækkefølgen."),
            Hint(id: "hint.boelgen.3", order: 3, penaltyPercent: 5, title: "Næsten", text: "Fem, ni og to."),
        ],
        completion: completion
    )

    static let mediaAsset = MediaAsset(
        id: "media.boelgen.hero",
        filename: "boelgen-hero.jpg",
        altText: "Fem hvide bølgeformede tage set fra promenaden.",
        owner: "Fotografens Navn",
        licence: "CC BY 4.0",
        credit: "Foto: Fotografens Navn",
        kind: .known(.contemporary),
        restrictions: "Må ikke beskæres.",
        expiresAt: nil
    )

    static let source = Source(
        id: "source.visitvejle.boelgen",
        title: "Bølgen",
        publisher: "VisitVejle",
        url: "https://www.visitvejle.dk/vejle/planlaeg-ferien/boelgen-gdk724987",
        kind: .known(.officialTourism)
    )

    static let contentPack = ContentPack(
        schemaVersion: "1.0",
        contentVersion: "2026-07-25.1",
        locale: "da-DK",
        areas: [area],
        locations: [location],
        missions: [mission],
        media: [mediaAsset],
        sources: [source]
    )

    // MARK: - Kørselsmodellen

    static let presenceEvidence = PresenceEvidence(
        method: .known(.gps),
        accuracyMetres: 12.5,
        dwellSeconds: 21,
        verifiedAt: date
    )

    static let gameEvent = GameEvent(
        id: uuid,
        sequence: 7,
        occurredAt: date,
        contentVersion: "2026-07-25.1",
        kind: .known(.answerSubmitted),
        payload: GameEventPayload(
            missionId: "mission.boelgen.den-femte-besked",
            stepId: "step.boelgen.koden",
            answer: "592",
            outcome: "correct"
        )
    )

    static let gameSession = GameSession(
        id: uuid,
        missionId: "mission.boelgen.den-femte-besked",
        contentVersion: "2026-07-25.1",
        startedAt: date,
        currentStepId: "step.boelgen.koden",
        presenceEvidence: presenceEvidence
    )

    /// En hændelse med en `kind`, denne app ikke kender.
    static let unknownKindEvent = GameEvent(
        id: uuid,
        sequence: 8,
        occurredAt: date,
        contentVersion: "2026-07-25.1",
        kind: .unknown("photoCaptured"),
        payload: GameEventPayload(missionId: "mission.boelgen.den-femte-besked")
    )
}
