import Foundation

/// Den ene coder, hele projektet bruger.
///
/// Wire-formatet er dyrt at ændre bagefter (research.md R-003), så valgene er
/// samlet her frem for at ligge spredt som argumenter på kaldsteder:
///
/// - **camelCase uden key-konvertering.** ASP.NET Cores default er camelCase.
///   Uden konvertering er Swift-navnet lig med wire-navnet, og det er præcis
///   dét, der giver golden-testen tænder: en omdøbning kan ikke skjule sig bag
///   en nøglestrategi.
/// - **ISO 8601 der også accepterer fraktionelle sekunder.** ASP.NET Core
///   udsender dem; Foundations indbyggede `.iso8601`-strategi fejler på dem.
///   Ét sted, én test.
public enum BHJSON {

    // MARK: - Datoformat

    private static let withFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    private static let withoutFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: false)

    /// Parser ISO 8601 med eller uden fraktionelle sekunder.
    ///
    /// Rækkefølgen er bevidst: fraktionelle sekunder først, fordi det er det,
    /// serveren vil sende, når den findes.
    public static func date(fromISO8601 string: String) -> Date? {
        if let date = try? withFractionalSeconds.parse(string) { return date }
        if let date = try? withoutFractionalSeconds.parse(string) { return date }
        return nil
    }

    /// Formaterer med fraktionelle sekunder, så klient og server skriver ens.
    public static func iso8601String(from date: Date) -> String {
        withFractionalSeconds.format(date)
    }

    // MARK: - Coders

    /// Til afkodning af indholdspakker og hændelseslog.
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = BHJSON.date(fromISO8601: string) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Ikke en gyldig ISO 8601-dato: \(string)"
                )
            }
            return date
        }
        return decoder
    }

    /// Til hændelsesloggen. Kompakt — én hændelse pr. linje.
    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(BHJSON.iso8601String(from: date))
        }
        return encoder
    }

    /// Til golden-filer og andet, et menneske skal læse i en diff.
    ///
    /// `sortedKeys` gør outputtet deterministisk, så en golden-fil kun ændrer
    /// sig, når kontrakten faktisk ændrer sig.
    public static var goldenEncoder: JSONEncoder {
        let encoder = Self.encoder
        encoder.outputFormatting = [.withoutEscapingSlashes, .sortedKeys, .prettyPrinted]
        return encoder
    }
}
