import Foundation
import Testing

@testable import ByensGaaderAdmin

/// Fletningen afgør, hvad der sker, når to quizmastere har rettet i den samme
/// pakke. Går den galt, forsvinder nogens arbejde — og det opdages først, når
/// nogen leder efter det uger senere.
@Suite("Fletning")
struct PackMergeTests {

    /// En minimal pakke med to opgaver.
    static func pack(
        version: String = "v1",
        missions: [[String: Any]] = [
            ["id": "m1", "title": "Bølgen", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus", "status": "draft"],
        ]
    ) -> [String: Any] {
        ["contentVersion": version, "missions": missions]
    }

    static func title(_ root: [String: Any], _ id: String) -> String? {
        (root["missions"] as? [[String: Any]])?
            .first { $0["id"] as? String == id }?["title"] as? String
    }

    static func ids(_ root: [String: Any]) -> [String] {
        (root["missions"] as? [[String: Any]])?.compactMap { $0["id"] as? String } ?? []
    }

    // MARK: - De to, der ikke er i vejen for hinanden

    /// Kernen. To quizmastere retter hver sin opgave, og begge rettelser skal
    /// stå bagefter — det er hele grunden til, at fletningen findes.
    @Test("Rettelser i hver sin opgave overlever begge")
    func changesToDifferentMissionsBothSurvive() {
        let base = Self.pack()
        var ours = Self.pack(); ours["missions"] = [
            ["id": "m1", "title": "Bølgen — rettet af mig", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus", "status": "draft"],
        ]
        var theirs = Self.pack(); theirs["missions"] = [
            ["id": "m1", "title": "Bølgen", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus — rettet af dem", "status": "draft"],
        ]

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(Self.title(result.root, "m1") == "Bølgen — rettet af mig")
        #expect(Self.title(result.root, "m2") == "Fjordenhus — rettet af dem")
        #expect(result.conflicts.isEmpty)
    }

    @Test("Forskellige felter i den samme opgave er heller ikke en konflikt")
    func differentFieldsInTheSameMissionMerge() {
        let base = Self.pack(missions: [["id": "m1", "title": "Bølgen", "status": "draft"]])
        let ours = Self.pack(missions: [["id": "m1", "title": "Ny titel", "status": "draft"]])
        let theirs = Self.pack(
            missions: [["id": "m1", "title": "Bølgen", "status": "fieldTestReady"]])

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)
        let mission = (result.root["missions"] as? [[String: Any]])?.first

        #expect(mission?["title"] as? String == "Ny titel")
        #expect(mission?["status"] as? String == "fieldTestReady")
        #expect(result.conflicts.isEmpty)
    }

    /// Uden basis ville en tovejsfletning skrive vores urørte felter tilbage
    /// oven i deres arbejde — præcis det, `If-Match` findes for at forhindre.
    @Test("Felter, vi ikke har rørt, tager deres værdi")
    func untouchedFieldsTakeTheirValue() {
        let base = Self.pack(version: "v1")
        let ours = Self.pack(version: "v1")
        let theirs = Self.pack(version: "v2")

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(result.root["contentVersion"] as? String == "v2")
        #expect(result.conflicts.isEmpty)
    }

    @Test("Har begge rettet det samme til det samme, er der ingen konflikt")
    func identicalChangesAgree() {
        let base = Self.pack(version: "v1")
        let ours = Self.pack(version: "v2")
        let theirs = Self.pack(version: "v2")

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)
        #expect(result.root["contentVersion"] as? String == "v2")
        #expect(result.conflicts.isEmpty)
    }

    // MARK: - Den ægte konflikt

    /// Vores værdi vinder, fordi den, der står med telefonen, er den eneste,
    /// der kan tage stilling. Men den må aldrig vinde i tavshed.
    @Test("Samme felt rettet forskelligt: vores står, og det bliver meldt")
    func sameFieldDifferentValuesIsReported() {
        let base = Self.pack(missions: [["id": "m1", "title": "Bølgen", "status": "draft"]])
        let ours = Self.pack(missions: [["id": "m1", "title": "Min titel", "status": "draft"]])
        let theirs = Self.pack(missions: [["id": "m1", "title": "Deres titel", "status": "draft"]])

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(Self.title(result.root, "m1") == "Min titel")
        #expect(result.hasConflicts)
        #expect(result.conflicts.contains { $0.contains("m1") && $0.contains("title") })
    }

    // MARK: - Tilføjelser og sletninger

    /// To, der hver opretter en opgave, ville med en pladsbaseret fletning
    /// begge skrive på plads nummer tre, og den ene ville forsvinde.
    @Test("To nye opgaver, én fra hver, er der begge bagefter")
    func additionsFromBothSidesSurvive() {
        let base = Self.pack()
        let ours = Self.pack(missions: [
            ["id": "m1", "title": "Bølgen", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus", "status": "draft"],
            ["id": "m3", "title": "Min nye", "status": "draft"],
        ])
        let theirs = Self.pack(missions: [
            ["id": "m1", "title": "Bølgen", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus", "status": "draft"],
            ["id": "m4", "title": "Deres nye", "status": "draft"],
        ])

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(Set(Self.ids(result.root)) == ["m1", "m2", "m3", "m4"])
        #expect(result.conflicts.isEmpty)
    }

    @Test("En sletning, den anden ikke har rørt, står ved magt")
    func deletionsStand() {
        let base = Self.pack()
        let ours = Self.pack(missions: [["id": "m1", "title": "Bølgen", "status": "draft"]])
        let theirs = Self.pack()

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(Self.ids(result.root) == ["m1"])
        #expect(result.conflicts.isEmpty)
    }

    /// Den farligste kombination. Havde den anden lige slettet opgaven, mens vi
    /// rettede i den, må rettelsen ikke bare forsvinde uden et ord.
    @Test("Slettet af den ene, rettet af den anden: den overlever og meldes")
    func deleteVersusEditKeepsTheEdit() {
        let base = Self.pack()
        let ours = Self.pack(missions: [
            ["id": "m1", "title": "Bølgen", "status": "draft"],
            ["id": "m2", "title": "Fjordenhus — jeg rettede den", "status": "draft"],
        ])
        let theirs = Self.pack(missions: [["id": "m1", "title": "Bølgen", "status": "draft"]])

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)

        #expect(Set(Self.ids(result.root)) == ["m1", "m2"])
        #expect(result.hasConflicts)
    }

    // MARK: - Lister uden id

    /// `tags` og `acceptedAnswers` har ingen id'er at flette på. De behandles
    /// som én værdi — det er ærligere end at gætte på rækkefølgen.
    @Test("En liste uden id'er flettes ikke element for element")
    func listsWithoutIdsAreWholeValues() {
        let base = Self.pack(missions: [["id": "m1", "tags": ["a"]]])
        let ours = Self.pack(missions: [["id": "m1", "tags": ["a", "mine"]]])
        let theirs = Self.pack(missions: [["id": "m1", "tags": ["a", "deres"]]])

        let result = PackMerge.merge(base: base, ours: ours, theirs: theirs)
        let tags = (result.root["missions"] as? [[String: Any]])?.first?["tags"] as? [String]

        #expect(tags == ["a", "mine"])
        #expect(result.hasConflicts)
    }

    // MARK: - Mod den rigtige pakke

    @Test("Fletning af den shippende pakke med sig selv ændrer intet")
    func mergingTheRealPackWithItselfIsANoop() throws {
        let document = try ContractFixtures.document()
        let result = PackMerge.merge(
            base: document.root, ours: document.root, theirs: document.root)

        #expect(result.conflicts.isEmpty)
        #expect(NSDictionary(dictionary: result.root).isEqual(to: document.root))
    }

    /// Hele vejen igennem `PackDocument`, som appen gør det efter en `412`.
    @Test("rebase lægger vores rettelse oven på serverens udgave")
    func rebaseAppliesOurEditOnTopOfTheirs() throws {
        let ours = try ContractFixtures.document()
        let server = try ContractFixtures.document()

        ours.setValue("Min titel", at: .mission(0, .key("title")))
        server.setValue("Deres beskrivelse", at: .mission(1, .key("description")))

        let conflicts = ours.rebase(onto: server)

        #expect(ours.string(at: .mission(0, .key("title"))) == "Min titel")
        #expect(ours.string(at: .mission(1, .key("description"))) == "Deres beskrivelse")
        #expect(conflicts.isEmpty)
    }

    /// Efter en fletning er serverens udgave den nye basis. Er den ikke det,
    /// vil næste gemning tro, at alle deres felter også er vores rettelser.
    @Test("Efter rebase er der intet ugemt, hvis vi intet havde rettet")
    func rebaseResetsTheBaseline() throws {
        let ours = try ContractFixtures.document()
        let server = try ContractFixtures.document()
        server.setValue("Deres titel", at: .mission(0, .key("title")))

        ours.rebase(onto: server)

        #expect(ours.string(at: .mission(0, .key("title"))) == "Deres titel")
        #expect(ours.hasUnsavedChanges == false)
    }

    /// Uden dette ville forsøg nummer to blive afvist med den samme `412`, og
    /// quizmasteren ville sidde i en løkke, hen ikke kan komme ud af.
    @Test("Efter rebase gemmes der mod serverens nye ETag")
    func rebaseAdoptsTheServerETag() throws {
        let ours = try PackDocument(
            data: try ContractFixtures.contentPackData(), etag: "\"gammel\"")
        let server = try PackDocument(
            data: try ContractFixtures.contentPackData(), etag: "\"ny\"")

        ours.rebase(onto: server)

        #expect(ours.etag == "\"ny\"")
    }
}

/// Kladden er det eneste, der står mellem en halv times arbejde i felten og
/// ingenting, når iOS lukker appen bag ryggen på quizmasteren.
@Suite("Kladden", .serialized)
struct DraftStoreTests {

    init() { DraftStore.clear() }

    @Test("En pakke uden rettelser efterlader ingen kladde")
    func nothingToSaveWritesNothing() throws {
        let document = try ContractFixtures.document()
        DraftStore.save(document)
        #expect(DraftStore.restore() == nil)
    }

    @Test("En rettelse kan hentes tilbage efter et nedbrud")
    func editsSurviveARestart() throws {
        let document = try ContractFixtures.document()
        document.setValue("Overlevede", at: .mission(0, .key("title")))
        DraftStore.save(document)

        let restored = try #require(DraftStore.restore())
        #expect(restored.document.string(at: .mission(0, .key("title"))) == "Overlevede")
        #expect(restored.document.hasUnsavedChanges, "kladden skal stadig vide, at den er ugemt")
        DraftStore.clear()
    }

    /// Uden basis kan fletningen ikke se, hvad quizmasteren selv havde rørt —
    /// og en genoprettet kladde ville skrive hele pakken tilbage som "mine
    /// rettelser".
    @Test("Kladden husker, hvilken udgave rettelserne blev lagt oven på")
    func theDraftRemembersItsBase() throws {
        let document = try ContractFixtures.document()
        let originalTitle = document.string(at: .mission(1, .key("title")))
        document.setValue("Kun denne", at: .mission(0, .key("title")))
        DraftStore.save(document)

        let restored = try #require(DraftStore.restore()).document
        let server = try ContractFixtures.document()
        server.setValue("Deres rettelse", at: .mission(1, .key("title")))
        restored.rebase(onto: server)

        #expect(restored.string(at: .mission(0, .key("title"))) == "Kun denne")
        #expect(restored.string(at: .mission(1, .key("title"))) == "Deres rettelse",
                "vores urørte felt måtte ikke skrive \(originalTitle) tilbage")
        DraftStore.clear()
    }

    @Test("En ulæselig kladde ryddes frem for at spørge ved hver start")
    func unreadableDraftsAreCleared() throws {
        let document = try ContractFixtures.document()
        document.setValue("Noget", at: .mission(0, .key("title")))
        DraftStore.save(document)

        let folder = URL.applicationSupportDirectory.appending(path: "ByensGaaderAdmin")
        try Data("ikke json".utf8).write(to: folder.appending(path: "kladde.json"))

        #expect(DraftStore.restore() == nil)
        #expect(DraftStore.restore() == nil, "den skulle være ryddet ved første forsøg")
    }
}
