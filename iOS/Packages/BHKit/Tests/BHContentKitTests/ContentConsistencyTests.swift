import BHContracts
import BHGameCore
import BHTestSupport
import Foundation
import Testing

@testable import BHContentKit

/// Selvkonsistens på **den pakke, der faktisk shipper**.
///
/// Uden quizmasterportal er denne testfil den eneste publiceringsport, der
/// findes. Hver test svarer til en regel i data-model.md, og en defekt, der
/// slipper igennem her, er en fejl i valideringen — ikke i indholdet.
@Suite("Indholdets selvkonsistens")
struct ContentConsistencyTests {

    let pack: ContentPack

    init() throws {
        pack = try ContractFixtures.contentPack()
    }

    // MARK: - V-01 Obligatoriske felter

    @Test("V-01: pakken har begge opgaver og de påkrævede felter")
    func requiredFieldsArePresent() throws {
        #expect(pack.schemaVersion == "1.0")
        #expect(pack.locale == "da-DK")
        #expect(pack.missions.count >= 2, "Pakken skal bære mindst Bølgen og Fjordenhus")

        for mission in pack.missions {
            #expect(!mission.fictionLabel.isEmpty, "\(mission.id) mangler fiktionsmarkering")
            #expect(!mission.sourceIds.isEmpty, "\(mission.id) mangler kilder")
            #expect(!mission.completion.historyFact.isEmpty, "\(mission.id) mangler historisk forklaring")
        }

        for location in pack.locations {
            #expect(!location.safety.notes.isEmpty, "\(location.id) mangler sikkerhedsnoter")
            #expect(!location.accessibility.notes.isEmpty, "\(location.id) mangler tilgængelighedsnoter")
        }
    }

    @Test("V-01/V-07: hvert medie har fuld rettighedskæde")
    func mediaCarryFullRights() {
        for asset in pack.media {
            #expect(!asset.altText.isEmpty, "\(asset.id) mangler altText")
            #expect(!asset.owner.isEmpty, "\(asset.id) mangler owner")
            #expect(!asset.licence.isEmpty, "\(asset.id) mangler licence")
            #expect(!asset.credit.isEmpty, "\(asset.id) mangler credit")
            #expect(asset.kind.isKnown, "\(asset.id) har ukendt kind")
        }
    }

    // MARK: - V-02 og V-03: svarreglerne bedømmer sig selv korrekt

    /// Den klassiske forfatterbug er en distraktor, der også accepteres.
    /// Disse to tests er grunden til, at den ikke kan nå at shippe.
    @Test("V-02: hvert kanonisk facit bedømmes korrekt af sin egen regel")
    func canonicalAnswersEvaluateAsCorrect() {
        let evaluator = AnswerEvaluator()
        for mission in pack.missions {
            for step in mission.orderedSteps {
                guard let rule = step.answerRule else { continue }
                let outcome = evaluator.evaluate(rule.canonicalAnswer, rule: rule)
                #expect(
                    outcome.isCorrect,
                    "\(mission.id)/\(step.id): facit '\(rule.canonicalAnswer)' bedømmes som \(outcome)"
                )
            }
        }
    }

    @Test("V-02: hver accepteret form bedømmes korrekt")
    func acceptedFormsEvaluateAsCorrect() {
        let evaluator = AnswerEvaluator()
        for mission in pack.missions {
            for step in mission.orderedSteps {
                guard let rule = step.answerRule else { continue }
                for accepted in rule.acceptedAnswers {
                    #expect(
                        evaluator.evaluate(accepted, rule: rule).isCorrect,
                        "\(mission.id)/\(step.id): '\(accepted)' burde være accepteret"
                    )
                }
            }
        }
    }

    @Test("V-03: ingen registreret near-miss evaluerer til korrekt")
    func nearMissesNeverEvaluateAsCorrect() {
        let evaluator = AnswerEvaluator()
        for mission in pack.missions {
            for step in mission.orderedSteps {
                guard let rule = step.answerRule else { continue }
                for nearMiss in rule.nearMissResponses {
                    let outcome = evaluator.evaluate(nearMiss.answer, rule: rule)
                    #expect(
                        !outcome.isCorrect,
                        "\(mission.id)/\(step.id): '\(nearMiss.answer)' er både distraktor og facit"
                    )
                    guard case .nearMiss = outcome else {
                        Issue.record(
                            "\(mission.id)/\(step.id): '\(nearMiss.answer)' burde give sin egen vejledning, gav \(outcome)"
                        )
                        continue
                    }
                }
            }
        }
    }

    // MARK: - V-04 og V-09: hints

    @Test("V-09: hver mission har præcis 3 hints med order 1, 2, 3")
    func exactlyThreeOrderedHints() {
        for mission in pack.missions {
            #expect(mission.hints.count == 3, "\(mission.id) har \(mission.hints.count) hints")
            #expect(
                mission.orderedHints.map(\.order) == [1, 2, 3],
                "\(mission.id) har forkert hint-rækkefølge"
            )
        }
    }

    @Test("V-04: hintfradragene summer til præcis 12")
    func hintPenaltiesSumToTwelve() {
        for mission in pack.missions {
            let sum = mission.hints.reduce(0) { $0 + $1.penaltyPercent }
            #expect(sum == 12, "\(mission.id) summer til \(sum), ikke 12")
        }
    }

    /// SC-005 lover 88 % tilbage efter alle tre hints. Det holder for
    /// grundpoint, hvor afrundingen går op — men afrundingen sker **pr.
    /// transaktion**, ikke på summen, og det er reglen der gælder.
    ///
    /// Ved 100 point: −3 −4 −5 = 88, altså præcis 88 %.
    /// Ved 50 point: −2 −2 −3 = 43, altså 86 %. Halve point findes ikke.
    ///
    /// Testen hævder derfor **reglen**, ikke tallet. Ville den have hævdet 88 %
    /// for alle, ville den tvinge alle opgaver op på samme grundpoint.
    @Test("Alle tre hints trækker præcis det, afrundingsreglen siger")
    func allHintsFollowTheRoundingRule() {
        let ledger = ScoreLedger()
        for mission in pack.missions {
            let used = mission.orderedHints.map {
                ScoreLedger.UsedHint(hint: $0, eventId: "e-\($0.id)")
            }
            let total = ledger.total(
                of: ledger.transactions(
                    missionId: mission.id,
                    basePoints: mission.basePoints,
                    usedHints: used,
                    completionEventId: "c"
                )
            )
            let expected = mission.basePoints - mission.orderedHints.reduce(0) {
                $0 + ScoreLedger.penalty(base: mission.basePoints, percent: $1.penaltyPercent)
            }
            #expect(total == expected, "\(mission.id) gav \(total), reglen siger \(expected)")
            #expect(total < mission.basePoints, "\(mission.id): hints skal koste noget")
        }
    }

    /// Bølgen og Fjordenhus bærer stadig løftet om præcis 88 point (SC-005).
    @Test("De to oprindelige opgaver giver præcis 88 point med alle hints")
    func theOriginalTwoStillLeaveEightyEight() throws {
        let ledger = ScoreLedger()
        for id in ["mission.boelgen.den-femte-besked", "mission.fjordenhus.vandets-tromler"] {
            let mission = try #require(pack.mission(id: id))
            let used = mission.orderedHints.map {
                ScoreLedger.UsedHint(hint: $0, eventId: "e-\($0.id)")
            }
            let total = ledger.total(
                of: ledger.transactions(
                    missionId: mission.id,
                    basePoints: mission.basePoints,
                    usedHints: used,
                    completionEventId: "c"
                )
            )
            #expect(total == 88, "\(id) gav \(total)")
        }
    }

    // MARK: - V-05: referencer

    @Test("V-05: alle id-referencer resolver")
    func allReferencesResolve() {
        let mediaIds = Set(pack.media.map(\.id))
        let sourceIds = Set(pack.sources.map(\.id))
        let areaIds = Set(pack.areas.map(\.id))
        let locationIds = Set(pack.locations.map(\.id))

        for location in pack.locations {
            #expect(areaIds.contains(location.areaId), "\(location.id) peger på ukendt område")
        }

        for mission in pack.missions {
            #expect(locationIds.contains(mission.locationId), "\(mission.id) peger på ukendt lokation")

            if let heroMediaId = mission.heroMediaId {
                #expect(mediaIds.contains(heroMediaId), "\(mission.id) peger på ukendt hero-medie")
            }
            for sourceId in mission.sourceIds {
                #expect(sourceIds.contains(sourceId), "\(mission.id) peger på ukendt kilde '\(sourceId)'")
            }

            let hintIds = Set(mission.hints.map(\.id))
            for step in mission.orderedSteps {
                for hintId in step.hintIds {
                    #expect(hintIds.contains(hintId), "\(step.id) peger på ukendt hint '\(hintId)'")
                }
            }
        }
    }

    @Test("V-05: id'er er unikke inden for hver samling")
    func idsAreUnique() {
        func expectUnique(_ ids: [String], _ label: String) {
            #expect(Set(ids).count == ids.count, "Dublet-id blandt \(label)")
        }
        expectUnique(pack.areas.map(\.id), "områder")
        expectUnique(pack.locations.map(\.id), "lokationer")
        expectUnique(pack.missions.map(\.id), "missioner")
        expectUnique(pack.media.map(\.id), "medier")
        expectUnique(pack.sources.map(\.id), "kilder")

        for mission in pack.missions {
            expectUnique(mission.steps.map(\.id), "trin i \(mission.id)")
            expectUnique(mission.hints.map(\.id), "hints i \(mission.id)")
        }
    }

    // MARK: - V-08: præcision mod radius

    @Test("V-08: maxAcceptableAccuracyMetres er højst activationRadiusMetres")
    func accuracyFitsWithinRadius() {
        for location in pack.locations {
            guard let accuracy = location.maxAcceptableAccuracyMetres,
                  let radius = location.activationRadiusMetres
            else { continue }
            #expect(
                accuracy <= radius,
                "\(location.id): præcisionskravet \(accuracy) m er større end radius \(radius) m"
            )
        }
    }

    // MARK: - V-10: publiceringsporten

    /// Feature 001 arbejder med foreløbige, ikke-feltverificerede værdier.
    /// Gaten skal derfor bide på begge missioner.
    @Test("V-10: publishReady kræver feltbesøg — og ingen mission er der endnu")
    func publishReadyRequiresFieldVerification() {
        for mission in pack.missions {
            guard let location = pack.location(id: mission.locationId) else { continue }

            let mayBePublishReady =
                location.fieldVerified
                && location.latitude != nil
                && location.longitude != nil
                && location.activationRadiusMetres != nil
                && location.lastPhysicallyVerified != nil

            if mission.status == .known(.publishReady) {
                #expect(mayBePublishReady, "\(mission.id) er publishReady uden feltbesøg")
            }
            #expect(
                mission.status == .known(.fieldTestReady),
                "\(mission.id) forventes fieldTestReady i feature 001"
            )
            #expect(location.fieldVerified == false, "\(location.id) er ikke besøgt endnu")
        }
    }

    // MARK: - Fase 1-afgrænsninger

    @Test("Ingen rute og ingen kapitelprogression")
    func storyFieldsAreReserved() {
        for mission in pack.missions {
            #expect(mission.storyId == nil)
            #expect(mission.chapterId == nil)
            #expect(mission.nextChapterId == nil)
        }
    }

    /// FR-050. Inventory er ude af fase 1, og belønningen er beskeden, pointene
    /// og den historiske forklaring — ikke en genstand.
    @Test("Ingen genstande overrækkes på belønningsskærmen")
    func noInventoryIsHandedOut() {
        let forbidden = ["det femte signal", "fjordseglet"]
        for mission in pack.missions {
            let completionText = [
                mission.completion.headline,
                mission.completion.subheadline,
                mission.completion.messageLabel,
                mission.completion.message,
                mission.completion.historyFact,
            ].joined(separator: " ").lowercased()

            for phrase in forbidden {
                #expect(
                    !completionText.contains(phrase),
                    "\(mission.id) overrækker stadig '\(phrase)' — inventory er ude af fase 1"
                )
            }
        }
    }

    @Test("Hver mission har mindst ét trin, der bedømmes")
    func everyMissionCanBeSolved() {
        for mission in pack.missions {
            #expect(
                mission.orderedSteps.contains { $0.answerRule != nil },
                "\(mission.id) har intet trin med et facit"
            )
            #expect(mission.orderedSteps.first?.kind == "narrative", "\(mission.id) mangler intro")
        }
    }
}
