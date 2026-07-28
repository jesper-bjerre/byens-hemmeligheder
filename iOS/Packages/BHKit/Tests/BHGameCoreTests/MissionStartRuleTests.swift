import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

/// Forfatningens princip I, gjort maskinelt: opgaven kan ikke startes hjemmefra.
@Suite("Start af opgave")
struct MissionStartRuleTests {

    @Test("Ved standpunktet kan opgaven startes")
    func atTheVantagePointItStarts() {
        #expect(MissionStartRule.evaluate(distanceMetres: 0, activationRadiusMetres: 45) == .ready)
        #expect(MissionStartRule.evaluate(distanceMetres: 20, activationRadiusMetres: 45) == .ready)
    }

    @Test("Hjemmefra kan den ikke")
    func fromHomeItDoesNot() {
        let outcome = MissionStartRule.evaluate(distanceMetres: 4000, activationRadiusMetres: 45)
        #expect(outcome.canStart == false)
        guard case .tooFar(let remaining) = outcome else {
            Issue.record("Forventede tooFar, fik \(outcome)")
            return
        }
        #expect(remaining > 3900)
    }

    /// Reglen må aldrig være strengere end gaten.
    @Test("Lige uden for radius åbner den stadig, fordi gaten ville gøre det")
    func slackMatchesTheGate() {
        // Radius 45 m, margen 1,5 → 67,5 m.
        #expect(MissionStartRule.evaluate(distanceMetres: 60, activationRadiusMetres: 45) == .ready)
        #expect(MissionStartRule.evaluate(distanceMetres: 67, activationRadiusMetres: 45) == .ready)
        #expect(MissionStartRule.evaluate(distanceMetres: 70, activationRadiusMetres: 45).canStart == false)
    }

    @Test("Uden position kan der ikke startes")
    func withoutALocationItWaits() {
        let outcome = MissionStartRule.evaluate(distanceMetres: nil, activationRadiusMetres: 45)
        #expect(outcome == .locationUnknown)
        #expect(outcome.canStart == false)
    }

    /// V-10: ingen lokation i feature 001 er opmålt endnu.
    @Test("Uden koordinater gates der ikke")
    func withoutCoordinatesItIsNotGated() {
        let outcome = MissionStartRule.evaluate(distanceMetres: nil, activationRadiusMetres: nil)
        #expect(outcome == .notGated)
        #expect(outcome.canStart, "Spilleren må ikke straffes for, at opmålingen mangler")
    }

    // MARK: - En gåde løses kun én gang

    /// Anden gang kender man facit. Så måler pointene ikke længere det, de skal.
    @Test("En løst opgave kan ikke startes igen")
    func aSolvedMissionCannotBeReplayed() {
        let outcome = MissionStartRule.evaluate(
            isCompleted: true,
            distanceMetres: 0,
            activationRadiusMetres: 45
        )
        #expect(outcome == .alreadySolved)
        #expect(outcome.canStart == false)
    }

    /// Den vigtige rækkefølge: "løst" slår alt andet.
    ///
    /// Uden dette ville en lokation uden koordinater falde igennem til
    /// ``MissionStartability/notGated``, som *kan* startes — og så ville netop
    /// de opgaver, felten endnu ikke har opmålt, kunne spilles om.
    @Test("Løst slår både afstand, manglende position og manglende koordinater")
    func solvedBeatsEveryOtherOutcome() {
        let cases: [(Double?, Double?)] = [
            (0, 45),        // ville været .ready
            (4000, 45),     // ville været .tooFar
            (nil, 45),      // ville været .locationUnknown
            (nil, nil),     // ville været .notGated — og dermed startbar
        ]

        for (distance, radius) in cases {
            let outcome = MissionStartRule.evaluate(
                isCompleted: true,
                distanceMetres: distance,
                activationRadiusMetres: radius
            )
            #expect(
                outcome == .alreadySolved,
                "afstand \(String(describing: distance)), radius \(String(describing: radius)) gav \(outcome)"
            )
        }
    }

    /// Positiv kontrol. Uden den ville ovenstående også bestå, hvis reglen
    /// begyndte at svare `.alreadySolved` på alt.
    @Test("En uløst opgave rammes ikke af spærringen")
    func anUnsolvedMissionIsUnaffected() {
        #expect(
            MissionStartRule.evaluate(
                isCompleted: false,
                distanceMetres: 0,
                activationRadiusMetres: 45
            ) == .ready
        )
    }

    @Test("Kun spærringen for en løst opgave er endelig")
    func onlySolvedIsPermanent() {
        #expect(MissionStartability.alreadySolved.isPermanent)
        #expect(MissionStartability.tooFar(metresRemaining: 500).isPermanent == false)
        #expect(MissionStartability.locationUnknown.isPermanent == false)
        #expect(MissionStartability.ready.isPermanent == false)
        #expect(MissionStartability.notGated.isPermanent == false)
    }

    @Test("Ingen opgave i pakken kan spilles om")
    func noMissionInThePackCanBeReplayed() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let location = try #require(pack.location(id: mission.locationId))
            let outcome = MissionStartRule.evaluate(
                isCompleted: true,
                distanceMetres: 0,
                activationRadiusMetres: location.activationRadiusMetres
            )
            #expect(outcome.canStart == false, "\(mission.id) kunne startes igen efter at være løst")
        }
    }

    @Test("Margenen er dokumenteret og ikke tilfældig")
    func slackIsDocumented() {
        #expect(MissionStartRule.slack == 1.5)
    }

    /// Mod den pakke, der faktisk shipper.
    @Test("Begge opgaver kan startes ved deres eget standpunkt")
    func bothMissionsStartAtTheirOwnVantagePoint() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let location = try #require(pack.location(id: mission.locationId))
            let outcome = MissionStartRule.evaluate(
                distanceMetres: 0,
                activationRadiusMetres: location.activationRadiusMetres
            )
            #expect(outcome.canStart, "\(mission.id) kan ikke startes på sit eget standpunkt")
        }
    }

    @Test("Ingen opgave kan startes fra den anden ende af byen")
    func noMissionStartsFromAcrossTown() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let location = try #require(pack.location(id: mission.locationId))
            let outcome = MissionStartRule.evaluate(
                distanceMetres: 2000,
                activationRadiusMetres: location.activationRadiusMetres
            )
            #expect(outcome.canStart == false, "\(mission.id) kunne startes 2 km væk")
        }
    }
}
