import Foundation
import Testing

@testable import ByensGaaderAdmin

/// Dokumentlaget er det farligste sted i admin-appen.
///
/// `PackDocument` skriver i det indhold, familier spiller på. Den modellerer
/// bevidst ikke kontrakten — den retter enkeltfelter i rå JSON — og prisen for
/// den frihed er, at ingen typechecker fanger en forkert sti. Det gør testene
/// her i stedet.
@Suite("Dokumentet")
struct PackDocumentTests {

    // MARK: - Læsning

    @Test("Pakken læses og bærer de opgaver, der shipper")
    func readsTheShippingPack() throws {
        let document = try ContractFixtures.document()
        #expect(!document.contentVersion.isEmpty)
        #expect(document.missions.count >= 2)
    }

    @Test("Et dybt felt kan læses gennem sin sti")
    func readsADeepField() throws {
        let document = try ContractFixtures.document()
        let facit: [JSONStep] = .mission(0, .key("steps"), .index(0), .key("answerRule"),
                                         .key("canonicalAnswer"))
        #expect(document.string(at: facit) == "592")
    }

    @Test("En sti, der ikke findes, giver tomt frem for at vælte")
    func missingPathsAreEmpty() throws {
        let document = try ContractFixtures.document()
        #expect(document.value(at: .mission(999, .key("title"))) == nil)
        #expect(document.string(at: [.key("findes"), .key("ikke")]).isEmpty)
        #expect(document.integer(at: .mission(0, .key("findesIkke"))) == nil)
    }

    // MARK: - Skrivning

    @Test("Ét felt rettes, og naboen står urørt")
    func writingOneFieldLeavesTheNeighbourAlone() throws {
        let document = try ContractFixtures.document()
        let neighbour = document.string(at: .mission(1, .key("title")))

        document.setValue("Rettet titel", at: .mission(0, .key("title")))

        #expect(document.string(at: .mission(0, .key("title"))) == "Rettet titel")
        #expect(document.string(at: .mission(1, .key("title"))) == neighbour)
    }

    /// Grunden til at appen ikke modellerer kontrakten. Kunne en gemning tabe et
    /// felt, appen ikke kender, ville spillerappens næste udvidelse blive slettet
    /// af den første quizmaster, der rettede en titel.
    @Test("Felter, editoren ikke kender, overlever en gemning")
    func unknownFieldsSurviveASave() throws {
        let document = try ContractFixtures.document()
        let original = try JSONSerialization.jsonObject(
            with: try ContractFixtures.contentPackData()) as? [String: Any]

        document.setValue("Rettet", at: .mission(0, .key("title")))
        let roundTripped = try PackDocument(data: try document.serialised(), etag: nil)

        #expect(Set(roundTripped.root.keys) == Set(original?.keys ?? [:].keys))
        #expect(roundTripped.value(at: .mission(0, .key("narrationMediaId"))) != nil)
        #expect(roundTripped.string(at: .mission(0, .key("fictionLabel"))).isEmpty == false)
    }

    /// Kontrakten skelner: `heroMediaId: null` betyder "intet billede", mens en
    /// manglende nøgle er et brud. Spillerappen viser en tom plads for det
    /// første og fejler på det andet.
    @Test("null skrives som null, og nil fjerner nøglen")
    func nullAndRemovalAreDifferent() throws {
        let document = try ContractFixtures.document()

        document.setValue(NSNull(), at: .mission(0, .key("heroMediaId")))
        #expect(document.value(at: .mission(0, .key("heroMediaId"))) is NSNull)

        document.setValue(nil, at: .mission(0, .key("heroMediaId")))
        #expect(document.value(at: .mission(0, .key("heroMediaId"))) == nil)
    }

    @Test("To gemninger af det samme giver de samme bytes")
    func serialisationIsStable() throws {
        let document = try ContractFixtures.document()
        #expect(try document.serialised() == (try document.serialised()))
    }

    // MARK: - Lister

    @Test("Et kort kan tilføjes, flyttes og fjernes, og order følger med")
    func cardsReorderAndRenumber() throws {
        let document = try ContractFixtures.document()
        let cards: [JSONStep] = .mission(0, .key("cards"))
        let before = document.objects(at: cards).count

        document.append(["id": "card.proeve", "order": 99, "text": "sidst"], to: cards)
        document.renumber(cards)
        #expect(document.objects(at: cards).count == before + 1)
        #expect(document.integer(at: cards + [.index(before), .key("order")]) == before + 1)

        document.move(fromOffsets: IndexSet(integer: before), toOffset: 0, in: cards)
        document.renumber(cards)
        #expect(document.string(at: cards + [.index(0), .key("id")]) == "card.proeve")
        #expect(document.integer(at: cards + [.index(0), .key("order")]) == 1)
        #expect(document.integer(at: cards + [.index(1), .key("order")]) == 2)

        document.remove(at: 0, in: cards)
        #expect(document.objects(at: cards).count == before)
    }

    /// Pilene i Detaljer bruger `move(fromOffsets:toOffset:)`, og `toOffset`
    /// tælles i listen **før** flytningen — et skridt ned er to pladser frem.
    /// Den regel er nem at tage fejl af, og en ombytning, der springer over,
    /// opdages først, når en spiller læser detaljerne i forkert rækkefølge.
    @Test("Op og ned flytter præcis én plads")
    func arrowsMoveExactlyOneStep() throws {
        let document = try ContractFixtures.document()
        let cards: [JSONStep] = .mission(0, .key("cards"))

        func ids() -> [String] {
            document.objects(at: cards).compactMap { $0["id"] as? String }
        }

        let start = ids()
        try #require(start.count >= 3, "opgaven skal have mindst tre detaljer")

        // Ned fra plads 0.
        document.move(fromOffsets: IndexSet(integer: 0), toOffset: 2, in: cards)
        #expect(ids() == [start[1], start[0], start[2]] + start.dropFirst(3))

        // Op igen fra plads 1.
        document.move(fromOffsets: IndexSet(integer: 1), toOffset: 0, in: cards)
        #expect(ids() == start, "op efter ned skal give det, man startede med")
    }

    // MARK: - Medier

    /// Medier overskrives aldrig — serveren svarer `409` på et kendt filnavn,
    /// fordi billeder sendes med et års cache. Nummeret **er** versionen, så det
    /// skal tælles op og aldrig genbruges.
    @Test("Næste medienummer er ét over det højeste, der er brugt")
    func mediaNumbersCountUp() throws {
        let document = try ContractFixtures.document()
        #expect(document.nextMediaNumber(stem: "boelgen") == 4)
        #expect(document.nextMediaNumber(stem: "findes-ikke") == 0)
    }

    // MARK: - Hierarkiet

    @Test("Opgaverne grupperes som landsdel → postnummer")
    func hierarchyGroupsByRegionThenPostalCode() throws {
        let document = try ContractFixtures.document()
        let tree = document.hierarchy

        #expect(tree.count == 1)
        #expect(tree.first?.region == "sydjylland")
        #expect(tree.first?.places.count == 2)
        #expect(tree.first?.places.first?.title == "7100 Vejle")
    }

    /// En opgave, der ikke kan ses, kan heller ikke rettes — og det er netop den
    /// slags fejl, quizmasteren skal kunne finde.
    @Test("Ingen opgave falder ud af hierarkiet")
    func nothingFallsOutOfTheHierarchy() throws {
        let document = try ContractFixtures.document()
        let grouped = document.hierarchy.flatMap { $0.places.flatMap(\.missions) }
        #expect(grouped.count == document.missions.count)
    }

    @Test("En opgave uden gyldigt postnummer forsvinder ikke")
    func brokenPostalCodesStillShow() throws {
        let document = try ContractFixtures.document()
        document.setValue("0000", at: .location(0, .key("postalCode")))

        let grouped = document.hierarchy.flatMap { $0.places.flatMap(\.missions) }
        #expect(grouped.count == document.missions.count)
        #expect(document.hierarchy.contains { $0.region.isEmpty })
    }

    // MARK: - Ny opgave

    /// Titlen er tom, fordi en forudfyldt "Ny opgave" skal slettes, før
    /// quizmasteren kan skrive sin egen — hver eneste gang.
    @Test("En ny opgave har ingen titel og et foreløbigt id")
    func newMissionStartsWithoutATitle() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission()

        #expect(document.string(at: .mission(created.index, .key("title"))).isEmpty)
        #expect(created.id.hasPrefix("mission.ny-opgave"))
    }

    /// Uden dette ville en opgave hedde `mission.ny-opgave-3` for altid — også
    /// i revisionssporet og i filnavnene på dens billeder.
    @Test("Ved gemning får en ny opgave titlens id — og alt inden i den følger med")
    func idsFollowTheTitleOnFirstSave() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission()
        document.setValue("Bølgen på Åen", at: .mission(created.index, .key("title")))

        document.finaliseNewMissionIds()
        let index = created.index

        #expect(document.string(at: .mission(index, .key("id"))) == "mission.boelgen-paa-aaen")
        #expect(document.string(at: .mission(index, .key("slug"))) == "boelgen-paa-aaen")

        let locationId = document.string(at: .mission(index, .key("locationId")))
        #expect(locationId == "loc.boelgen-paa-aaen")
        #expect(document.locationIndex(forMissionAt: index) != nil, "stedet skal stadig kunne findes")

        let hintIds = document.objects(at: .mission(index, .key("hints")))
            .compactMap { $0["id"] as? String }
        #expect(hintIds == ["hint.boelgen-paa-aaen.1", "hint.boelgen-paa-aaen.2", "hint.boelgen-paa-aaen.3"])

        // Trinnet peger på hintene. Peger det på de gamle, kan spilleren ikke
        // åbne et eneste hint.
        let stepHintIds = document.strings(
            at: .mission(index, .key("steps"), .index(0), .key("hintIds")))
        #expect(stepHintIds == hintIds)
        #expect(document.string(at: .mission(index, .key("steps"), .index(0), .key("id")))
            == "step.boelgen-paa-aaen.opgaven")
    }

    @Test("En opgave uden titel omdøbes ikke")
    func untitledMissionsKeepTheirProvisionalId() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission()

        document.finaliseNewMissionIds()

        #expect(document.string(at: .mission(created.index, .key("id"))) == created.id)
    }

    /// Den vigtigste grænse. En opgave, der ligger på serveren, må aldrig
    /// skifte id — alt, der peger på den, ville pege i luften.
    @Test("En gemt opgave omdøbes aldrig, uanset hvad titlen bliver")
    func savedMissionsAreNeverRenamed() throws {
        let document = try ContractFixtures.document()
        let originalId = document.string(at: .mission(0, .key("id")))

        document.setValue("En helt anden titel", at: .mission(0, .key("title")))
        document.finaliseNewMissionIds()

        #expect(document.string(at: .mission(0, .key("id"))) == originalId)
    }

    @Test("Detaljernes id'er følger også med")
    func cardIdsFollowTheRename() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission()
        document.setValue("Kaninens hul", at: .mission(created.index, .key("title")))
        document.append(["id": "card.gammel.1", "order": 1, "text": "x"],
                        to: .mission(created.index, .key("cards")))

        document.finaliseNewMissionIds()

        #expect(document.string(at: .mission(created.index, .key("cards"), .index(0), .key("id")))
            == "card.kaninens-hul.1")
    }

    /// En opgave, der siger "mangler" til spilleren, er ikke en halvfærdig
    /// opgave — den er en fejl, der er sluppet ud.
    @Test("En ny opgave bærer ingen pladsholdere i det, spilleren ser")
    func newMissionsCarryNoPlaceholders() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission(named: "Kaninens hul")
        document.finaliseNewMissionIds()

        let index = created.index
        let synlige = [
            document.string(at: .mission(index, .key("fictionLabel"))),
            document.string(at: .mission(index, .key("completion"), .key("headline"))),
            document.string(at: .mission(index, .key("completion"), .key("message"))),
            document.string(at: .mission(index, .key("completion"), .key("historyFact"))),
        ]
        for tekst in synlige {
            #expect(!tekst.isEmpty)
            #expect(!tekst.lowercased().contains("mangler"), "'\(tekst)' siger mangler")
        }

        let sted = try #require(document.locationIndex(forMissionAt: index))
        #expect(document.string(at: .location(sted, .key("name"))) == "Kaninens hul")
        #expect(!document.string(at: .location(sted, .key("address"))).contains("mangler"))
        #expect(!document.string(
            at: .location(sted, .key("safety"), .key("notes"))).contains("ikke vurderet"))
    }

    /// Sikkerhedsteksten må ikke påstå, at stedet er gennemgået. Den lover
    /// ellers noget, ingen har kontrolleret (forfatningens princip IV).
    @Test("Sikkerhedsteksten er forholdsregler og ikke en vurdering")
    func safetyNotesDoNotClaimAnAssessment() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission(named: "Prøve")
        let sted = try #require(document.locationIndex(forMissionAt: created.index))
        let noter = document.string(at: .location(sted, .key("safety"), .key("notes")))

        #expect(noter.contains("ikke særskilt sikkerhedsvurderet"))
    }

    @Test("En ny opgave er komplet og kommer med i hierarkiet")
    func newMissionIsComplete() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission(named: "Prøveopgave i Vejle")

        #expect(created.id == "mission.proeveopgave-i-vejle")
        #expect(document.locationIndex(forMissionAt: created.index) != nil)
        #expect(document.objects(at: .mission(created.index, .key("hints"))).count == 3)
        #expect(document.objects(at: .mission(created.index, .key("steps"))).count == 1)
        #expect(document.hierarchy.flatMap { $0.places.flatMap(\.missions) }
            .contains { $0.id == created.id })
    }

    /// "Ny opgave" trykkes typisk to gange i træk. To opgaver med samme id gør
    /// pakken ugyldig.
    @Test("To opgaver med samme navn får hver sit id")
    func duplicateNamesGetDistinctIds() throws {
        let document = try ContractFixtures.document()
        let first = document.createMission(named: "Prøve")
        let second = document.createMission(named: "Prøve")

        #expect(first.id != second.id)
        #expect(second.id == "mission.proeve-2")
    }

    @Test("En ny opgave arver postnummeret fra den seneste")
    func newMissionInheritsThePostalCode() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission(named: "Arvet")
        #expect(document.string(at: .location(
            document.locationIndex(forMissionAt: created.index) ?? 0,
            .key("postalCode"))) == "7120")
    }

    // MARK: - Felter, ingen redigerer

    /// Svarmotoren bedømmer kun mod `acceptedAnswers`. Står facit ikke på
    /// listen, er den rigtige løsning forkert — og det opdages først, når en
    /// familie står på stedet med det rigtige svar og får nej.
    @Test("Facit står altid blandt de accepterede svar")
    func theCanonicalAnswerIsAlwaysAccepted() throws {
        let document = try ContractFixtures.document()
        let rule: [JSONStep] = .mission(0, .key("steps"), .index(0), .key("answerRule"))

        // Sådan gør bindingen i Spørgsmål-fanebladet.
        func setFacit(_ new: String) {
            let previous = document.string(at: rule + [.key("canonicalAnswer")])
            document.setValue(new, at: rule + [.key("canonicalAnswer")])
            var answers = document.strings(at: rule + [.key("acceptedAnswers")])
            if let position = answers.firstIndex(of: previous) {
                answers[position] = new
            } else if !answers.contains(new) {
                answers.append(new)
            }
            document.setValue(answers.filter { !$0.isEmpty }, at: rule + [.key("acceptedAnswers")])
        }

        setFacit("777")
        #expect(document.strings(at: rule + [.key("acceptedAnswers")]).contains("777"))

        // Og det gamle facit må ikke blive stående som accepteret.
        setFacit("778")
        let answers = document.strings(at: rule + [.key("acceptedAnswers")])
        #expect(answers.contains("778"))
        #expect(!answers.contains("777"), "det gamle facit tæller stadig som rigtigt")
    }

    /// Trinnets titel og hintenes overskrifter er ude af UI'et, men kontrakten
    /// kræver dem. Uden dette gemmes en ugyldig pakke.
    @Test("De felter, ingen redigerer, udfyldes ved gemning")
    func hiddenRequiredLabelsAreFilled() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission()
        document.setValue("Prøvetitel uden dubletter", at: .mission(created.index, .key("title")))
        document.setValue("", at: .mission(created.index, .key("steps"), .index(0), .key("title")))
        document.setValue("", at: .mission(created.index, .key("hints"), .index(0), .key("title")))

        document.finaliseNewMissionIds()
        document.fillRequiredLabels()

        let index = created.index
        #expect(document.string(at: .mission(index, .key("steps"), .index(0), .key("title")))
            == "Prøvetitel uden dubletter")
        #expect(document.string(at: .mission(index, .key("hints"), .index(0), .key("title")))
            == "Hvor")
    }

    // MARK: - Sletning

    @Test("En slettet opgave tager sit sted med, når ingen anden bruger det")
    func deletingAMissionTakesItsPlace() throws {
        let document = try ContractFixtures.document()
        let created = document.createMission(named: "Slettes")
        let locations = document.objects(at: [.key("locations")]).count

        document.deleteMission(at: created.index)

        #expect(document.missions.contains { $0.id == created.id } == false)
        #expect(document.objects(at: [.key("locations")]).count == locations - 1)
    }

    /// To opgaver kan dele et sted. Rev sletningen stedet med, ville den anden
    /// opgave miste sit koordinat uden at nogen så det.
    @Test("Et delt sted bliver stående")
    func sharedPlacesSurvive() throws {
        let document = try ContractFixtures.document()
        let locations = document.objects(at: [.key("locations")]).count

        // De to første opgaver deler ikke sted i pakken; peg den anden på den
        // førstes, så de gør.
        let shared = document.string(at: .mission(0, .key("locationId")))
        document.setValue(shared, at: .mission(1, .key("locationId")))

        document.deleteMission(at: 1)

        #expect(document.objects(at: [.key("locations")]).count == locations)
    }
}

/// Ordbogen oversætter kontraktens engelske wire-værdier til dansk. Oversættelsen
/// må aldrig havne i pakken — den er kun til skærmen.
@Suite("Ordbogen")
struct VocabularyTests {

    @Test("fieldTestReady vises som Frigivet")
    func statusNamesFollowFR104() {
        #expect(Vocabulary.statusName("fieldTestReady") == "Frigivet")
        #expect(Vocabulary.statusName("draft") == "Kladde")
    }

    /// En pakke kan være nyere end appen. En status, quizmasteren ikke kan se,
    /// er værre end en, hen ikke kan oversætte.
    @Test("En ukendt værdi gives tilbage uændret")
    func unknownValuesPassThrough() {
        #expect(Vocabulary.statusName("noget-nyt") == "noget-nyt")
        #expect(Vocabulary.regionName("marsjylland") == "marsjylland")
    }

    /// Quizmasteren arbejder kun med to. Bærer en opgave alligevel en af de tre
    /// andre, skal den kunne flyttes — ellers er den låst fast for altid.
    @Test("Statusvælgeren viser den værdi, opgaven faktisk står i")
    func theCurrentStatusIsAlwaysOffered() {
        #expect(Vocabulary.statusChoices(current: "draft") == ["draft", "fieldTestReady"])
        #expect(Vocabulary.statusChoices(current: "paused").contains("paused"))
        #expect(Vocabulary.statusChoices(current: "paused").count == 3)
    }

    @Test("Danske titler bliver til id'er, kontrakten accepterer")
    func slugsAreValidIds() {
        #expect("Bølgen på Åen".packSlug == "boelgen-paa-aaen")
        #expect("Café 42!".packSlug == "cafe-42")
        #expect("   ".packSlug == "uden-navn")

        // Skemaets mønster: ^[a-z0-9]+([._-][a-z0-9]+)*$
        for title in ["Bølgen på Åen", "Café 42!", "   ", "Vejle Ø", "3 små grise"] {
            let slug = title.packSlug
            #expect(
                slug.wholeMatch(of: /[a-z0-9]+([._-][a-z0-9]+)*/) != nil,
                "'\(title)' gav '\(slug)', som skemaet vil afvise")
        }
    }
}

/// Tabellen er genereret fra Dataforsyningen. Testene her fanger, at
/// genereringen er kørt skævt — ikke at Danmark har ændret sig.
@Suite("Postnumre")
struct PostnumreTests {

    @Test("Alle 1089 postnumre er der, og hvert har en kendt landsdel")
    func theTableIsComplete() {
        #expect(Postnumre.all.count == 1089)
        #expect(Postnumre.all.allSatisfy { Vocabulary.regions.contains($0.region) })
        #expect(Postnumre.all.allSatisfy { $0.code.count == 4 && $0.code.allSatisfy(\.isNumber) })
        #expect(Postnumre.all.allSatisfy { !$0.city.isEmpty })
    }

    @Test("Kendte postnumre slår op til den rigtige by og landsdel")
    func knownCodesResolve() {
        #expect(Postnumre.city("7100") == "Vejle")
        #expect(Postnumre.region("7100") == "sydjylland")
        #expect(Postnumre.city("1050") == "København K")
        #expect(Postnumre.region("2300") == "byenKoebenhavn")
        #expect(Postnumre.region("3700") == "bornholm")
        #expect(Postnumre.region("8000") == "oestjylland")
        #expect(Postnumre.region("9990") == "nordjylland")
    }

    @Test("Et postnummer, der ikke findes, giver nil frem for et gæt")
    func unknownCodesAreNil() {
        #expect(Postnumre.sted("0000") == nil)
        #expect(Postnumre.city("9999") == nil)
    }

    @Test("Hver landsdel har postnumre, så ingen vælger fører til en tom liste")
    func everyRegionHasPlaces() {
        for region in Vocabulary.regions {
            #expect(!Postnumre.inRegion(region).isEmpty, "\(region) er tom")
        }
    }
}
