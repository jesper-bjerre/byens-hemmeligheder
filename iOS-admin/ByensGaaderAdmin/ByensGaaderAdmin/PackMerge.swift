import Foundation

/// Fletter to quizmasteres rettelser sammen.
///
/// ## Hvorfor det ikke er nok at hente igen
///
/// `If-Match` sikrer, at ingen overskriver en anden i tavshed — serveren svarer
/// `412`, og det er den rigtige halvdel af løsningen. Den anden halvdel manglede:
/// beskeden "hent igen, og læg dine rettelser oveni" beder quizmasteren om at
/// smide sit eget arbejde væk og taste det igen efter hukommelsen.
///
/// Mod én maskine på skrivebordet sker det aldrig. Med fem quizmastere på en
/// fælles server sker det hver uge.
///
/// ## Trevejs og ikke tovejs
///
/// Fletningen kender tre udgaver:
///
/// - **basis** — pakken, som den så ud, da quizmasteren hentede den
/// - **vores** — den samme pakke med hens rettelser i
/// - **deres** — det, der ligger på serveren nu
///
/// Uden basis kan man ikke se forskel på "jeg har ændret dette felt" og "jeg har
/// ikke rørt det". En tovejsfletning ville derfor skrive alle vores urørte
/// felter tilbage oven i den andens arbejde — præcis det, `If-Match` findes for
/// at forhindre.
///
/// ## Hvad der sker ved en ægte konflikt
///
/// Har begge rettet **det samme felt** til noget forskelligt, vinder vores — og
/// feltet står på listen over konflikter. Det er valgt sådan, fordi den, der
/// står med telefonen lige nu, er den eneste, der kan tage stilling. Men det må
/// aldrig ske i tavshed, og derfor er listen ikke til at overse.
enum PackMerge {

    struct Result {
        let root: [String: Any]
        /// Stier, hvor begge havde rettet forskelligt. Vores værdi står, men
        /// quizmasteren får dem at se.
        let conflicts: [String]

        var hasConflicts: Bool { !conflicts.isEmpty }
    }

    static func merge(
        base: [String: Any], ours: [String: Any], theirs: [String: Any]
    ) -> Result {
        var conflicts: [String] = []
        let merged = mergeValue(
            base: base, ours: ours, theirs: theirs, path: "", conflicts: &conflicts)
        return Result(root: merged as? [String: Any] ?? ours, conflicts: conflicts)
    }

    // MARK: - Selve fletningen

    private static func mergeValue(
        base: Any?, ours: Any?, theirs: Any?, path: String, conflicts: inout [String]
    ) -> Any? {
        // De tre billige svar først. Rækkefølgen er ikke ligegyldig: har ingen
        // af os rørt feltet, er alle tre ens, og så er der intet at gøre.
        if equal(ours, theirs) { return ours }
        if equal(ours, base) { return theirs }
        if equal(theirs, base) { return ours }

        // Begge har ændret noget. Er det objekter, ligger uenigheden måske
        // dybere nede, og så er der stadig noget at redde.
        if let baseObject = base as? [String: Any],
           let ourObject = ours as? [String: Any],
           let theirObject = theirs as? [String: Any] {
            return mergeObjects(
                base: baseObject, ours: ourObject, theirs: theirObject,
                path: path, conflicts: &conflicts)
        }

        if let baseArray = base as? [Any],
           let ourArray = ours as? [Any],
           let theirArray = theirs as? [Any],
           isIdentified(baseArray) || isIdentified(ourArray) {
            return mergeIdentifiedArrays(
                base: baseArray, ours: ourArray, theirs: theirArray,
                path: path, conflicts: &conflicts)
        }

        // Blade og lister uden id — fx `tags` eller `acceptedAnswers`. De kan
        // ikke flettes meningsfuldt element for element, så de behandles som én
        // værdi.
        conflicts.append(path.isEmpty ? "pakken" : path)
        return ours
    }

    private static func mergeObjects(
        base: [String: Any], ours: [String: Any], theirs: [String: Any],
        path: String, conflicts: inout [String]
    ) -> [String: Any] {
        var merged: [String: Any] = [:]

        for key in Set(base.keys).union(ours.keys).union(theirs.keys).sorted() {
            let childPath = path.isEmpty ? key : "\(path).\(key)"
            let inBase = base[key], inOurs = ours[key], inTheirs = theirs[key]

            // Fjernelser. Har den ene fjernet nøglen og den anden ikke rørt
            // den, står fjernelsen ved magt.
            if inOurs == nil, equal(inTheirs, inBase) { continue }
            if inTheirs == nil, equal(inOurs, inBase) { continue }

            if let value = mergeValue(
                base: inBase, ours: inOurs, theirs: inTheirs,
                path: childPath, conflicts: &conflicts) {
                merged[key] = value
            }
        }

        return merged
    }

    /// Lister af objekter med `id` — opgaver, steder, kort, hints, medier.
    ///
    /// Flettes på id og ikke på plads. To quizmastere, der hver tilføjer en
    /// opgave, ville ellers begge skrive på plads nummer fem, og den ene ville
    /// forsvinde.
    private static func mergeIdentifiedArrays(
        base: [Any], ours: [Any], theirs: [Any],
        path: String, conflicts: inout [String]
    ) -> [Any] {
        let baseById = byId(base), ourById = byId(ours)
        var merged: [Any] = []
        var taken = Set<String>()

        // Deres rækkefølge er udgangspunktet — den ligger allerede på serveren.
        for element in theirs {
            guard let id = identifier(element) else { continue }
            taken.insert(id)

            let inBase = baseById[id], inOurs = ourById[id]

            // Vi har slettet den, og de har ikke rørt den.
            if inOurs == nil, inBase != nil, equal(element, inBase) { continue }

            if let value = mergeValue(
                base: inBase, ours: inOurs ?? element, theirs: element,
                path: "\(path)[\(id)]", conflicts: &conflicts) {
                merged.append(value)
            }
        }

        // Det, vi selv har tilføjet, kommer bagest — og det, de har slettet,
        // men vi har rettet, følger med, så en rettelse aldrig forsvinder.
        for element in ours {
            guard let id = identifier(element), !taken.contains(id) else { continue }
            if let inBase = baseById[id] {
                // De slettede den. Har vi rettet i den, er det en konflikt.
                if equal(element, inBase) { continue }
                conflicts.append("\(path)[\(id)] — slettet af en anden, men rettet af dig")
            }
            merged.append(element)
        }

        return merged
    }

    // MARK: - Småting

    private static func isIdentified(_ array: [Any]) -> Bool {
        !array.isEmpty && array.allSatisfy { identifier($0) != nil }
    }

    private static func identifier(_ element: Any?) -> String? {
        (element as? [String: Any])?["id"] as? String
    }

    private static func byId(_ array: [Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        for element in array {
            if let id = identifier(element) { result[id] = element }
        }
        return result
    }

    /// Sammenligner to JSON-værdier.
    ///
    /// `NSObject.isEqual` klarer tal, strenge, `NSNull`, arrays og dictionaries,
    /// fordi `JSONSerialization` leverer dem alle som Foundation-objekter. En
    /// egen rekursiv sammenligning ville kun være en dårligere kopi.
    private static func equal(_ left: Any?, _ right: Any?) -> Bool {
        switch (left, right) {
        case (nil, nil): true
        case (nil, _), (_, nil): false
        default: (left as AnyObject).isEqual(right as AnyObject)
        }
    }
}
