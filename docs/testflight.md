# TestFlight — fra kode til quizmasterens telefon

Vejledning til at få **Byens Gåder** ud til quizmasterne. Skrevet til intern
test, hvor der ikke er nogen review hos Apple.

**Bundle-id:** `dk.hyldenbrandt.byensgaader`
**Team:** `QHL89A7A8J`

---

## 0. Intern eller ekstern test?

Vælg **intern**. Forskellen er ikke kosmetisk:

| | Intern | Ekstern |
|---|---|---|
| Antal testere | 100 | 10.000 |
| Review hos Apple | **Nej** | Ja, af første build i hver version |
| Ventetid | Minutter efter upload | Timer til dage |
| Krav til testeren | Skal være bruger i dit App Store Connect-team | Kun en mailadresse |

Til fem quizmastere er intern test hurtigere, og ingen hos Apple åbner appen.

---

## 1. Registrér bundle-id'et (kun første gang)

Xcode plejer at gøre det selv, men kontrollér det:

1. [developer.apple.com](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles** → **Identifiers**
2. Findes `dk.hyldenbrandt.byensgaader` ikke, tryk **+** → **App IDs** → **App**
3. Description: `Byens Gaader`. Bundle ID: **Explicit** → `dk.hyldenbrandt.byensgaader`
4. Ingen capabilities skal slås til. Appen bruger kun position, og det styres af
   `Info.plist`.

---

## 2. Opret appen i App Store Connect

Det er dette skridt, der mangler i dag. Uden det fejler eksporten med
`No profiles for 'dk.hyldenbrandt.byensgaader' were found`.

1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**
2. Udfyld:
   - **Platforms:** iOS
   - **Name:** `Byens Gåder` — skal være unikt i hele App Store. Er navnet taget,
     vælg et andet her; det påvirker ikke `CFBundleDisplayName` i appen.
   - **Primary Language:** Dansk
   - **Bundle ID:** `dk.hyldenbrandt.byensgaader`
   - **SKU:** fx `byensgaader-001` — kun til dit eget regnskab, ses aldrig af brugere
   - **User Access:** Full Access
3. **Create**

Du behøver **ikke** udfylde pris, kategori, skærmbilleder eller beskrivelse for
at bruge TestFlight. Det er først nødvendigt ved en rigtig udgivelse.

---

## 3. Byg og upload fra Xcode

> **Gør afsnit 1 og 2 først.** Uploaden fejler, hvis App ID'et og app-posten
> ikke findes. Det er ikke en fejl i projektet.

### Trin 1 — vælg den rigtige destination

Øverst i Xcode, til højre for play-knappen, står der hvilken enhed der bygges
til. Klik på den og vælg **Any iOS Device (arm64)**.

Det er det vigtigste skridt, og det er dér de fleste går i stå: **står der en
simulator, er menupunktet Archive gråt og kan ikke vælges.** En simulator bygger
til Mac-processoren, og det kan ikke sendes til Apple.

Vælg også målet **ByensHemmeligheder** — ikke `ByensHemmelighederUITests`.

### Trin 2 — hæv build-nummeret

Apple afviser to bygninger med samme nummer, og fejlen kommer først efter
uploaden. Klik projektet i venstre panel → målet **ByensHemmeligheder** →
fanen **General** → afsnittet **Identity**:

- **Build** hæves med 1 hver eneste gang (1 → 2 → 3 …)
- **Version** hæves kun, når det er en ny version udadtil (1.0 → 1.1)

### Trin 3 — Product → Archive

Menuen **Product** øverst på skærmen → **Archive**.

Xcode bygger nu i **Release**-opsætning. Det tager nogle minutter — længere end
et almindeligt build, fordi hele pakken optimeres og signeres.

Går det galt her, er det næsten altid destinationen fra trin 1.

### Trin 4 — Organizer åbner af sig selv

Når arkivet er færdigt, åbner vinduet **Organizer** med arkivet øverst på
listen. Sker det ikke, findes det under **Window → Organizer**.

Kontrollér at versionen og build-nummeret er dem, du satte i trin 2.

### Trin 5 — Validate App først

Knappen **Validate App** i højre side. Den kører Apples kontrol **uden** at
uploade noget, og den fanger de fejl, der ellers først dukker op en time senere:
manglende ikon, forkert build-nummer, manglende profil.

Det tager to minutter og sparer ofte en time. Spring det ikke over.

### Trin 6 — Distribute App

Knappen **Distribute App** → vælg:

1. **App Store Connect** — TestFlight og App Store er den samme kanal
2. **Upload** — ikke *Export*. *Export* lægger blot en fil på din disk.
3. Lad **Automatically manage signing** stå til. Xcode henter eller opretter
   distributionsprofilen.
4. **Upload**

Uploaden tager nogle minutter afhængigt af forbindelsen.

### Trin 7 — vent på behandling

Bygningen er **ikke** klar med det samme. Den skal behandles hos Apple, typisk
5–60 minutter. Du får en mail, når den er klar, og den dukker op under fanen
**TestFlight** i App Store Connect.

Fortsæt derfra i afsnit 4.

---

### Hvis noget går galt

| Symptom | Årsag |
|---|---|
| **Archive** er gråt i Product-menuen | Der er valgt en simulator. Vælg **Any iOS Device (arm64)**. |
| `No account for team "QHL89A7A8J"` | Log ind i **Xcode → Settings → Accounts** med det Apple-ID, der ejer teamet. |
| `No profiles for 'dk.hyldenbrandt.byensgaader' were found` | App ID'et eller app-posten mangler. Se afsnit 1 og 2. |
| `The bundle version must be higher than the previously uploaded version` | Build-nummeret er ikke hævet. Trin 2. |
| Organizer viser intet arkiv | Der blev bygget til en simulator, eller arkivet fejlede. Se fejlpanelet. |

---

### Samme sag fra terminalen

Kun hvis du foretrækker det. Eksportopsætningen ligger i repoet som
`iOS/Config/ExportOptions.plist`.

```bash
cd iOS
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer

xcodebuild -project ByensHemmeligheder.xcodeproj -scheme ByensHemmeligheder \
  -destination "generic/platform=iOS" -configuration Release \
  -archivePath build/ByensGaader.xcarchive archive

xcodebuild -exportArchive \
  -archivePath build/ByensGaader.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist Config/ExportOptions.plist \
  -allowProvisioningUpdates

xcrun altool --upload-app --type ios \
  --file build/export/ByensHemmeligheder.ipa \
  --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

`-allowProvisioningUpdates` lader Xcode hente eller oprette
distributionsprofilen.

### API-nøglen er en hemmelighed

Kun nødvendig til terminalvejen. Hentes i App Store Connect under
**Users and Access → Integrations → App Store Connect API**. Du får en
`AuthKey_XXXXXXXX.p8`, som **kun kan hentes én gang**.

- Læg den i `~/.appstoreconnect/private_keys/` — dér finder `altool` den selv.
- Læg den **aldrig** i repoet. Mønsteret `AuthKey_*.p8` er dækket af
  `.gitignore` (linje 31), men et public repo tilgiver ikke en fejltagelse: en
  nøgle, der er committet og siden slettet, er stadig kompromitteret.
- Kontrollér med `git check-ignore -v <sti>`, hvis du er i tvivl.

---

## 4. Slip bygningen løs i TestFlight

1. App Store Connect → din app → fanen **TestFlight**
2. Bygningen står som **Processing** i 5–60 minutter. Vent.
3. Første gang spørges der om **eksportoverholdelse**. Svar **nej** til, at
   appen bruger ikke-fritaget kryptering — `ITSAppUsesNonExemptEncryption` er
   allerede sat til `false` i `Info.plist`, så svaret er konsistent.
4. Udfyld **Test Information**: hvad quizmasterne skal prøve, og en kontaktmail.

### Tilføj quizmasterne

De skal først være **brugere i teamet**:

1. **Users and Access** → **+**
2. Mailadresse (deres Apple-ID) og rolle — **Developer** eller **Marketing** er nok
3. De får en invitation, som skal accepteres

Derefter som testere:

1. **TestFlight** → **Internal Testing** → **+** ved gruppen
2. Opret fx gruppen `Quizmastere`
3. Tilføj brugerne, og vælg hvilken bygning gruppen har adgang til

---

## 5. Sådan gør quizmasteren

1. Installér **TestFlight** fra App Store (Apples egen app, gratis)
2. Åbn invitationsmailen på telefonen og tryk **View in TestFlight**
3. Installér **Byens Gåder** inde fra TestFlight
4. Ved første start spørger appen om **position** — vælg **Tillad, mens appen er i brug**.
   Uden den kan opgaverne ikke låses op; det er stedet, der er spillet.

### Hvad de skal vide

- **Admin-siden** åbnes med hammer-ikonet øverst til højre. Dér kan de simulere
  deres position og nulstille alle svar, så den samme opgave kan prøves igen.
- **Simuleret position** er slået fra på en telefon. Slås den til under
  "Positionskilde", begynder simuleringen dér, hvor de faktisk står.
- **En gåde kan kun løses én gang.** Skal den prøves igen, bruges
  "Nulstil alle svar" på admin-siden.
- **Fem opgaver** ligger i appen: Bølgen, Fjordenhus, Den grønne transmission,
  Vera og Den forsvundne landevej.

### Sådan rapporterer de fejl

Appen har **ingen indbygget fejlrapportering** endnu. Bed dem skrive direkte —
og bed dem altid om at oplyse **hvilken opgave** og **hvad de gjorde lige før**.
Uden det er en fejl som "den virkede ikke" umulig at forfølge.

I TestFlight kan de tage et skærmbillede og trykke **Del feedback**; det lander
i App Store Connect under **TestFlight → Feedback**.

---

## 6. Næste upload

Apple afviser to bygninger med samme nummer. Hæv **build-nummeret** hver gang:

- `CURRENT_PROJECT_VERSION` — hæves ved **hver** upload (1, 2, 3 …)
- `MARKETING_VERSION` — hæves kun, når det er en ny version udadtil (1.0 → 1.1)

Begge står i `iOS/ByensHemmeligheder.xcodeproj/project.pbxproj`. I Xcode findes
de under målet → **General** → **Identity**.

`ExportOptions.plist` sætter `manageAppVersionAndBuildNumber` til `false` med
vilje: Xcode skal ikke selv rode med numrene, så to uploads aldrig kan komme til
at dele nummer uden at nogen har besluttet det.

---

## 7. Når det driller

| Fejl | Årsag |
|---|---|
| `No profiles for '…' were found` | Appen findes ikke i App Store Connect. Se afsnit 2. |
| `No signing certificate "iOS Distribution" found` | Kør eksporten med `-allowProvisioningUpdates`, eller åbn Xcode → Settings → Accounts → Download Manual Profiles. |
| Bygningen står evigt i **Processing** | Vent en time. Sker det stadig, mangler ofte et ikon eller en nøgle i `Info.plist`. |
| `Invalid Bundle. Missing app icon` | Assets-kataloget er ikke med. Kontrollér `iOS/App/Assets.xcassets/AppIcon.appiconset`. |
| Testeren kan ikke se appen i TestFlight | Invitationen til **teamet** er ikke accepteret endnu — det er et andet skridt end testerinvitationen. |
