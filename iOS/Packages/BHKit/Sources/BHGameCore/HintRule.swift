import BHContracts
import Foundation

/// Hints åbnes i rækkefølge: hint 2 kan ikke fås før hint 1.
///
/// ## Hvorfor rækkefølgen er en regel og ikke en anbefaling
///
/// Hintstigen er forfattet som *hvor → hvordan → næsten løsningen*, og
/// fradragene stiger med den (3 → 4 → 5 %). Kunne spilleren springe direkte til
/// det tredje, ville stigen falde sammen: hen ville betale 5 % for et svar,
/// hen måske kunne have fundet med et vink på 3. Rækkefølgen beskytter altså
/// spillerens point, ikke opgavens hemmelighed.
public enum HintRule {

    /// Om et hint må åbnes nu.
    ///
    /// Kravet gælder **alle** lavere hints i missionen, ikke kun det
    /// umiddelbart foregående — så et hul i rækken kan ikke opstå.
    public static func isUnlocked(
        _ hint: Hint,
        in hints: [Hint],
        revealed: Set<String>
    ) -> Bool {
        hints
            .filter { $0.order < hint.order }
            .allSatisfy { revealed.contains($0.id) }
    }

    /// Det næste hint, spilleren må åbne. `nil`, når alle er åbnet.
    public static func nextAvailable(in hints: [Hint], revealed: Set<String>) -> Hint? {
        hints
            .sorted { $0.order < $1.order }
            .first { !revealed.contains($0.id) }
    }

    /// Hvilket hint der spærrer for et låst hint — til beskeden på skærmen.
    public static func blocking(
        _ hint: Hint,
        in hints: [Hint],
        revealed: Set<String>
    ) -> Hint? {
        hints
            .filter { $0.order < hint.order && !revealed.contains($0.id) }
            .min { $0.order < $1.order }
    }
}
