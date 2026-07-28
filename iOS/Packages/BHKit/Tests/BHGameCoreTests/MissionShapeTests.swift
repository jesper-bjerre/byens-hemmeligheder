import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

/// Alle opgaver har samme form. Det er data, der skiller dem — aldrig koden.
@Suite("Opgaveform")
struct MissionShapeTests {

    // MARK: - Mod pakken, der faktisk shipper

    /// Den vigtigste test i suiten.
    ///
    /// Opgaverne divergerede uden at nogen besluttede det: fem trin i to
    /// opgaver, to i de andre, og tre forskellige skærmlayouts. Denne test er
    /// det, der gør, at det ikke sker igen — en ny opgave i den forkerte form
    /// fejler her og ikke først, når en quizmaster står ude i felten.
    @Test("Hver opgave i pakken har den ene form")
    func everyMissionInThePackHasTheOneShape() throws {
        let pack = try ContractFixtures.contentPack()
        let media = Dictionary(uniqueKeysWithValues: pack.media.map { ($0.id, $0) })

        for mission in pack.missions {
            let violations = MissionShape.violations(of: mission, media: media)
            #expect(
                violations.isEmpty,
                "\(mission.id): \(violations.map(\.description).joined(separator: "; "))"
            )
        }
    }

    @Test("Hver opgave har præcis ét fortællende trin og ét spørgsmål")
    func everyMissionHasOneNarrativeAndOneChallenge() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let steps = mission.orderedSteps
            #expect(steps.count == 2, "\(mission.id) har \(steps.count) trin")
            #expect(steps.first?.kind == NarrativeStep.kind, "\(mission.id) begynder ikke med fortællingen")
            #expect(mission.challengeStep != nil, "\(mission.id) har intet spørgsmål")
        }
    }

    /// Svaret må være kode, fritekst eller fire valgmuligheder — intet andet.
    @Test("Svartypen er en af de tre, appen kan tegne ens")
    func theAnswerKindIsOneOfThree() throws {
        let pack = try ContractFixtures.contentPack()
        let allowed = [SingleChoiceStep.kind, NumericCodeStep.kind, FreeTextStep.kind]

        for mission in pack.missions {
            let challenge = try #require(mission.challengeStep)
            #expect(allowed.contains(challenge.kind), "\(mission.id) svarer med '\(challenge.kind)'")
        }
    }

    /// Hovedet skal kunne tegnes uden at kende svartypen.
    @Test("Hvert spørgsmål har et hoved med titel og afgrænsning")
    func everyChallengeHasAPrompt() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let challenge = try #require(mission.challengeStep)
            let prompt = try #require(challenge.prompt, "\(mission.id) har intet spørgsmålshoved")
            #expect(!prompt.title.isEmpty, "\(mission.id) mangler titel")
            #expect(!prompt.instruction.isEmpty, "\(mission.id) mangler afgrænsning")
        }
    }

    // MARK: - Positive kontroller

    /// Uden disse ville alt ovenfor også bestå, hvis validatoren returnerede
    /// en tom liste uanset hvad.
    @Test("En opgave med for mange trin afvises")
    func tooManyStepsIsRejected() throws {
        let pack = try ContractFixtures.contentPack()
        let good = try #require(pack.missions.first)
        let extra = good.orderedSteps + [
            .narrative(
                NarrativeStep(id: "step.ekstra", order: 3, title: "Ekstra", body: "…", continueLabel: "Videre")
            )
        ]

        let violations = MissionShape.violations(of: good.copy(steps: extra))
        #expect(violations.contains(.wrongStepCount(3)))
    }

    @Test("Et valgspørgsmål med tre muligheder afvises")
    func threeChoicesIsRejected() throws {
        let step = SingleChoiceStep(
            id: "step.tre",
            order: 2,
            eyebrow: nil,
            title: "Tre",
            question: "Hvor mange?",
            instruction: "Tæl.",
            options: (1...3).map { ChoiceOption(id: "o\($0)", label: "\($0)") },
            answerRule: AnswerRule(
                kind: .known(.exact),
                canonicalAnswer: "1",
                acceptedAnswers: ["1"],
                nearMissResponses: [],
                genericIncorrectFeedback: "Prøv igen."
            ),
            correctFeedback: "Rigtigt.",
            hintIds: []
        )

        let pack = try ContractFixtures.contentPack()
        let good = try #require(pack.missions.first)
        let narrative = try #require(good.orderedSteps.first)

        let violations = MissionShape.violations(of: good.copy(steps: [narrative, .singleChoice(step)]))
        #expect(violations.contains(MissionShape.Violation.wrongChoiceCount(stepId: "step.tre", count: 3)))
    }

    @Test("Et AI-billede som stedbillede afvises")
    func anAIImageAsPlaceMediaIsRejected() throws {
        let pack = try ContractFixtures.contentPack()
        let asset = try #require(pack.media.first { $0.kind == .known(.aiGenerated) })
        let mission = try #require(pack.missions.first).copy(placeMediaId: asset.id)

        let violations = MissionShape.violations(
            of: mission,
            media: [asset.id: asset]
        )
        #expect(
            violations.contains { if case .misclassifiedMedia = $0 { true } else { false } },
            "Et AI-genereret billede blev accepteret som orienteringsfoto"
        )
    }
}

// MARK: - Hjælper

private extension Mission {
    /// Kopi med enkelte felter ændret. `Mission` har mange felter, og testene
    /// skal kun variere ét ad gangen.
    func copy(steps: [Step]? = nil, placeMediaId: String? = nil) -> Mission {
        Mission(
            id: id,
            slug: slug,
            locationId: locationId,
            title: title,
            shortTitle: shortTitle,
            teaser: teaser,
            status: status,
            difficulty: difficulty,
            estimatedMinutes: estimatedMinutes,
            basePoints: basePoints,
            tags: tags,
            fictionLabel: fictionLabel,
            heroMediaId: heroMediaId,
            sourceIds: sourceIds,
            placeMediaId: placeMediaId ?? self.placeMediaId,
            moodMediaId: moodMediaId,
            narrationMediaId: narrationMediaId,
            steps: steps ?? self.steps,
            hints: hints,
            completion: completion
        )
    }
}
