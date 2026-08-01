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
    func createMission(
        named title: String = "Ny opgave", postalCode: String = ""
    ) -> MissionSummary {
        let slug = uniqueSlug(base: title.packSlug)
        let locationId = "loc.\(slug)"
        let code = postalCode.isEmpty ? (lastUsedPostalCode ?? "") : postalCode

        append(newLocation(id: locationId, postalCode: code), to: [.key("locations")])
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

    private var lastUsedPostalCode: String? {
        objects(at: [.key("locations")]).last?["postalCode"] as? String
    }

    // MARK: - Skabelonerne

    private func newLocation(id: String, postalCode: String) -> [String: Any] {
        [
            "id": id,
            "postalCode": postalCode,
            "name": "Nyt sted",
            "address": "Adresse mangler",
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
                "notes": "Sikkerheden er ikke vurderet endnu. Skriv, hvad der skal passes på.",
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
            "fictionLabel": "Fiktionsmarkeringen mangler.",
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
            "completion": [
                "headline": "Løst",
                "subheadline": "Belønningsteksten mangler.",
                "messageLabel": "Beskeden",
                "message": "Beskeden mangler.",
                "historyFact": "Den historiske forklaring mangler.",
            ],
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
            "title": "Spørgsmålet mangler",
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
            "title": ["Hvor", "Hvordan", "Næsten løsningen"][order - 1],
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
