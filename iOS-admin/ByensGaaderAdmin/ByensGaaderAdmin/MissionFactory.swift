import Foundation

/// Oprettelsen af en ny opgave (FR-106).
///
/// ## Hvorfor der udfyldes så meget på forhånd
///
/// Kontrakten har ingen valgfri felter at tale om: en opgave uden `completion`,
/// uden præcis tre hints eller uden `fictionLabel` er ikke en halvfærdig
/// opgave, den er en ugyldig pakke. Blev felterne udeladt, ville quizmasteren
/// møde fejlen som "serveren afviste" et kvarter senere og et andet sted i
/// appen.
///
/// Værdierne herunder er derfor gyldige og **tydeligt** foreløbige. En tom
/// tekst, quizmasteren overser, er farligere end en, der står og råber.
extension PackDocument {

    /// Lægger en ny opgave og dens sted ind i dokumentet.
    ///
    /// Der gemmes ikke. Opgaven findes kun i telefonen, indtil quizmasteren
    /// trykker Gem — og fortryder hen, er det nok at hente igen.
    /// - Parameter postalCode: postnummeret, den nye opgave lægges under. Er
    ///   det tomt, arves det fra den senest oprettede opgave — quizmasteren
    ///   opretter som regel flere i samme by på én gang.
    /// Titlen er tom med vilje. En forudfyldt "Ny opgave" skal slettes, før
    /// quizmasteren kan skrive sin egen — og det er første ting, hen gør ved
    /// hver eneste opgave.
    ///
    /// Til gengæld skal id'et være unikt fra første øjeblik, og det kan ikke
    /// udledes af en tom titel. Opgaven får derfor et foreløbigt id, som
    /// ``finaliseNewMissionIds()`` skriver om til titlens, første gang den
    /// gemmes.
    func createMission(
        named title: String = "", postalCode: String = ""
    ) -> MissionSummary {
        let slug = uniqueSlug(base: title.isEmpty ? Self.placeholderSlug : title.packSlug)
        let locationId = "loc.\(slug)"
        let code = postalCode.isEmpty ? (lastUsedPostalCode ?? "") : postalCode

        append(newLocation(id: locationId, postalCode: code, name: title),
               to: [.key("locations")])
        append(newMission(slug: slug, locationId: locationId, title: title), to: [.key("missions")])

        let index = objects(at: [.key("missions")]).count - 1
        return MissionSummary(
            index: index,
            id: "mission.\(slug)",
            title: title,
            status: "draft",
            cardCount: 0,
            postalCode: code
        )
    }

    // MARK: - Standardtekster

    /// Hvad der er digtet, og hvad der er virkeligt.
    ///
    /// Kontrakten kræver feltet, og forfatningens princip III kræver, at
    /// spilleren kan se, hvad der er opfundet. Rammen om en opgave er fiktion —
    /// stedet, formerne og årstallene er det ikke, og facit hviler på dem.
    ///
    /// Teksten er den samme for alle opgaver indtil videre. Skal en enkelt
    /// opgave sige noget andet, hører det til i en redigering af pakken.
    static let standardFictionLabel = "Opgavens historie er opdigtet."

    /// Det, spilleren får at se, når gåden er løst.
    ///
    /// Generisk med vilje. En opgave, der siger "Belønningsteksten mangler",
    /// er værre end en, der siger noget rigtigt om alle opgaver.
    static var standardCompletion: [String: Any] {
        [
            "headline": "Gåden er løst",
            "subheadline": "Du fandt svaret dér, hvor det står",
            "messageLabel": "Det, du fandt",
            "message":
                "Svaret lå på stedet hele tiden — i en form, et tal eller en retning, "
                + "der har været der længe før jer, og som bliver stående, når I går "
                + "videre.",
            "historyFact":
                "Hvert sted i byen bærer spor af dem, der byggede det. Kig op næste "
                + "gang I går forbi.",
        ]
    }

    /// Sikkerhed, der gælder alle steder.
    ///
    /// Formuleret som almindelige forholdsregler og **ikke** som en vurdering
    /// af det enkelte sted. Forfatningens princip IV sætter sikkerhed over
    /// spilværdi, og en tekst, der påstod at stedet var gennemgået, ville være
    /// værre end ingen tekst: den ville love noget, ingen havde kontrolleret.
    static let standardSafetyNotes =
        "Bliv på offentligt tilgængelige arealer, og gå ikke ind på privat grund. "
        + "Hold øje med trafik og cyklister, og stil jer et sted, hvor I ikke er i "
        + "vejen. Kig op fra telefonen, når I flytter jer. Stedet er ikke særskilt "
        + "sikkerhedsvurderet."

    /// Udfylder de felter, kontrakten kræver, men ingen redigerer.
    ///
    /// Trinnets `title` vises aldrig for spilleren — kun som reservetekst for
    /// skærmlæseren — og hintenes overskrifter er de samme for alle opgaver.
    /// Begge dele er derfor taget ud af UI'et, og begge dele skal stadig stå i
    /// pakken, ellers er den ugyldig.
    ///
    /// Kaldes lige før en gemning, sammen med ``finaliseNewMissionIds()``.
    func fillRequiredLabels() {
        for mission in objects(at: [.key("missions")]).indices {
            let title = string(at: .mission(mission, .key("title")))
                .trimmingCharacters(in: .whitespacesAndNewlines)

            for step in objects(at: .mission(mission, .key("steps"))).indices {
                let path: [JSONStep] = .mission(mission, .key("steps"), .index(step), .key("title"))
                if string(at: path).isEmpty, !title.isEmpty {
                    setValue(title, at: path)
                }
            }

            // Facit skrives af det første accepterede svar.
            //
            // Feltet findes i kontrakten, men spillerappen bruger det ikke:
            // svarmotoren bedømmer kun mod `acceptedAnswers`, og facit vises
            // ingen steder. To felter, hvor det ene skal være en kopi af en
            // linje i det andet, er to steder at tage fejl.
            for step in objects(at: .mission(mission, .key("steps"))).indices {
                let rule: [JSONStep] = .mission(
                    mission, .key("steps"), .index(step), .key("answerRule"))
                guard value(at: rule) is [String: Any] else { continue }

                let answers = strings(at: rule + [.key("acceptedAnswers")])
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }

                setValue(answers, at: rule + [.key("acceptedAnswers")])
                if let facit = answers.first {
                    setValue(facit, at: rule + [.key("canonicalAnswer")])
                }

                // Cifferkoder sammenlignes som cifre; ellers ville "0592" og
                // "592" være det samme svar. Følger af svartypen og er derfor
                // ikke noget, nogen skal vælge.
                let kind = string(at: .mission(mission, .key("steps"), .index(step), .key("kind")))
                setValue(kind == "numericCode" ? "digitsOnly" : "exact",
                         at: rule + [.key("kind")])
            }

            for hint in objects(at: .mission(mission, .key("hints"))).indices {
                let path: [JSONStep] = .mission(mission, .key("hints"), .index(hint), .key("title"))
                guard string(at: path).isEmpty else { continue }
                let order = integer(
                    at: .mission(mission, .key("hints"), .index(hint), .key("order"))) ?? hint + 1
                setValue(Self.hintTitle(order: order), at: path)
            }
        }
    }

    /// Hintenes overskrifter. Vises som "Hint 1 · Hvor".
    static func hintTitle(order: Int) -> String {
        switch order {
        case 1: "Hvor"
        case 2: "Hvordan"
        default: "Næsten løsningen"
        }
    }

    /// Stammen i et foreløbigt id. Genkendes af ``finaliseNewMissionIds()``.
    static let placeholderSlug = "ny-opgave"

    /// Giver de opgaver, der aldrig er gemt, id'er der følger deres titel.
    ///
    /// Kaldes lige før en gemning. Indtil da hedder en ny opgave
    /// `mission.ny-opgave-3`, og det ville stå sådan for altid — også i
    /// revisionssporet og i filnavnene på dens billeder.
    ///
    /// Det er sikkert at omdøbe her, netop fordi opgaven aldrig har været på
    /// serveren: intet uden for den peger på den, og alt inden i den er noget,
    /// appen selv har skrevet.
    func finaliseNewMissionIds() {
        let saved = Set(
            ((base["missions"] as? [[String: Any]]) ?? []).compactMap { $0["id"] as? String })

        for index in objects(at: [.key("missions")]).indices.reversed() {
            let id = string(at: .mission(index, .key("id")))
            let title = string(at: .mission(index, .key("title")))

            guard !saved.contains(id),
                  id.hasPrefix("mission.\(Self.placeholderSlug)"),
                  !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { continue }

            rename(missionAt: index, to: uniqueSlug(base: title.packSlug))
            nameThePlace(afterMissionAt: index, title: title)
        }
    }

    /// Stedet hedder det samme som opgaven, indtil nogen siger andet.
    ///
    /// Navnet vises for spilleren under "Sted". Uden dette ville hver ny opgave
    /// stå som "Nyt sted", og feltet kan ikke rettes i appen.
    static let placeholderPlaceName = "Nyt sted"

    private func nameThePlace(afterMissionAt index: Int, title: String) {
        guard let position = locationIndex(forMissionAt: index),
              string(at: .location(position, .key("name"))) == Self.placeholderPlaceName
        else { return }
        setValue(title.trimmingCharacters(in: .whitespacesAndNewlines),
                 at: .location(position, .key("name")))
    }

    /// Skriver et foreløbigt id om — og alt, der peger på det.
    private func rename(missionAt index: Int, to slug: String) {
        let oldLocationId = string(at: .mission(index, .key("locationId")))
        let locationId = "loc.\(slug)"

        if let position = objects(at: [.key("locations")])
            .firstIndex(where: { $0["id"] as? String == oldLocationId }) {
            setValue(locationId, at: .location(position, .key("id")))
        }

        setValue("mission.\(slug)", at: .mission(index, .key("id")))
        setValue(slug, at: .mission(index, .key("slug")))
        setValue(locationId, at: .mission(index, .key("locationId")))

        // Hints først: trinnet peger på dem, og rækkefølgen skal holde.
        var hintIds: [String] = []
        for hint in objects(at: .mission(index, .key("hints"))).indices {
            let order = integer(at: .mission(index, .key("hints"), .index(hint), .key("order"))) ?? hint + 1
            let hintId = "hint.\(slug).\(order)"
            setValue(hintId, at: .mission(index, .key("hints"), .index(hint), .key("id")))
            hintIds.append(hintId)
        }

        for step in objects(at: .mission(index, .key("steps"))).indices {
            setValue("step.\(slug).opgaven",
                     at: .mission(index, .key("steps"), .index(step), .key("id")))
            setValue(hintIds, at: .mission(index, .key("steps"), .index(step), .key("hintIds")))
        }

        for card in objects(at: .mission(index, .key("cards"))).indices {
            let order = integer(at: .mission(index, .key("cards"), .index(card), .key("order"))) ?? card + 1
            setValue("card.\(slug).\(order)",
                     at: .mission(index, .key("cards"), .index(card), .key("id")))
        }
    }

    private var lastUsedPostalCode: String? {
        objects(at: [.key("locations")]).last?["postalCode"] as? String
    }

    // MARK: - Skabelonerne

    private func newLocation(id: String, postalCode: String, name: String) -> [String: Any] {
        // Navn og adresse kan ikke rettes i appen længere. De må derfor sige
        // noget, der er sandt fra starten: byen kender vi af postnummeret, og
        // navnet får stedet af opgavens titel, når den bliver gemt.
        let by = Postnumre.city(postalCode)
        return [
            "id": id,
            "postalCode": postalCode,
            // Har opgaven allerede en titel, hedder stedet det samme med det
            // samme. Er den tom — og det er den i appen — sættes navnet af
            // `finaliseNewMissionIds()`, når titlen er skrevet.
            "name": name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? Self.placeholderPlaceName
                : name.trimmingCharacters(in: .whitespacesAndNewlines),
            "address": by ?? "Danmark",
            // Koordinaterne står som null og ikke som 0,0. Nul er et sted i
            // Atlanterhavet, og en opgave, der peger derhen, ser udfyldt ud.
            "latitude": NSNull(),
            "longitude": NSNull(),
            "activationRadiusMetres": 45,
            "maxAcceptableAccuracyMetres": 40,
            "dwellSeconds": 20,
            "accuracyProfile": "standard",
            "publicAccess": true,
            "safety": [
                "flags": [],
                "notes": Self.standardSafetyNotes,
            ],
            "accessibility": [
                "surface": "Ikke opmålt",
                "incline": "Ikke opmålt",
                "steps": false,
                "wheelchair": "unknown",
                "stroller": "unknown",
                "distanceFromAccessMetres": NSNull(),
                "notes": "Tilgængeligheden skal registreres ved feltbesøget.",
            ],
            "fieldVerified": false,
            "lastPhysicallyVerified": NSNull(),
        ]
    }

    private func newMission(slug: String, locationId: String, title: String) -> [String: Any] {
        [
            "id": "mission.\(slug)",
            "slug": slug,
            "locationId": locationId,
            "title": title,
            "shortTitle": title,
            "description": "Beskrivelsen mangler.",
            "status": "draft",
            "difficulty": 3,
            "estimatedMinutes": 15,
            "basePoints": 100,
            "tags": [],
            "fictionLabel": Self.standardFictionLabel,
            "heroMediaId": NSNull(),
            "thumbnailMediaId": NSNull(),
            "placeMediaId": NSNull(),
            "moodMediaId": NSNull(),
            "narrationMediaId": NSNull(),
            // Tom med vilje, og det er en gyldig pakke. Ikke enhver opgave er
            // en bærende opgave — en lille gåde på vejen hen til den næste
            // hviler ikke på noget, der skal dokumenteres.
            "sourceIds": [],
            "steps": [newStep(slug: slug)],
            "hints": (1...3).map { newHint(slug: slug, order: $0) },
            "completion": Self.standardCompletion,
            "cards": [],
            "storyId": NSNull(),
            "chapterId": NSNull(),
            "nextChapterId": NSNull(),
        ]
    }

    /// `freeText` er standarden, fordi den kræver mindst af de tre: `singleChoice`
    /// skal have mindst to svarmuligheder, og de skal opfindes, før nogen har
    /// set stedet.
    private func newStep(slug: String) -> [String: Any] {
        [
            "id": "step.\(slug).opgaven",
            "order": 1,
            "kind": "freeText",
            // Vises aldrig for spilleren. Sættes af `fillRequiredLabels()`
            // ud fra opgavens titel, når den er skrevet.
            "title": "Opgaven",
            "question": "Hvad skal spilleren finde?",
            "placeholder": "Skriv svaret",
            "answerRule": [
                "kind": "exact",
                "canonicalAnswer": "facit",
                "acceptedAnswers": ["facit"],
                "nearMissResponses": [],
            ],
            "hintIds": (1...3).map { "hint.\(slug).\($0)" },
        ]
    }

    private func newHint(slug: String, order: Int) -> [String: Any] {
        [
            "id": "hint.\(slug).\(order)",
            "order": order,
            // 3, 4, 5 — samme trappe som de opgaver, der allerede findes.
            "penaltyPercent": order + 2,
            "title": Self.hintTitle(order: order),
            "text": "Hintet mangler.",
        ]
    }

    // MARK: - Id'er

    /// Et id, der ikke er brugt. To opgaver med samme id gør pakken ugyldig, og
    /// "Ny opgave" trykkes typisk to gange i træk.
    private func uniqueSlug(base: String, prefix: String = "mission.") -> String {
        let taken = Set(missions.map(\.id))
        var candidate = base
        var counter = 2
        while taken.contains(prefix + candidate) {
            candidate = "\(base)-\(counter)"
            counter += 1
        }
        return candidate
    }
}
