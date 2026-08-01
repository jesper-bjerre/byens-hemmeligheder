import PhotosUI
import SwiftUI
import UIKit

/// Kameraet. `PhotosPicker` dækker biblioteket, men ikke optagelsen, og
/// quizmasteren står på stedet med motivet foran sig.
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {
        private let onCapture: (UIImage) -> Void

        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage { onCapture(image) }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

/// Viser et billede fra serveren.
///
/// Hentes med den samme adresse, spillerappen bruger. Ser quizmasteren noget
/// andet end spilleren, opdages en forkert `mediaId` aldrig herinde.
struct MediaThumbnail: View {
    let filename: String
    var height: CGFloat = 160

    private let client = PackClient()

    var body: some View {
        AsyncImage(url: client.url(forMediaNamed: filename)) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFit()
            case .failure:
                Label("Billedet kunne ikke hentes", systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            default:
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: height)
    }
}

/// Lægger et nyt billede op og registrerer det i pakken (FR-108).
///
/// ## Rettighedskæden udfyldes her og ikke bagefter
///
/// Ejer, licens og kredit er påkrævede felter i kontrakten, fordi forfatningens
/// princip IV sætter rettigheder over spilværdi. Udfyldes de "senere", er
/// billedet allerede lagt op, og så er der ingen, der gør det.
struct MediaUploadSheet: View {
    let document: PackDocument
    /// Stammen i filnavnet — stedets navn, ikke opgavens. Billeder af Bølgen
    /// hedder `boelgen-000`, uanset hvilken opgave der bruger dem.
    let stem: String
    /// Kaldes med det nye mediets id, når det ligger på serveren.
    let onUploaded: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var image: UIImage?
    @State private var photo: PhotosPickerItem?
    @State private var showsCamera = false

    @State private var altText = ""
    @State private var isUploading = false
    @State private var failure: String?

    private let client = PackClient()

    private var number: Int { document.nextMediaNumber(stem: stem) }
    private var filename: String { String(format: "%@-%03d.jpg", stem, number) }
    private var mediaId: String { String(format: "media.%@.%03d", stem, number) }

    /// Hvad der mangler, sagt i klartekst.
    ///
    /// En grå knap uden begrundelse er ikke en spærring, det er en gåde — og
    /// quizmasteren står i felten og kan ikke se, om det er en fejl i appen.
    private var missing: String? {
        if image == nil { return "Vælg et billede." }
        if altText.trimmed.isEmpty { return "Skriv en beskrivelse af billedet." }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Billedet") {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                    }

                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            showsCamera = true
                        } label: {
                            Label("Tag et billede", systemImage: "camera")
                        }
                    }

                    PhotosPicker(selection: $photo, matching: .images) {
                        Label("Vælg fra biblioteket", systemImage: "photo.on.rectangle")
                    }

                }

                Section {
                    TextField("Hvad ser man på billedet", text: $altText, axis: .vertical)
                        .lineLimit(2...)
                } header: {
                    Text("Beskrivelse")
                } footer: {
                    Text("Skriv den selv. Teksten læses højt for den, der ikke kan se "
                         + "billedet, og et genereret forsøg beskriver som regel noget "
                         + "andet end motivet.")
                }

                if let missing {
                    Section {
                        Label(missing, systemImage: "exclamationmark.circle")
                            .foregroundStyle(.secondary)
                    }
                }

                if let failure {
                    Section {
                        Text(failure).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Nyt billede")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fortryd") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Læg op", action: upload)
                        .disabled(missing != nil || isUploading)
                }
            }
            .fullScreenCover(isPresented: $showsCamera) {
                CameraPicker { image = $0 }
                    .ignoresSafeArea()
            }
            .onChange(of: photo) { _, item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        image = UIImage(data: data)
                    }
                }
            }
            .overlay {
                if isUploading { ProgressView().controlSize(.large) }
            }
        }
    }

    private func upload() {
        guard let image, let data = Self.jpeg(from: image) else {
            failure = "Billedet kunne ikke gøres til en JPEG."
            return
        }

        isUploading = true
        failure = nil

        // Filnavnet aflæses **før** kaldet. Bagefter har `nextMediaNumber` talt
        // op, og id og filnavn ville pege hver sin vej.
        let name = filename
        let id = mediaId

        Task {
            do {
                try await client.upload(data, filename: name, contentType: "image/jpeg")

                document.addMediaAsset([
                    "id": id,
                    "filename": name,
                    "altText": altText.trimmed,
                    // Rettighedskæden udfyldes af sig selv, fordi svaret er
                    // kendt: quizmasteren tog billedet med sin egen telefon
                    // for et par sekunder siden. Felterne er stadig i pakken —
                    // kontrakten kræver dem, og forfatningens princip IV sætter
                    // rettigheder over spilværdi. Men det er ikke et spørgsmål,
                    // der skal stilles fem gange pr. opgave.
                    "owner": AdminConfiguration.quizmaster,
                    "licence": "Eget materiale — Byens Gåder ejer rettighederne",
                    "credit": "Byens Gåder",
                    "creditLine": NSNull(),
                    // Et nutidigt foto. Hverken historisk, bearbejdet eller
                    // AI-genereret — og derfor er der intet at spørge om.
                    "kind": "contemporary",
                    "mediaType": "image",
                    "manipulation": NSNull(),
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

extension MediaUploadSheet {

    /// Den længste side, et billede lægges op i.
    ///
    /// Et telefonfoto er 12 megapixel og 4–8 MB. Serveren afviser over 10, og
    /// over mobilnet ved Bølgen tager de sidste megabyte længere end
    /// quizmasteren gider vente — uden at billedet bliver bedre af det. 2048 px
    /// er stadig skarpere end nogen telefonskærm viser det på.
    static let maxPixels: CGFloat = 2048

    static func jpeg(from image: UIImage) -> Data? {
        downscaled(image).jpegData(compressionQuality: 0.85)
    }

    static func downscaled(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxPixels else { return image }

        let scale = maxPixels / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat.default()
        // 1.0, ellers ganger renderen op med skærmens skala igen, og
        // nedskaleringen ville være uden virkning.
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
