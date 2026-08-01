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

        for mission in pack.missions where mission.isPlayable {
            let violations = MissionShape.violations(of: mission, media: media)
            #expect(
                violations.isEmpty,
                "\(mission.id): \(violations.map(\.description).joined(separator: "; "))"
            )
        }
    }

    @Test("Hver opgave har kort og præcis ét spørgsmål")
    func everyMissionHasCardsAndOneChallenge() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions where mission.isPlayable {
            #expect(mission.orderedSteps.count == 1, "\(mission.id) har \(mission.orderedSteps.count) trin")
            #expect(mission.challengeStep != nil, "\(mission.id) har intet spørgsmål")
            #expect(!mission.orderedCards.isEmpty, "\(mission.id) har ingen kort")
        }
    }

    /// Kort 1 bærer introduktionen og er derfor den længste tekst.
    @Test("Første kort har introduktionen")
    func theFirstCardCarriesTheIntroduction() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions where mission.isPlayable {
            let first = try #require(mission.orderedCards.first)
            #expect(!first.text.isEmpty, "\(mission.id): første kort har ingen tekst")
            #expect(first.order == 1, "\(mission.id): kortene begynder ikke ved 1")
        }
    }

    /// Miniaturen må aldrig mangle — så ville opgavekortet på kortet stå tomt.
    @Test("Hver opgave har en miniature at vise på kortet")
    func everyMissionResolvesAThumbnail() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions where mission.isPlayable {
            #expect(
                mission.resolvedThumbnailMediaId != nil,
                "\(mission.id) har intet billede at vise på kortet"
            )
        }
    }

    /// Svaret må være kode, fritekst eller fire valgmuligheder — intet andet.
    @Test("Svartypen er en af de tre, appen kan tegne ens")
    func theAnswerKindIsOneOfThree() throws {
        let pack = try ContractFixtures.contentPack()
        let allowed = [SingleChoiceStep.kind, NumericCodeStep.kind, FreeTextStep.kind]

        for mission in pack.missions where mission.isPlayable {
            let challenge = try #require(mission.challengeStep)
            #expect(allowed.contains(challenge.kind), "\(mission.id) svarer med '\(challenge.kind)'")
        }
    }

    /// Hovedet skal kunne tegnes uden at kende svartypen.
    @Test("Hvert spørgsmål har et hoved med titel og afgrænsning")
    func everyChallengeHasAPrompt() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions where mission.isPlayable {
            let challenge = try #require(mission.challengeStep)
            let prompt = try #require(challenge.prompt, "\(mission.id) har intet spørgsmålshoved")
            #expect(!prompt.title.isEmpty, "\(mission.id) mangler titel")
        }
    }

    // MARK: - Ufærdige opgaver må ikke nå spilleren

    /// "Den forsvundne landevej" ligger i pakken uden facit. Det er tilladt —
    /// men kun så længe den ikke kan spilles.
    @Test("En opgave uden fastlagt facit er ikke spilbar")
    func aMissionWithoutAFacitIsNotPlayable() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions where mission.isPlayable {
            let accepted = mission.challengeStep?.answerRule?.acceptedAnswers ?? []
            guard accepted.contains(MissionShape.unsetFacit) else { continue }

            #expect(
                mission.status != .known(.fieldTestReady) && mission.status != .known(.publishReady),
                "\(mission.id) kan spilles, men har intet facit"
            )
        }
    }

    /// Positiv kontrol: reglen skal faktisk fyre.
    ///
    /// Opgaven bygges her frem for at findes i pakken. Testen hentede før en
    /// opgave med `unsetFacit` fra indholdet — og gik i stå den dag, "Den
    /// forsvundne landevej" fik sit facit. En regel skal kunne efterprøves,
    /// også når intet indhold tilfældigvis overtræder den.
    @Test("En spilbar opgave uden facit fanges")
    func promotingAMissionWithoutAFacitIsCaught() throws {
        let pack = try ContractFixtures.contentPack()
        let good = try #require(pack.missions.first)

        let unfinished = SingleChoiceStep(
            id: "step.ufaerdig",
            order: 1,
            eyebrow: nil,
            title: "Uden facit",
            question: "Hvilken vej?",
            options: ["Nord", "Syd", "Øst", "Vest"].map { ChoiceOption(id: "opt.\($0)", label: $0) },
            answerRule: AnswerRule(
                kind: .known(.exact),
                canonicalAnswer: MissionShape.unsetFacit,
                acceptedAnswers: [MissionShape.unsetFacit],
                nearMissResponses: []
            ),
            hintIds: []
        )

        let promoted = good.copy(
            steps: [.singleChoice(unfinished)],
            status: .known(.fieldTestReady)
        )
        #expect(MissionShape.violations(of: promoted).contains(.playableWithoutAnswer))
    }

    /// Modstykket: den samme opgave er i orden, så længe den ikke kan spilles.
    @Test("Den samme opgave er i orden som researchklar")
    func theSameMissionIsFineWhileResearchReady() throws {
        let pack = try ContractFixtures.contentPack()
        let good = try #require(pack.missions.first)

        let rule = AnswerRule(
            kind: .known(.exact),
            canonicalAnswer: MissionShape.unsetFacit,
            acceptedAnswers: [MissionShape.unsetFacit],
            nearMissResponses: []
        )
        let step = FreeTextStep(
            id: "step.ufaerdig",
            order: 1,
            title: "Uden facit",
            answerRule: rule,
            hintIds: []
        )

        let draft = good.copy(steps: [.freeText(step)], status: .known(.researchReady))
        #expect(!MissionShape.violations(of: draft).contains(.playableWithoutAnswer))
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
                NarrativeStep(id: "step.ekstra", order: 2, title: "Ekstra", body: "…", continueLabel: "Videre")
            )
        ]

        let violations = MissionShape.violations(of: good.copy(steps: extra))
        #expect(violations.contains(.wrongStepCount(2)))
    }

    @Test("Et valgspørgsmål med tre muligheder afvises")
    func threeChoicesIsRejected() throws {
        let step = SingleChoiceStep(
            id: "step.tre",
            order: 2,
            eyebrow: nil,
            title: "Tre",
            question: "Hvor mange?",
            options: (1...3).map { ChoiceOption(id: "o\($0)", label: "\($0)") },
            answerRule: AnswerRule(
                kind: .known(.exact),
                canonicalAnswer: "1",
                acceptedAnswers: ["1"],
                nearMissResponses: []
            ),
            hintIds: []
        )

        let pack = try ContractFixtures.contentPack()
        let good = try #require(pack.missions.first)

        let violations = MissionShape.violations(of: good.copy(steps: [.singleChoice(step)]))
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
    func copy(
        steps: [Step]? = nil,
        placeMediaId: String? = nil,
        status: Tolerant<MissionStatus>? = nil
    ) -> Mission {
        Mission(
            id: id,
            slug: slug,
            locationId: locationId,
            title: title,
            shortTitle: shortTitle,
            description: description,
            status: status ?? self.status,
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
