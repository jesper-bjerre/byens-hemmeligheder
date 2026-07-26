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
