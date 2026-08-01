import CoreLocation
import SwiftUI

/// Faneblad 2: stedet.
///
/// Stedet er en egen post i `locations`, som flere opgaver kan dele. Rettes
/// adressen her, rettes den for dem alle — det er meningen, og det står i
/// fanebladet, så ingen opdager det bagefter.
struct PlaceTab: View {
    let document: PackDocument
    let missionIndex: Int
    /// Standardvisningen svarer på to spørgsmål: hvor på listen hører opgaven
    /// til, og hvor står man. Alt andet — stedets navn og adresse,
    /// positionsgatens tal, sikkerhed, tilgængelighed og feltbesøg — ligger
    /// under Avanceret.
    let isAdvanced: Bool

    /// Usikkerheden på den seneste aflæsning. Bruges kun til at advare og
    /// skrives aldrig i pakken — den hører til telefonen, ikke til stedet.
    @State private var lastAccuracy: CLLocationAccuracy?

    /// Landsdelen, postnummerlisten er filtreret efter.
    ///
    /// Den er et **filter** og ikke et felt. Landsdelen gemmes ikke i pakken —
    /// den følger af postnummeret og slås op i ``Postnumre``.
    @State private var region = ""

    private var locationIndex: Int? { document.locationIndex(forMissionAt: missionIndex) }

    var body: some View {
        Group {
            if let index = locationIndex {
                form(index)
            } else {
                VStack(spacing: 16) {
                    Image("EmptyState-ChooseLocation")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 320)
                        .accessibilityHidden(true)
                    Text("Opgaven peger ikke på et sted. `locationId` findes ikke i pakken — "
                         + "ret den i hånden, eller opret opgaven på ny.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
        .onAppear(perform: adoptRegionOfCurrentPlace)
    }

    /// Filteret begynder der, hvor opgaven allerede står.
    private func adoptRegionOfCurrentPlace() {
        guard region.isEmpty, let index = locationIndex else { return }
        let code = document.string(at: .location(index, .key("postalCode")))
        region = Postnumre.region(code) ?? Vocabulary.regions.first ?? ""
    }

    // MARK: - Formularen

    private func form(_ index: Int) -> some View {
        Form {
            area(index)
            position(index)
            if isAdvanced {
                place(index)
                gate(index)
                safety(index)
                accessibility(index)
                fieldVisit(index)
            }
        }
    }

    // MARK: - Hvor opgaven hører til

    /// Landsdel først, postnummer derefter.
    ///
    /// Rækkefølgen er ikke kosmetik. Der er 1089 postnumre i Danmark; en liste,
    /// der ikke er skåret ned til én landsdel først, er ikke til at finde noget
    /// i på en telefon.
    ///
    /// Byen vises, men kan ikke rettes. Den følger af postnummeret, og et felt,
    /// man kan skrive "Vejle Havn" i, gør 7100 til to forskellige steder på
    /// forsiden.
    @ViewBuilder
    private func area(_ index: Int) -> some View {
        let path: [JSONStep] = .location(index, .key("postalCode"))
        let code = document.string(at: path)
        let inRegion = Postnumre.inRegion(region)

        Section {
            Picker("Landsdel", selection: Binding(
                get: { region },
                set: { chosen in
                    region = chosen
                    moveToFirstPlace(in: chosen, unless: code, at: path)
                }
            )) {
                ForEach(Vocabulary.regions, id: \.self) {
                    Text(Vocabulary.regionName($0)).tag($0)
                }
            }

            if inRegion.isEmpty {
                Text("Ingen postnumre i \(Vocabulary.regionName(region)).")
                    .foregroundStyle(.secondary)
            } else {
                Picker("Postnummer", selection: document.text(path)) {
                    ForEach(inRegion) { Text($0.label).tag($0.code) }
                }
            }

            if let city = Postnumre.city(code) {
                LabeledContent("By", value: city)
            } else if !code.isEmpty {
                Label("\(code) er ikke et dansk postnummer", systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
        } header: {
            Text("Hvor på listen")
        } footer: {
            Text("Byen følger af postnummeret og gemmes ikke i opgaven.")
        }
    }

    /// Følger opgaven med over i den nye landsdel.
    ///
    /// Uden dette ville landsdelen sige ét og postnummeret noget andet, og
    /// opgaven ville blive stående under den gamle landsdel på forsiden.
    private func moveToFirstPlace(in region: String, unless current: String, at path: [JSONStep]) {
        let places = Postnumre.inRegion(region)
        guard !places.contains(where: { $0.code == current }), let first = places.first else { return }
        document.setValue(first.code, at: path)
    }

    // MARK: - Stedets navn og adresse

    private func place(_ index: Int) -> some View {
        Section {
            TextField("Navn", text: document.text(.location(index, .key("name"))))
            TextField("Adresse", text: document.text(.location(index, .key("address"))),
                      axis: .vertical)
        } header: {
            Text("Navn og adresse")
        } footer: {
            Text("Flere opgaver kan dele det samme sted. Rettes adressen her, "
                 + "rettes den for dem alle.")
        }
    }

    // MARK: - Position

    @ViewBuilder
    private func position(_ index: Int) -> some View {
        Section {
            LabeledContent("Bredde") {
                TextField("55.7105", text: document.decimalText(.location(index, .key("latitude"))))
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Længde") {
                TextField("9.5575", text: document.decimalText(.location(index, .key("longitude"))))
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
            }

            CurrentPositionButton { coordinate, accuracy in
                document.setValue(coordinate.latitude, at: .location(index, .key("latitude")))
                document.setValue(coordinate.longitude, at: .location(index, .key("longitude")))
                lastAccuracy = accuracy
            }
        } header: {
            Text("Startsted")
        } footer: {
            accuracyNote(index)
        }
    }

    /// Siger fra, når telefonens egen usikkerhed er større end den, opgaven
    /// accepterer. Skrives koordinatet ind alligevel, står gaten og venter på
    /// en præcision, spilleren aldrig får på det sted.
    @ViewBuilder
    private func accuracyNote(_ index: Int) -> some View {
        if let accuracy = lastAccuracy, accuracy > 0 {
            let allowed = document.number(at: .location(index, .key("maxAcceptableAccuracyMetres")))
            let text = "Sidste aflæsning var på ±\(Int(accuracy.rounded())) m."

            if let allowed, accuracy > allowed {
                Text(text + " Det er dårligere end de \(Int(allowed)) m, opgaven accepterer — "
                     + "stå stille et øjeblik, og prøv igen.")
                    .foregroundStyle(.orange)
            } else {
                Text(text)
            }
        } else {
            Text("Stå på stedet, når du trykker. Koordinatet er opgavens startsted "
                 + "og det, gaten måler imod.")
        }
    }

    // MARK: - Gaten

    private func gate(_ index: Int) -> some View {
        Section {
            LabeledContent("Aktiveringsradius") {
                TextField("45", text: document.decimalText(
                    .location(index, .key("activationRadiusMetres"))))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Højeste usikkerhed") {
                TextField("40", text: document.decimalText(
                    .location(index, .key("maxAcceptableAccuracyMetres"))))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            LabeledContent("Ophold") {
                TextField("20", text: document.decimalText(
                    .location(index, .key("dwellSeconds"))))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }
            Picker("Signalforhold",
                   selection: document.choice(.location(index, .key("accuracyProfile")),
                                              fallback: "standard")) {
                ForEach(Vocabulary.accuracyProfiles, id: \.self) {
                    Text(Vocabulary.accuracyProfileName($0)).tag($0)
                }
            }
        } header: {
            Text("Positionsgaten")
        } footer: {
            Text("Højeste usikkerhed skal være mindre end aktiveringsradius. Er den større, "
                 + "kan spilleren låse op uden at være der.")
        }
    }

    // MARK: - Sikkerhed

    @ViewBuilder
    private func safety(_ index: Int) -> some View {
        let path: [JSONStep] = .location(index, .key("safety"), .key("flags"))
        let flags = Set(document.strings(at: path))

        Section {
            Toggle("Offentligt tilgængeligt",
                   isOn: document.flag(.location(index, .key("publicAccess"))))

            ForEach(Vocabulary.safetyFlags, id: \.self) { flag in
                Toggle(Vocabulary.safetyFlagName(flag), isOn: Binding(
                    get: { flags.contains(flag) },
                    set: { isOn in
                        var updated = flags
                        if isOn { updated.insert(flag) } else { updated.remove(flag) }
                        // Kontraktens rækkefølge, ikke klikkenes — ellers ændrer
                        // pakken sig, hver gang nogen slår det samme til og fra.
                        document.setValue(
                            Vocabulary.safetyFlags.filter(updated.contains), at: path)
                    }
                ))
            }

            TextField("Hvad skal der passes på",
                      text: document.text(.location(index, .key("safety"), .key("notes"))),
                      axis: .vertical)
                .lineLimit(3...)
        } header: {
            Text("Sikkerhed")
        } footer: {
            Text("Sikkerhed går forud for spilværdi. Et godt kig fra en farlig ståplads er "
                 + "ikke en opgave.")
        }
    }

    // MARK: - Tilgængelighed

    private func accessibility(_ index: Int) -> some View {
        let path: [JSONStep] = .location(index, .key("accessibility"))

        return Section("Tilgængelighed") {
            TextField("Underlag", text: document.text(path + [.key("surface")]))
            TextField("Hældning", text: document.text(path + [.key("incline")]))
            Toggle("Trapper på vejen", isOn: document.flag(path + [.key("steps")]))

            Picker("Kørestol", selection: document.choice(path + [.key("wheelchair")],
                                                          fallback: "unknown")) {
                ForEach(Vocabulary.accessLevels, id: \.self) {
                    Text(Vocabulary.accessLevelName($0)).tag($0)
                }
            }
            Picker("Barnevogn", selection: document.choice(path + [.key("stroller")],
                                                           fallback: "unknown")) {
                ForEach(Vocabulary.accessLevels, id: \.self) {
                    Text(Vocabulary.accessLevelName($0)).tag($0)
                }
            }

            LabeledContent("Fra nærmeste adgang") {
                TextField("meter",
                          text: document.decimalText(path + [.key("distanceFromAccessMetres")]))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
            }

            TextField("Noter", text: document.text(path + [.key("notes")]), axis: .vertical)
                .lineLimit(3...)
        }
    }

    // MARK: - Feltbesøg

    @ViewBuilder
    private func fieldVisit(_ index: Int) -> some View {
        let path: [JSONStep] = .location(index, .key("lastPhysicallyVerified"))
        let stored = document.string(at: path)

        Section {
            Toggle("Besøgt i felten",
                   isOn: document.flag(.location(index, .key("fieldVerified"))))

            DatePicker(
                "Senest besøgt",
                selection: Binding(
                    get: { Self.day.date(from: stored) ?? .now },
                    set: { document.setValue(Self.day.string(from: $0), at: path) }
                ),
                displayedComponents: .date)

            if !stored.isEmpty {
                Button("Ryd datoen", role: .destructive) {
                    document.setValue(NSNull(), at: path)
                }
            }
        } header: {
            Text("Feltbesøg")
        } footer: {
            Text("Et registreret standpunkt tæller kun, hvis nogen har stået der. "
                 + "Datoen er den eneste, der kan svare på hvornår.")
        }
    }

    /// `YYYY-MM-DD`, som kontrakten skriver datoer uden klokkeslæt.
    private static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

/// Knappen, der indsætter quizmasterens nuværende position (FR-107).
///
/// Hver knap har sin **egen** aflæser. Delte de én, ville et tryk på
/// standpunktets knap også skrive stedets koordinat — begge lytter jo på den
/// samme position, og ingen af dem kan se, hvem der bad om den.
struct CurrentPositionButton: View {
    var title = "Brug min position"
    let onFix: (CLLocationCoordinate2D, CLLocationAccuracy) -> Void

    @State private var gps = LocationProvider()

    var body: some View {
        Button {
            gps.requestOnce()
        } label: {
            HStack {
                Label {
                    Text(title)
                } icon: {
                    Image("Icon-GPS")
                }
                Spacer()
                if gps.isLocating { ProgressView() }
            }
        }
        .disabled(gps.isLocating)
        // Tælleren og ikke koordinatet. To aflæsninger på det samme sted giver
        // den samme værdi, og så ville anden gang ikke skrive noget.
        .onChange(of: gps.fixCount) { _, _ in
            guard let coordinate = gps.coordinate else { return }
            onFix(coordinate, gps.accuracyMetres ?? -1)
        }

        if let failure = gps.failure {
            Text(failure).font(.footnote).foregroundStyle(.red)
        }
    }
}
