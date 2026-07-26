import Foundation

/// Normalisering af spillerens svar før sammenligning.
///
/// ## Hvorfor ikke `folding(options: .diacriticInsensitive)`
///
/// Fordi den er forkert for dansk, og forkert på en måde der først viser sig
/// hos brugeren. `å` folder til `a`, mens `ø` og `æ` opfører sig inkonsistent
/// på tværs af ICU-versioner — så en test, der består på udviklerens Mac, kan
/// fejle på en telefon med en anden iOS-version. Derfor er hvert skridt her
/// eksplicit og unit-testet (research.md R-006).
///
/// Rækkefølgen er en del af kontrakten og er dokumenteret i
/// `contracts/spec/answer-normalization.md`.
public struct DanishTextNormalizer: Sendable {

    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// `æ→ae`, `ø→oe`, `å→aa`. Eksplicit, aldrig via ICU-folding.
        public static let foldDanishLetters = Options(rawValue: 1 << 0)
        /// Fjerner mellemrum inde i svaret — `5 9 2` bliver til `592`.
        public static let stripWhitespace = Options(rawValue: 1 << 1)
        /// Fjerner bindestreger og lignende skilletegn — `5-9-2` bliver til `592`.
        public static let stripSeparators = Options(rawValue: 1 << 2)
        /// Kasserer alt, der ikke er et ciffer.
        public static let digitsOnly = Options(rawValue: 1 << 3)

        /// Til fritekstsvar.
        public static let text: Options = [.foldDanishLetters, .stripWhitespace, .stripSeparators]
        /// Til talkoder. Resultatet sammenlignes som string, aldrig som integer.
        public static let numericCode: Options = [.digitsOnly]
    }

    public init() {}

    public static func normalize(_ input: String, options: Options) -> String {
        var value = input

        // 1. NFC. Samler `a` + combining ring til ét `å`, så senere skridt kan
        //    arbejde på hele tegn frem for på grafem-fragmenter.
        value = value.precomposedStringWithCanonicalMapping

        // 2. Små bogstaver med dansk locale.
        value = value.lowercased(with: Locale(identifier: "da_DK"))

        // 3. Typografiske look-alikes. En telefon med dansk autokorrektur sender
        //    krøllede anførselstegn og tankestreger, som brugeren opfatter som
        //    de tegn, de ligner.
        value = replaceLookAlikes(in: value)

        // 4. Eksplicit dansk foldning. Skal ske efter look-alikes, så `ø` altid
        //    er U+00F8 på dette tidspunkt.
        if options.contains(.foldDanishLetters) {
            value = foldDanishLetters(in: value)
        }

        // 5. Kassér tegn, svaret ikke må afhænge af.
        value = strip(value, options: options)

        // 6. Trim. Sidst, fordi de foregående skridt kan have efterladt kanter.
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Skridtene hver for sig

    /// Erstatninger, hvor et tegn ligner et andet nok til, at brugeren mener
    /// det andet.
    static func replaceLookAlikes(in input: String) -> String {
        var result = String()
        result.reserveCapacity(input.count)

        for character in input {
            switch character {
            // Apostroffer og anførselstegn
            case "\u{2018}", "\u{2019}", "\u{02BC}", "\u{00B4}", "\u{2032}":
                result.append("'")
            case "\u{201C}", "\u{201D}", "\u{2033}":
                result.append("\"")

            // Streger: tanke-, minus- og orddelingsstreger
            case "\u{2010}", "\u{2011}", "\u{2012}", "\u{2013}", "\u{2014}", "\u{2015}", "\u{2212}":
                result.append("-")

            // Mellemrum, der ikke ser ud som mellemrum
            case "\u{00A0}", "\u{2007}", "\u{2009}", "\u{202F}", "\u{3000}":
                result.append(" ")

            // Nul-bredde. Usynlige og altid utilsigtede.
            case "\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}":
                continue

            default:
                // Fuldbredde- og ikke-vestlige cifre skrives om til ASCII, så
                // `５９２` bedømmes som `592`.
                if character.isNumber,
                   let digit = character.wholeNumberValue,
                   (0...9).contains(digit),
                   !character.isASCII {
                    result.append(Character(String(digit)))
                } else {
                    result.append(character)
                }
            }
        }
        return result
    }

    /// De tre danske bogstaver, skrevet ud. Eksplicit tabel, ingen ICU.
    static func foldDanishLetters(in input: String) -> String {
        var result = String()
        result.reserveCapacity(input.count)
        for character in input {
            switch character {
            case "æ": result.append("ae")
            case "ø": result.append("oe")
            case "å": result.append("aa")
            default: result.append(character)
            }
        }
        return result
    }

    static func strip(_ input: String, options: Options) -> String {
        guard !options.isEmpty else { return input }

        if options.contains(.digitsOnly) {
            return String(input.filter { $0.isASCII && $0.isNumber })
        }

        var result = String()
        result.reserveCapacity(input.count)
        for character in input {
            if options.contains(.stripWhitespace), character.isWhitespace { continue }
            if options.contains(.stripSeparators), Self.separators.contains(character) { continue }
            result.append(character)
        }
        return result
    }

    private static let separators: Set<Character> = ["-", "_", ".", ",", "/", "\\", ":", ";"]
}
