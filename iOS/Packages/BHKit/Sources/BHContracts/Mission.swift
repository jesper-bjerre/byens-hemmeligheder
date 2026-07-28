import Foundation

/// Den fritstående opgave. Én mission hører til én lokation.
public struct Mission: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let slug: String
    public let locationId: String
    public let title: String
    public let shortTitle: String
    public let teaser: String
    public let status: Tolerant<MissionStatus>
    /// Mental udfordring. Aldrig fysisk risiko (forfatningens princip VII).
    public let difficulty: Int
    public let estimatedMinutes: Int
    public let basePoints: Int
    public let tags: [String]
    /// Vises på intro og i infovisning (FR-007).
    public let fictionLabel: String
    public let heroMediaId: String?
    /// Indtalt introduktion, afspillet når spilleren går i gang.
    ///
    /// Stemning og uddybning — aldrig indhold. Alt nødvendigt for at løse
    /// opgaven står som tekst på skærmen (ADR 0003).
    public let narrationMediaId: String?
    public let sourceIds: [String]
    public let steps: [Step]
    /// Præcis 3 (FR-017, V-09).
    public let hints: [Hint]
    public let completion: Completion

    // Reserveret. Ingen adfærd i fase 1 — ingen rute, ingen kapitelprogression.
    public let storyId: String?
    public let chapterId: String?
    public let nextChapterId: String?

    public init(
        id: String,
        slug: String,
        locationId: String,
        title: String,
        shortTitle: String,
        teaser: String,
        status: Tolerant<MissionStatus>,
        difficulty: Int,
        estimatedMinutes: Int,
        basePoints: Int,
        tags: [String],
        fictionLabel: String,
        heroMediaId: String?,
        sourceIds: [String],
        narrationMediaId: String? = nil,
        steps: [Step],
        hints: [Hint],
        completion: Completion,
        storyId: String? = nil,
        chapterId: String? = nil,
        nextChapterId: String? = nil
    ) {
        self.id = id
        self.slug = slug
        self.locationId = locationId
        self.title = title
        self.shortTitle = shortTitle
        self.teaser = teaser
        self.status = status
        self.difficulty = difficulty
        self.estimatedMinutes = estimatedMinutes
        self.basePoints = basePoints
        self.tags = tags
        self.fictionLabel = fictionLabel
        self.heroMediaId = heroMediaId
        self.narrationMediaId = narrationMediaId
        self.sourceIds = sourceIds
        self.steps = steps
        self.hints = hints
        self.completion = completion
        self.storyId = storyId
        self.chapterId = chapterId
        self.nextChapterId = nextChapterId
    }

    /// Trinnene i den rækkefølge, spilleren møder dem.
    public var orderedSteps: [Step] { steps.sorted { $0.order < $1.order } }

    /// Hints i den rækkefølge, de må åbnes.
    public var orderedHints: [Hint] { hints.sorted { $0.order < $1.order } }

    public func hint(id: String) -> Hint? { hints.first { $0.id == id } }
}

public enum MissionStatus: String, TolerantEnum {
    case draft
    case researchReady
    case fieldTestReady
    /// Kræver feltbesøg. V-10 blokerer den bevidst i feature 001.
    case publishReady
    case paused
}

// MARK: - Step

/// Ét skridt, diskrimineret på `kind`.
///
/// Ukendte værdier degraderer til ``unknown(_:)`` frem for at kaste (FR-003),
/// så en shippet app ikke mures af en nyere indholdspakke. UI'et springer
/// ukendte trin over.
public enum Step: Hashable, Sendable, Identifiable {
    case narrative(NarrativeStep)
    case singleChoice(SingleChoiceStep)
    case numericCode(NumericCodeStep)
    case freeText(FreeTextStep)
    case unknown(UnknownStep)

    public var id: String {
        switch self {
        case .narrative(let step): step.id
        case .singleChoice(let step): step.id
        case .numericCode(let step): step.id
        case .freeText(let step): step.id
        case .unknown(let step): step.id
        }
    }

    public var order: Int {
        switch self {
        case .narrative(let step): step.order
        case .singleChoice(let step): step.order
        case .numericCode(let step): step.order
        case .freeText(let step): step.order
        case .unknown(let step): step.order
        }
    }

    public var kind: String {
        switch self {
        case .narrative: NarrativeStep.kind
        case .singleChoice: SingleChoiceStep.kind
        case .numericCode: NumericCodeStep.kind
        case .freeText: FreeTextStep.kind
        case .unknown(let step): step.kind
        }
    }

    /// Svarreglen, hvis trinnet bedømmes. Narrative trin har ingen.
    public var answerRule: AnswerRule? {
        switch self {
        case .singleChoice(let step): step.answerRule
        case .numericCode(let step): step.answerRule
        case .freeText(let step): step.answerRule
        case .narrative, .unknown: nil
        }
    }

    /// Hvilke hints trinnet tilbyder.
    public var hintIds: [String] {
        switch self {
        case .singleChoice(let step): step.hintIds
        case .numericCode(let step): step.hintIds
        case .freeText(let step): step.hintIds
        case .narrative, .unknown: []
        }
    }
}

extension Step: Codable {
    private enum DiscriminatorKeys: String, CodingKey {
        case id, order, kind
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DiscriminatorKeys.self)
        let kind = try container.decode(String.self, forKey: .kind)

        switch kind {
        case NarrativeStep.kind:
            self = .narrative(try NarrativeStep(from: decoder))
        case SingleChoiceStep.kind:
            self = .singleChoice(try SingleChoiceStep(from: decoder))
        case NumericCodeStep.kind:
            self = .numericCode(try NumericCodeStep(from: decoder))
        case FreeTextStep.kind:
            self = .freeText(try FreeTextStep(from: decoder))
        default:
            self = .unknown(
                UnknownStep(
                    id: try container.decode(String.self, forKey: .id),
                    order: try container.decode(Int.self, forKey: .order),
                    kind: kind
                )
            )
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case .narrative(let step): try step.encode(to: encoder)
        case .singleChoice(let step): try step.encode(to: encoder)
        case .numericCode(let step): try step.encode(to: encoder)
        case .freeText(let step): try step.encode(to: encoder)
        case .unknown(let step): try step.encode(to: encoder)
        }
    }
}

public struct NarrativeStep: Codable, Hashable, Sendable, Identifiable {
    public static let kind = "narrative"

    public let id: String
    public let order: Int
    public let title: String
    public let body: String
    public let continueLabel: String

    public init(id: String, order: Int, title: String, body: String, continueLabel: String) {
        self.id = id
        self.order = order
        self.title = title
        self.body = body
        self.continueLabel = continueLabel
    }

    private enum CodingKeys: String, CodingKey {
        case id, order, kind, title, body, continueLabel
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        continueLabel = try container.decode(String.self, forKey: .continueLabel)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(Self.kind, forKey: .kind)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(continueLabel, forKey: .continueLabel)
    }
}

public struct SingleChoiceStep: Codable, Hashable, Sendable, Identifiable {
    public static let kind = "singleChoice"

    public let id: String
    public let order: Int
    /// Fx `"SPOR 1 AF 3"`.
    public let eyebrow: String?
    public let title: String
    public let question: String
    /// Afgrænsningen: hvad skal ignoreres (FR-009).
    public let instruction: String
    public let options: [ChoiceOption]
    public let answerRule: AnswerRule
    public let correctFeedback: String
    public let hintIds: [String]

    public init(
        id: String,
        order: Int,
        eyebrow: String?,
        title: String,
        question: String,
        instruction: String,
        options: [ChoiceOption],
        answerRule: AnswerRule,
        correctFeedback: String,
        hintIds: [String]
    ) {
        self.id = id
        self.order = order
        self.eyebrow = eyebrow
        self.title = title
        self.question = question
        self.instruction = instruction
        self.options = options
        self.answerRule = answerRule
        self.correctFeedback = correctFeedback
        self.hintIds = hintIds
    }

    private enum CodingKeys: String, CodingKey {
        case id, order, kind, eyebrow, title, question, instruction
        case options, answerRule, correctFeedback, hintIds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        eyebrow = try container.decodeIfPresent(String.self, forKey: .eyebrow)
        title = try container.decode(String.self, forKey: .title)
        question = try container.decode(String.self, forKey: .question)
        instruction = try container.decode(String.self, forKey: .instruction)
        options = try container.decode([ChoiceOption].self, forKey: .options)
        answerRule = try container.decode(AnswerRule.self, forKey: .answerRule)
        correctFeedback = try container.decode(String.self, forKey: .correctFeedback)
        hintIds = try container.decode([String].self, forKey: .hintIds)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(Self.kind, forKey: .kind)
        try container.encodeIfPresent(eyebrow, forKey: .eyebrow)
        try container.encode(title, forKey: .title)
        try container.encode(question, forKey: .question)
        try container.encode(instruction, forKey: .instruction)
        try container.encode(options, forKey: .options)
        try container.encode(answerRule, forKey: .answerRule)
        try container.encode(correctFeedback, forKey: .correctFeedback)
        try container.encode(hintIds, forKey: .hintIds)
    }
}

public struct ChoiceOption: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let label: String

    public init(id: String, label: String) {
        self.id = id
        self.label = label
    }
}

public struct NumericCodeStep: Codable, Hashable, Sendable, Identifiable {
    public static let kind = "numericCode"

    public let id: String
    public let order: Int
    public let eyebrow: String?
    public let title: String
    public let instruction: String
    public let length: Int
    /// Tidligere fundne deltal vises igen, så spilleren ikke skal huske dem (FR-010).
    public let evidenceCards: [EvidenceCard]
    public let answerRule: AnswerRule
    public let hintIds: [String]

    public init(
        id: String,
        order: Int,
        eyebrow: String?,
        title: String,
        instruction: String,
        length: Int,
        evidenceCards: [EvidenceCard],
        answerRule: AnswerRule,
        hintIds: [String]
    ) {
        self.id = id
        self.order = order
        self.eyebrow = eyebrow
        self.title = title
        self.instruction = instruction
        self.length = length
        self.evidenceCards = evidenceCards
        self.answerRule = answerRule
        self.hintIds = hintIds
    }

    private enum CodingKeys: String, CodingKey {
        case id, order, kind, eyebrow, title, instruction
        case length, evidenceCards, answerRule, hintIds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        eyebrow = try container.decodeIfPresent(String.self, forKey: .eyebrow)
        title = try container.decode(String.self, forKey: .title)
        instruction = try container.decode(String.self, forKey: .instruction)
        length = try container.decode(Int.self, forKey: .length)
        evidenceCards = try container.decode([EvidenceCard].self, forKey: .evidenceCards)
        answerRule = try container.decode(AnswerRule.self, forKey: .answerRule)
        hintIds = try container.decode([String].self, forKey: .hintIds)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(Self.kind, forKey: .kind)
        try container.encodeIfPresent(eyebrow, forKey: .eyebrow)
        try container.encode(title, forKey: .title)
        try container.encode(instruction, forKey: .instruction)
        try container.encode(length, forKey: .length)
        try container.encode(evidenceCards, forKey: .evidenceCards)
        try container.encode(answerRule, forKey: .answerRule)
        try container.encode(hintIds, forKey: .hintIds)
    }
}

/// Et fritekstsvar — ét ord eller en kort frase.
///
/// Tilføjet efter `numericCode` og er derfor en **additiv** kontraktændring:
/// en ældre app afkoder trinnet til ``Step/unknown(_:)`` og springer det over
/// frem for at mure hele indholdspakken (FR-003, research.md R-003).
///
/// Adskiller sig fra ``SingleChoiceStep`` ved ikke at have svarmuligheder.
/// Spilleren skriver selv, og ``AnswerRuleKind/exact`` afgør resten — hvilket
/// er dét, der gør `gulerod`, `Gulerod` og `en gulerod` til samme svar uden at
/// opgaven behøver kende de tre former hver for sig.
public struct FreeTextStep: Codable, Hashable, Sendable, Identifiable {
    public static let kind = "freeText"

    public let id: String
    public let order: Int
    public let eyebrow: String?
    public let title: String
    public let question: String?
    /// Afgrænsningen: hvad spilleren skal svare på (FR-009).
    public let instruction: String
    /// Vist i det tomme felt. Må aldrig røbe svaret.
    public let placeholder: String?
    public let answerRule: AnswerRule
    public let hintIds: [String]

    public init(
        id: String,
        order: Int,
        eyebrow: String? = nil,
        title: String,
        question: String? = nil,
        instruction: String,
        placeholder: String? = nil,
        answerRule: AnswerRule,
        hintIds: [String]
    ) {
        self.id = id
        self.order = order
        self.eyebrow = eyebrow
        self.title = title
        self.question = question
        self.instruction = instruction
        self.placeholder = placeholder
        self.answerRule = answerRule
        self.hintIds = hintIds
    }

    private enum CodingKeys: String, CodingKey {
        case id, order, kind, eyebrow, title, question, instruction
        case placeholder, answerRule, hintIds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self, forKey: .order)
        eyebrow = try container.decodeIfPresent(String.self, forKey: .eyebrow)
        title = try container.decode(String.self, forKey: .title)
        question = try container.decodeIfPresent(String.self, forKey: .question)
        instruction = try container.decode(String.self, forKey: .instruction)
        placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
        answerRule = try container.decode(AnswerRule.self, forKey: .answerRule)
        hintIds = try container.decode([String].self, forKey: .hintIds)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(Self.kind, forKey: .kind)
        try container.encodeIfPresent(eyebrow, forKey: .eyebrow)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(question, forKey: .question)
        try container.encode(instruction, forKey: .instruction)
        try container.encodeIfPresent(placeholder, forKey: .placeholder)
        try container.encode(answerRule, forKey: .answerRule)
        try container.encode(hintIds, forKey: .hintIds)
    }
}

/// Et trin, hvis `kind` er nyere end denne app. Bærer kun det fælles hoved.
public struct UnknownStep: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let order: Int
    public let kind: String

    public init(id: String, order: Int, kind: String) {
        self.id = id
        self.order = order
        self.kind = kind
    }
}

/// Kortet der gengiver et tidligere fundet deltal (FR-010).
public struct EvidenceCard: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let symbol: String?
    public let label: String
    public let title: String
    public let description: String
    public let supportingText: String
    public let displayValue: String

    public init(
        id: String,
        symbol: String?,
        label: String,
        title: String,
        description: String,
        supportingText: String,
        displayValue: String
    ) {
        self.id = id
        self.symbol = symbol
        self.label = label
        self.title = title
        self.description = description
        self.supportingText = supportingText
        self.displayValue = displayValue
    }
}

// MARK: - Svar, hints og afslutning

public struct AnswerRule: Codable, Hashable, Sendable {
    public let kind: Tolerant<AnswerRuleKind>
    /// Altid string. Foranstillede nuller er betydende og må ikke tabes til en
    /// talkonvertering (R-006).
    public let canonicalAnswer: String
    public let acceptedAnswers: [String]
    public let nearMissResponses: [NearMissResponse]
    /// Ikke-nedgørende (FR-015).
    public let genericIncorrectFeedback: String

    public init(
        kind: Tolerant<AnswerRuleKind>,
        canonicalAnswer: String,
        acceptedAnswers: [String],
        nearMissResponses: [NearMissResponse],
        genericIncorrectFeedback: String
    ) {
        self.kind = kind
        self.canonicalAnswer = canonicalAnswer
        self.acceptedAnswers = acceptedAnswers
        self.nearMissResponses = nearMissResponses
        self.genericIncorrectFeedback = genericIncorrectFeedback
    }
}

public enum AnswerRuleKind: String, TolerantEnum {
    /// Sammenlignes efter normalisering, men uden at fjerne ikke-cifre.
    case exact
    /// Alt andet end cifre kasseres før sammenligning.
    case digitsOnly
}

public struct NearMissResponse: Codable, Hashable, Sendable {
    public let answer: String
    public let feedback: String

    public init(answer: String, feedback: String) {
        self.answer = answer
        self.feedback = feedback
    }
}

/// Fradragene kommer fra indholdet, ikke fra koden (FR-021).
public struct Hint: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let order: Int
    public let penaltyPercent: Double
    public let title: String
    public let text: String

    public init(id: String, order: Int, penaltyPercent: Double, title: String, text: String) {
        self.id = id
        self.order = order
        self.penaltyPercent = penaltyPercent
        self.title = title
        self.text = text
    }
}

/// Belønningsskærmens indhold.
///
/// Bevidst uden `inventoryRewards`. Inventory er ude af fase 1 (FR-050,
/// data-model.md). Belønningen er beskeden, pointene og den historiske
/// forklaring.
public struct Completion: Codable, Hashable, Sendable {
    public let headline: String
    public let subheadline: String
    public let messageLabel: String
    public let message: String
    public let historyFact: String

    public init(
        headline: String,
        subheadline: String,
        messageLabel: String,
        message: String,
        historyFact: String
    ) {
        self.headline = headline
        self.subheadline = subheadline
        self.messageLabel = messageLabel
        self.message = message
        self.historyFact = historyFact
    }
}
