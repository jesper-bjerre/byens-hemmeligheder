import Foundation

/// Kontraktens engelske wire-værdier oversat til dansk (FR-104).
///
/// Oversættelsen bor **kun** her og aldrig i pakken. Kontraktens værdier er
/// wire-navne, som spillerappen og serveren er enige om; skrev editoren
/// "Frigivet" i `status`, ville pakken være ulæselig for alt andet end denne
/// app.
///
/// Ukendte værdier gives tilbage uændret i stedet for at blive skjult. En pakke
/// kan være nyere end appen, og en status, quizmasteren ikke kan se, er værre
/// end en, hen ikke kan oversætte.
enum Vocabulary {

    // MARK: - Opgavens status

    /// De tre statusser, en quizmaster bruger i den almindelige arbejdsgang.
    /// De engelske værdier er kontraktens wire-navne og må ikke oversættes i
    /// den gemte pakke.
    static let statuses = ["draft", "fieldTestReady", "publishReady"]

    /// Valgene for en opgave, der står i `raw` netop nu.
    static func statusChoices(current raw: String) -> [String] {
        statuses.contains(raw) || raw.isEmpty ? statuses : statuses + [raw]
    }

    static func statusName(_ raw: String) -> String {
        switch raw {
        case "draft": "Kladde"
        case "researchReady": "Research på plads"
        case "fieldTestReady": "Klar til udgivelse"
        case "publishReady": "Frigivet"
        case "paused": "På pause"
        default: raw
        }
    }

    // MARK: - Landsdele

    static let regions = [
        "byenKoebenhavn", "koebenhavnsOmegn", "nordsjaelland", "bornholm",
        "oestsjaelland", "vestOgSydsjaelland", "fyn", "sydjylland",
        "oestjylland", "vestjylland", "nordjylland",
    ]

    static func regionName(_ raw: String) -> String {
        switch raw {
        case "byenKoebenhavn": "Byen København"
        case "koebenhavnsOmegn": "Københavns omegn"
        case "nordsjaelland": "Nordsjælland"
        case "bornholm": "Bornholm"
        case "oestsjaelland": "Østsjælland"
        case "vestOgSydsjaelland": "Vest- og Sydsjælland"
        case "fyn": "Fyn"
        case "sydjylland": "Sydjylland"
        case "oestjylland": "Østjylland"
        case "vestjylland": "Vestjylland"
        case "nordjylland": "Nordjylland"
        case "": "Uden landsdel"
        default: raw
        }
    }

    // MARK: - Spørgsmålet

    static let stepKinds = ["singleChoice", "numericCode", "freeText"]

    static func stepKindName(_ raw: String) -> String {
        switch raw {
        case "singleChoice": "Vælg blandt svar"
        case "numericCode": "Talkode"
        case "freeText": "Fritekst"
        case "narrative": "Fortælling"
        default: raw
        }
    }

    static let answerKinds = ["exact", "digitsOnly"]

    static func answerKindName(_ raw: String) -> String {
        switch raw {
        case "exact": "Nøjagtig tekst"
        case "digitsOnly": "Kun cifre"
        default: raw
        }
    }

    // MARK: - Stedet

    static let safetyFlags = [
        "traffic", "water", "steepSlope", "darkness",
        "privateProperty", "cyclePath", "construction", "crowding",
    ]

    static func safetyFlagName(_ raw: String) -> String {
        switch raw {
        case "traffic": "Trafik"
        case "water": "Åbent vand"
        case "steepSlope": "Stejl skråning"
        case "darkness": "Mørke"
        case "privateProperty": "Privat grund"
        case "cyclePath": "Cykelsti"
        case "construction": "Byggeplads"
        case "crowding": "Mange mennesker"
        default: raw
        }
    }

    static let accessLevels = ["yes", "partial", "no", "unknown"]

    static func accessLevelName(_ raw: String) -> String {
        switch raw {
        case "yes": "Ja"
        case "partial": "Delvist"
        case "no": "Nej"
        case "unknown": "Ikke opmålt"
        default: raw
        }
    }

    static let accuracyProfiles = ["standard", "urbanCanyon"]

    static func accuracyProfileName(_ raw: String) -> String {
        switch raw {
        case "standard": "Almindeligt"
        case "urbanCanyon": "Mellem høje huse"
        default: raw
        }
    }

    // MARK: - Medier

    static let mediaKinds = ["historical", "contemporary", "aiGenerated", "enhanced"]

    static func mediaKindName(_ raw: String) -> String {
        switch raw {
        case "historical": "Historisk fotografi"
        case "contemporary": "Nutidigt foto"
        case "aiGenerated": "AI-genereret"
        case "enhanced": "Ægte foto, bearbejdet"
        default: raw
        }
    }

    // MARK: - Sporet over ændringer

    static func changeName(_ raw: String) -> String {
        switch raw {
        case "status": "flyttede status"
        case "created": "oprettede"
        case "removed": "fjernede"
        case "content": "rettede indhold"
        default: raw
        }
    }
}

extension String {

    /// Gør en dansk titel til et id, kontrakten accepterer.
    ///
    /// Mønsteret er `^[a-z0-9]+([._-][a-z0-9]+)*$`, så æ, ø og å skal skrives
    /// om og ikke blot fjernes: "Bølgen" og "Blgen" er to forskellige ord, og
    /// det er quizmasteren, der skal kunne genkende sit eget id bagefter.
    var packSlug: String {
        let folded = lowercased()
            .replacingOccurrences(of: "æ", with: "ae")
            .replacingOccurrences(of: "ø", with: "oe")
            .replacingOccurrences(of: "å", with: "aa")
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "da-DK"))

        let allowed: [Character] = folded.map { character in
            character.isASCII && (character.isLetter || character.isNumber)
                ? character
                : Character(" ")
        }
        let parts = allowed.split(separator: Character(" ")).map { String($0) }

        let slug = parts.joined(separator: "-")
        // Et tomt id ville blive afvist af skemaet uden at sige hvorfor.
        return slug.isEmpty ? "uden-navn" : slug
    }
}
