import SwiftUI
import UniformTypeIdentifiers

/// Valg og upload af opgavens indtalte fortælling.
///
/// Filvælgeren må vise alle lydfiler. Serveren er den fælles sandhed om de
/// konkrete formater og gør dem til den samme lille MP3, før pakken peger på
/// dem med `narrationMediaId`.
struct NarrationUploadSection: View {
    let document: PackDocument
    let missionIndex: Int

    @State private var showsImporter = false
    @State private var isUploading = false
    @State private var selectedName: String?
    @State private var failure: String?

    private let client = PackClient()

    private var narrationPath: [JSONStep] {
        .mission(missionIndex, .key("narrationMediaId"))
    }

    private var narrationId: String? {
        let value = document.value(at: narrationPath)
        return value is NSNull ? nil : value as? String
    }

    private var filename: String? { document.filename(forMediaId: narrationId) }

    private var stem: String {
        let slug = document.string(at: .mission(missionIndex, .key("slug")))
        return "narration-" + (slug.isEmpty ? "opgave" : slug)
    }

    var body: some View {
        Section {
            if let filename {
                LabeledContent("Aktuel fil", value: filename)
            }

            Button {
                showsImporter = true
            } label: {
                Label(filename == nil ? "Vælg lydfil" : "Vælg en ny lydfil",
                      systemImage: "waveform.badge.plus")
            }
            .disabled(isUploading)

            if let selectedName {
                LabeledContent("Valgt", value: selectedName)
            }

            if isUploading {
                HStack {
                    ProgressView()
                    Text("Gør fortællingen klar…")
                }
            }

            if filename != nil {
                Button("Fjern fra opgaven", role: .destructive) {
                    document.setValue(NSNull(), at: narrationPath)
                    selectedName = nil
                    failure = nil
                }
                .disabled(isUploading)
            }

            if let failure {
                Text(failure).foregroundStyle(.red)
            }
        } header: {
            Text("Indtalt fortælling")
        } footer: {
            Text("MP3, M4A, AAC, WAV, AIFF, CAF, OGG, Opus og FLAC understøttes. "
                 + "Serveren gør filen til en kompakt MP3, som virker i både appen og browseren.")
        }
        .fileImporter(isPresented: $showsImporter, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url):
                importAudio(url)
            case .failure(let error):
                failure = error.localizedDescription
            }
        }
    }

    private func importAudio(_ url: URL) {
        let hasAccess = url.startAccessingSecurityScopedResource()
        defer { if hasAccess { url.stopAccessingSecurityScopedResource() } }

        do {
            let data = try Data(contentsOf: url)
            selectedName = url.lastPathComponent
            upload(data, sourceExtension: url.pathExtension.lowercased())
        } catch {
            failure = "Lydfilen kunne ikke læses: \(error.localizedDescription)"
        }
    }

    private func upload(_ data: Data, sourceExtension: String) {
        let number = document.nextMediaNumber(stem: stem)
        let filename = String(format: "%@-%03d.mp3", stem, number)
        let mediaId = String(format: "media.%@.%03d", stem, number)
        let title = document.string(at: .mission(missionIndex, .key("title")))

        isUploading = true
        failure = nil

        Task {
            do {
                try await client.uploadNarration(
                    data, filename: filename, sourceExtension: sourceExtension)
                document.addMediaAsset([
                    "id": mediaId,
                    "filename": filename,
                    "altText": "Fortælling til \(title)",
                    "owner": "Byens Gåder",
                    "licence": "Eget materiale — Byens Gåder ejer rettighederne",
                    "credit": "Byens Gåder",
                    "creditLine": NSNull(),
                    "kind": "contemporary",
                    "mediaType": "audio",
                    "manipulation": "Konverteret til MP3, mono, 64 kbit/s",
                    "restrictions": NSNull(),
                    "expiresAt": NSNull(),
                ])
                document.setValue(mediaId, at: narrationPath)
                selectedName = nil
            } catch {
                failure = PackClient.describe(error)
            }
            isUploading = false
        }
    }
}
