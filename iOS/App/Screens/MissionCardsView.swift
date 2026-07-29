import BHContracts
import BHDesignSystem
import SwiftUI

/// Ét kort: et billede i fuld bredde med lidt tekst hen over bunden.
///
/// ## Billedet er det primære
///
/// Teksten ligger **over** billedets nederste kant med en blød mørk overgang.
/// Det er dét, der får bunken til at ligne kort fra et brætspil frem for en
/// artikel med billedtekster.
///
/// ## Derfor er teksten kort
///
/// Overlayet kan kun bære det, der er plads til over billedets kant. En lang
/// tekst blev klippet — først usynligt, indtil tilgængelighedsauditten afviste
/// den ved de store skriftstørrelser. Det er ikke en fejl i layoutet: et kort i
/// et brætspil bærer heller ikke fem afsnit.
///
/// Løsningen ligger derfor i indholdet. Er teksten for lang til ét kort, deles
/// den over flere — se ``MissionShape/maximumCardTextLength``. Quizmasteren
/// leverer et foto pr. kort; indtil da genbruges opgavens billede.
struct MissionCardView: View {
    let card: MissionCard
    let onZoom: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            if let mediaId = card.mediaId {
                // Fuld bredde, højden følger billedforholdet.
                //
                // Der stod før en fast højde her. Sammen med `scaledToFit`
                // betød det, at billedet blev passet ind i højden og endte
                // **smallere** end skærmen — med luft i siderne, mens
                // tekstoverlayet gik ud til kanten. Højden er ligegyldig:
                // spilleren ruller.
                MissionHeroImage(mediaId: mediaId, fillsWidth: true, isSquared: true)
            }

            if !card.text.isEmpty {
                Text(card.text)
                    .font(BHFont.body)
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(BHSpacing.regular)
                    .background(alignment: .bottom) {
                        // En blød overgang. En hård kant ville ligne et sort
                        // felt klistret på billedet.
                        LinearGradient(
                            colors: [.black.opacity(0), .black.opacity(0.6), .black.opacity(0.88)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: BHRadius.card, style: .continuous))
        .onTapGesture(perform: onZoom)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tryk for at forstørre billedet")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("card.\(card.id)")
    }
}

/// Kortet i fuld skærm, hvor det kan forstørres.
///
/// ## Hvorfor zoom ikke er en luksus
///
/// Kortene kan bære detaljer, der er skrevet eller vist småt — en indskrift, et
/// husnummer, et skilt i baggrunden. På en telefon i sollys er de ulæselige i
/// den størrelse, et kort i en bunke har. Uden zoom ville gåden i praksis
/// afhænge af, hvor godt man ser.
struct MissionCardZoomView: View {
    let card: MissionCard
    let onClose: () -> Void

    @State private var scale: CGFloat = 1
    @State private var committedScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero

    private static let maxScale: CGFloat = 6

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let mediaId = card.mediaId {
                MissionHeroImage(mediaId: mediaId, fillsWidth: true, isZoomable: true)
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(magnification.simultaneously(with: drag))
                    // Dobbelttryk frem og tilbage. Hurtigere end at knibe, og
                    // det eneste, der virker med én hånd.
                    .onTapGesture(count: 2) {
                        withAnimation(.snappy) {
                            let zoomedIn = committedScale > 1
                            scale = zoomedIn ? 1 : 3
                            committedScale = scale
                            offset = .zero
                            committedOffset = .zero
                        }
                    }
                    .accessibilityIdentifier("card.zoom.image")
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(BHFont.heading)
                            .foregroundStyle(.white)
                            .padding(BHSpacing.snug)
                            .background(Circle().fill(.black.opacity(0.45)))
                    }
                    .accessibilityLabel("Luk billedet")
                    .accessibilityIdentifier("card.zoom.close")
                }
                Spacer()
            }
            .padding(BHSpacing.regular)
        }
        .statusBarHidden()
    }

    private var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                scale = min(max(1, committedScale * value.magnification), Self.maxScale)
            }
            .onEnded { _ in
                committedScale = scale
                if scale <= 1 {
                    withAnimation(.snappy) {
                        offset = .zero
                        committedOffset = .zero
                    }
                }
            }
    }

    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                // Der kan kun flyttes rundt, når der er zoomet ind. Ellers ville
                // billedet glide væk fra midten uden grund.
                guard committedScale > 1 else { return }
                offset = CGSize(
                    width: committedOffset.width + value.translation.width,
                    height: committedOffset.height + value.translation.height
                )
            }
            .onEnded { _ in committedOffset = offset }
    }
}
