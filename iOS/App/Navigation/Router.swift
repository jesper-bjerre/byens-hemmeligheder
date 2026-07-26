import Foundation
import Observation

/// Hvor spilleren kan være.
///
/// Typesikker og `Codable`, ikke en streng. Det er dét, der gør genoptagelse
/// efter fuld terminering til en serialisering af selve stien frem for et sæt
/// løse flag, der skal gættes rigtigt igen (FR-036).
enum Route: Hashable, Codable, Sendable {
    case missionDetail(missionId: String)
    case approach(missionId: String)
    case step(missionId: String, stepId: String)
    case reward(missionId: String)

    var missionId: String {
        switch self {
        case .missionDetail(let id), .approach(let id), .reward(let id):
            id
        case .step(let id, _):
            id
        }
    }
}

/// Navigationsstakken, drevet af `NavigationStack(path:)`.
@Observable
@MainActor
final class Router {

    /// Nøglen i `UserDefaults`. Kun navigation — aldrig progression, som hører
    /// hjemme i hændelsesloggen (research.md R-005).
    private static let restorationKey = "bh.router.path.v1"

    var path: [Route] = []

    /// Vist ark, uafhængigt af stakken.
    var presentedSheet: Sheet?

    enum Sheet: Hashable, Identifiable {
        case hints(missionId: String, stepId: String)
        case presenceProblem(missionId: String)
        case safety(missionId: String)
        case permissionPrimer(missionId: String)

        var id: Self { self }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Navigation

    func push(_ route: Route) {
        path.append(route)
        persist()
    }

    /// Erstatter det øverste trin frem for at lægge et nyt oven på.
    ///
    /// Bruges mellem opgavetrin, så tilbageknappen fører til missionsarket og
    /// ikke gennem hvert eneste trin, spilleren allerede har løst.
    func replaceTop(with route: Route) {
        if path.isEmpty {
            path = [route]
        } else {
            path[path.count - 1] = route
        }
        persist()
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
        persist()
    }

    func popToRoot() {
        path.removeAll()
        persist()
    }

    // MARK: - Genoptagelse

    /// Gemmer stien, så appen kan genoptage på samme trin efter fuld
    /// terminering (FR-036).
    func persist() {
        guard let data = try? JSONEncoder().encode(path) else { return }
        defaults.set(data, forKey: Self.restorationKey)
    }

    /// Genskaber stien. Ruter, der peger på indhold, der ikke længere findes,
    /// kasseres frem for at give en tom skærm.
    func restore(validatingAgainst missionIds: Set<String>) {
        guard let data = defaults.data(forKey: Self.restorationKey),
              let restored = try? JSONDecoder().decode([Route].self, from: data)
        else { return }

        let valid = restored.prefix { missionIds.contains($0.missionId) }
        path = Array(valid)
    }

    func clearRestoration() {
        defaults.removeObject(forKey: Self.restorationKey)
    }
}
