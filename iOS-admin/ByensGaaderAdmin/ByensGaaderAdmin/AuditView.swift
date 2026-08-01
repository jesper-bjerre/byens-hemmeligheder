import SwiftUI

/// Sporet over hvem der ændrede hvad hvornår (FR-111).
///
/// Det står her og ikke inde i den enkelte opgave, fordi spørgsmålet sjældent
/// er "hvad skete der med denne opgave" og næsten altid "hvem flyttede noget i
/// går". Sporet kan kun læses; det skrives af serveren ved hver gemning.
struct AuditView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var entries: [AuditEntry] = []
    @State private var failure: String?
    @State private var isLoading = true

    private let client = PackClient()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if let failure {
                    ContentUnavailableView("Sporet kunne ikke hentes", systemImage: "wifi.slash",
                                           description: Text(failure))
                } else if entries.isEmpty {
                    ContentUnavailableView("Intet er rettet endnu", systemImage: "clock")
                } else {
                    List(entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(headline(entry))
                            if let detail = detail(entry) {
                                Text(detail).font(.subheadline).foregroundStyle(.secondary)
                            }
                            Text(entry.at.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
            .navigationTitle("Hvem har rettet hvad")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Luk") { dismiss() }
                }
            }
            .task(load)
        }
    }

    private func headline(_ entry: AuditEntry) -> String {
        let what = entry.missionId ?? "pakken"
        return "\(entry.by) \(Vocabulary.changeName(entry.change)) \(what)"
    }

    private func detail(_ entry: AuditEntry) -> String? {
        switch (entry.from, entry.to) {
        case let (from?, to?):
            "\(Vocabulary.statusName(from)) → \(Vocabulary.statusName(to))"
        case let (nil, to?):
            "Ny som \(Vocabulary.statusName(to))"
        case let (from?, nil):
            "Var \(Vocabulary.statusName(from))"
        default:
            nil
        }
    }

    @Sendable
    private func load() async {
        isLoading = true
        do {
            entries = try await client.audit()
            failure = nil
        } catch {
            failure = error.localizedDescription
        }
        isLoading = false
    }
}
