import BHContracts
import BHTestSupport
import Foundation
import Testing

@testable import BHGameCore

@Suite("Hints i rækkefølge")
struct HintRuleTests {

    /// Mod den pakke, der faktisk shipper.
    func hints() throws -> [Hint] {
        let pack = try ContractFixtures.contentPack()
        let mission = try #require(pack.mission(id: "mission.boelgen.den-femte-besked"))
        return mission.orderedHints
    }

    @Test("Uden noget åbnet er kun det første tilgængeligt")
    func onlyTheFirstIsOpenAtTheStart() throws {
        let hints = try hints()
        #expect(HintRule.isUnlocked(hints[0], in: hints, revealed: []))
        #expect(HintRule.isUnlocked(hints[1], in: hints, revealed: []) == false)
        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: []) == false)
    }

    @Test("Hint 2 åbner, når hint 1 er brugt")
    func theSecondOpensAfterTheFirst() throws {
        let hints = try hints()
        let revealed: Set<String> = [hints[0].id]

        #expect(HintRule.isUnlocked(hints[1], in: hints, revealed: revealed))
        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: revealed) == false)
    }

    @Test("Hint 3 kræver både 1 og 2")
    func theThirdNeedsBoth() throws {
        let hints = try hints()

        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: [hints[0].id]) == false)
        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: [hints[1].id]) == false)
        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: [hints[0].id, hints[1].id]))
    }

    /// Et hul i rækken må ikke kunne opstå. Kravet gælder alle lavere hints,
    /// ikke kun det umiddelbart foregående.
    @Test("Et spring over hint 1 låser ikke hint 3 op")
    func skippingLeavesTheLadderIntact() throws {
        let hints = try hints()
        // Kun hint 2 åbnet — hvilket i sig selv ikke kan lade sig gøre, men
        // reglen skal holde uanset hvordan tilstanden er opstået.
        #expect(HintRule.isUnlocked(hints[2], in: hints, revealed: [hints[1].id]) == false)
    }

    @Test("Næste tilgængelige hint følger rækkefølgen")
    func nextAvailableWalksTheLadder() throws {
        let hints = try hints()

        #expect(HintRule.nextAvailable(in: hints, revealed: [])?.order == 1)
        #expect(HintRule.nextAvailable(in: hints, revealed: [hints[0].id])?.order == 2)
        #expect(HintRule.nextAvailable(in: hints, revealed: [hints[0].id, hints[1].id])?.order == 3)
        #expect(
            HintRule.nextAvailable(
                in: hints,
                revealed: Set(hints.map(\.id))
            ) == nil,
            "Med alle åbnet er der intet næste"
        )
    }

    @Test("Det spærrende hint er det laveste uåbnede")
    func blockingHintIsTheLowestUnopened() throws {
        let hints = try hints()

        #expect(HintRule.blocking(hints[2], in: hints, revealed: [])?.order == 1)
        #expect(HintRule.blocking(hints[2], in: hints, revealed: [hints[0].id])?.order == 2)
        #expect(HintRule.blocking(hints[0], in: hints, revealed: []) == nil)
    }

    @Test("Begge opgaver har en hintstige, der kan gås igennem")
    func bothMissionsHaveAWalkableLadder() throws {
        let pack = try ContractFixtures.contentPack()

        for mission in pack.missions {
            let hints = mission.orderedHints
            var revealed: Set<String> = []

            for expected in 1...3 {
                let next = HintRule.nextAvailable(in: hints, revealed: revealed)
                #expect(next?.order == expected, "\(mission.id) brød rækkefølgen ved hint \(expected)")
                guard let next else { break }
                #expect(HintRule.isUnlocked(next, in: hints, revealed: revealed))
                revealed.insert(next.id)
            }
            #expect(HintRule.nextAvailable(in: hints, revealed: revealed) == nil)
        }
    }
}
