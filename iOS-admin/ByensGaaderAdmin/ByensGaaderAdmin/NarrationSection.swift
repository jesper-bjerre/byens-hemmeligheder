import AVFoundation
import SwiftUI
import UniformTypeIdentifiers

/// Opgavens indtalte fortælling: hør den, der ligger, og læg en ny op.
///
/// Fortællingen sætter stemningen og uddyber. Den bærer **aldrig** et spor,
/// teksten ikke også bærer (ADR 0003) — en spiller med høretelefonerne i lommen
/// skal kunne løse opgaven alligevel.
struct NarrationSection: View {
    let document: PackDocument
    let missionIndex: Int

    @State private var player = NarrationPlayer()
    @State private var isImporting = false
    @State private var picked: URL?
    @State private var failure: String?

    private let client = PackClient()

    private var path: [JSONStep] { .mission(missionIndex, .key("narrationMediaId")) }
    private var mediaId: String? {
        let raw = document.string(at: path)
        return raw.isEmpty ? nil : raw
    }
    private var filename: String? { document.filename(forMediaId: mediaId) }

    var body: some View {
        Section {
            if let filename {
                Button {
                    player.toggle(client.url(forMediaNamed: filename))
                } label: {
                    HStack(spacing: 12) {
                        Image("Icon-Audio")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        VStack(alignment: .leading) {
                            Text(player.isPlaying ? "Afspiller …" : "Hør fortællingen")
                            Text(filename).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: player.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                    }
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
            } else if mediaId != nil {
                Label("Fortællingen \(mediaId ?? "") findes ikke i pakken",
                      systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            Button {
                isImporting = true
            } label: {
                Label(filename == nil ? "Læg en fortælling op" : "Erstat fortællingen",
                      systemImage: "waveform.badge.plus")
            }

            if let failure {
                Text(failure).font(.footnote).foregroundStyle(.red)
            }
        } header: {
            Text("Fortælling")
        } footer: {
            Text("Stemning og uddybning — aldrig noget, opgaven ikke kan løses uden. "
                 + "MP3 og andre formater laves om til M4A, før de lægges op.")
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls): picked = urls.first
            case .failure(let error): failure = error.localizedDescription
            }
        }
        .sheet(item: Binding(
            get: { picked.map(PickedAudio.init(url:)) },
            set: { picked = $0?.url }
        )) { audio in
            NarrationUploadSheet(document: document, missionIndex: missionIndex, source: audio.url) {
                document.setValue($0, at: path)
            }
        }
        .onDisappear { player.stop() }
    }
}

private struct PickedAudio: Identifiable {
    let url: URL
    var id: URL { url }
}

/// Afspilning af én fortælling ad gangen.
@Observable
final class NarrationPlayer {
    private(set) var isPlaying = false
    private var player: AVPlayer?
    private var observer: (any NSObjectProtocol)?

    func toggle(_ url: URL) {
        if isPlaying { stop(); return }

        // Uden dette er lyden tavs, når telefonen står på lydløs — og en
        // quizmaster i felten har den altid på lydløs.
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)

        let item = AVPlayerItem(url: url)
        observer = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.stop() }
        }

        player = AVPlayer(playerItem: item)
        player?.play()
        isPlaying = true
    }

    func stop() {
        player?.pause()
        player = nil
        isPlaying = false
        if let observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
}

/// Lægger en fortælling op og registrerer den i pakken.
struct NarrationUploadSheet: View {
    let document: PackDocument
    let missionIndex: Int
    let source: URL
    let onUploaded: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var altText = ""
    @State private var owner = ""
    @State private var licence = ""
    @State private var credit = ""
    @State private var kind = "aiGenerated"
    @State private var manipulation =
        "Syntetisk fortællerstemme. Sætter stemningen og uddyber — alt nødvendigt for at "
        + "løse opgaven står som tekst på skærmen (ADR 0003)."
    @State private var isUploading = false
    @State private var failure: String?

    private let client = PackClient()

    /// Kun to af kontraktens fire slags giver mening for en stemme.
    private static let kinds = ["aiGenerated", "contemporary"]

    private var slug: String {
        let raw = document.string(at: .mission(missionIndex, .key("slug")))
        return raw.isEmpty ? "opgave" : raw
    }
    private var stem: String { "narration-\(slug)" }
    private var number: Int { document.nextMediaNumber(stem: stem) }
    private var filename: String { String(format: "%@-%03d.m4a", stem, number) }
    private var mediaId: String { String(format: "media.narration.%@.%03d", slug, number) }

    private var isComplete: Bool {
        !altText.trimmed.isEmpty && !owner.trimmed.isEmpty
            && !licence.trimmed.isEmpty && !credit.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Valgt fil", value: source.lastPathComponent)
                    LabeledContent("Lægges op som", value: filename)
                } footer: {
                    Text(source.pathExtension.lowercased() == "m4a"
                         ? "Filen er allerede M4A og sendes, som den er."
                         : "Filen laves om til M4A (AAC), før den sendes.")
                }

                Section {
                    TextField("Beskrivelse", text: $altText, axis: .vertical)
                } header: {
                    Text("Hvad høres der")
                } footer: {
                    Text("Skriv den selv. Teksten er det eneste, den, der ikke kan høre "
                         + "fortællingen, får.")
                }

                Section("Rettigheder") {
                    TextField("Ejer", text: $owner)
                    TextField("Licens", text: $licence)
                    TextField("Kredit", text: $credit)
                }

                Section {
                    Picker("Slags", selection: $kind) {
                        ForEach(Self.kinds, id: \.self) {
                            Text(Vocabulary.mediaKindName($0)).tag($0)
                        }
                    }
                    TextField("Hvordan er den lavet", text: $manipulation, axis: .vertical)
                } footer: {
                    Text("En syntetisk stemme må aldrig stå som en ægte optagelse.")
                }

                if let failure {
                    Section { Text(failure).foregroundStyle(.red) }
                }
            }
            .navigationTitle("Ny fortælling")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fortryd") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Læg op", action: upload).disabled(!isComplete || isUploading)
                }
            }
            .overlay { if isUploading { ProgressView().controlSize(.large) } }
        }
    }

    private func upload() {
        isUploading = true
        failure = nil

        // Aflæses **før** kaldet. Bagefter har `nextMediaNumber` talt op, og id
        // og filnavn ville pege hver sin vej.
        let name = filename
        let id = mediaId

        Task {
            do {
                let data = try await AudioConversion.m4aData(from: source)
                try await client.upload(data, filename: name, contentType: "audio/mp4")

                document.addMediaAsset([
                    "id": id,
                    "filename": name,
                    "altText": altText.trimmed,
                    "owner": owner.trimmed,
                    "licence": licence.trimmed,
                    "credit": credit.trimmed,
                    "creditLine": NSNull(),
                    "kind": kind,
                    "mediaType": "audio",
                    "manipulation": manipulation.trimmed.isEmpty
                        ? NSNull() : manipulation.trimmed,
                    "restrictions": NSNull(),
                    "expiresAt": NSNull(),
                ])
                onUploaded(id)
                dismiss()
            } catch {
                failure = error.localizedDescription
            }
            isUploading = false
        }
    }
}

/// Laver enhver lydfil om til M4A.
///
/// ## Hvorfor i appen og ikke på serveren
///
/// Serveren leverer bytes og forstår dem ikke — det er dét, der gør, at
/// kontrakten kan udvides uden en udrulning. En omkodning på serveren ville
/// kræve `ffmpeg` i containeren og gøre den til noget, der skal holdes ved lige.
/// iOS har `AVFoundation` i forvejen.
///
/// ## Hvorfor M4A og ikke MP3
///
/// De fortællinger, der allerede ligger, er `.m4a`, og AAC er det, Apples egen
/// afspiller er bedst til. Ét format i pakken frem for to betyder også, at
/// spillerappen aldrig skal gætte.
enum AudioConversion {

    static func m4aData(from source: URL) async throws -> Data {
        let scoped = source.startAccessingSecurityScopedResource()
        defer { if scoped { source.stopAccessingSecurityScopedResource() } }

        if source.pathExtension.lowercased() == "m4a" {
            return try Data(contentsOf: source)
        }

        let asset = AVURLAsset(url: source)
        guard let session = AVAssetExportSession(
            asset: asset, presetName: AVAssetExportPresetAppleM4A)
        else {
            throw AdminError.message("Lydfilen kunne ikke læses.")
        }

        let destination = URL.temporaryDirectory
            .appending(path: UUID().uuidString)
            .appendingPathExtension("m4a")

        try await session.export(to: destination, as: .m4a)
        defer { try? FileManager.default.removeItem(at: destination) }

        return try Data(contentsOf: destination)
    }
}
