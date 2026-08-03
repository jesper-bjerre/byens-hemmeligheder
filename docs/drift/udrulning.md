# Udrulning af backenden

Hvad der kører hvor, hvordan det kommer derop, og hvad der gik galt undervejs.

## Hvad der findes i Azure

Alt ligger i abonnementet *Jespers private Azure subscription*. Abonnements- og
tenant-id står i GitHub-secrets og ikke her — repoet er public.

| | Navn | Bemærkning |
|---|---|---|
| App Service Plan | `ASP-Gulvet-8d7b` | B1, Linux, West Europe, ressourcegruppe `Gulvet` |
| API (PROD) | `byensgaader-api-p` | `DOTNETCORE:10.0` |
| API (DEV) | `byensgaader-api-d` | `DOTNETCORE:10.0`, samme App Service Plan som PROD |
| Storage (PROD) | `byensgaaderp` | ressourcegruppe `byensgaader-p_rg`, containere `content` og `authoring` |
| Storage (DEV/lokal) | `byensgaaderd` | DEV bruger `content`/`authoring`; lokal bruger `content-local`/`authoring-local` |
| API-identiteter | system-assigned pr. API | hver har kun *Storage Blob Data Contributor* på sit eget miljø |
| Udrulningens identitet | `oidc-msi-8800` | user-assigned, *Website Contributor* på de to API'er alene |

**Planen deles af seks apps.** B1 er én kerne og 1,75 GB til dem alle.
Bliver API'et langsomt, er det dér, der skal kigges — ikke i koden.

**B1 har ingen deployment slots.** En udrulning går direkte i luften. Relevante
ændringer på `main` udrulles i den aktuelle testfase automatisk til både DEV og
PROD; begge API-workflows kan også genkøres manuelt.

## App-indstillinger

PROD:

```
ContentStore__Provider          = Blob
ContentStore__StorageAccountUri = https://byensgaaderp.blob.core.windows.net
ContentStore__Container         = content
ContentStore__AuthoringContainer = authoring
Authoring__ReconciliationEnabled = false
ASPNETCORE_ENVIRONMENT          = Production
```

DEV bruger samme indstillinger med disse miljøværdier:

```text
ContentStore__StorageAccountUri = https://byensgaaderd.blob.core.windows.net
ContentStore__Container         = content
ContentStore__AuthoringContainer = authoring
ASPNETCORE_ENVIRONMENT          = Development
```

`Authoring__ReconciliationEnabled` står på `false`, fordi migrationen til
opgavevise blobs er afsluttet. En almindelig kodeudrulning må ikke forsøge at
genskabe eller migrere PROD-indhold ved opstart.

Den tidligere mulighed for at pege PROD tilbage på D-kontoen er lukket, fordi D
nu er et aktivt testmiljø. PROD må ikke peges på `byensgaaderd`, medmindre DEV
først fryses, begge datasæt afstemmes, og adgangsrollen gives eksplicit igen.

Den gamle admin-builds hel-pakke-PUT afvises efter authoring er aktiveret. Det
er bevidst: at lade to samtidige kilder acceptere writes ville kunne tabe
opgaver. Udrul derfor de nye admin-klienter før aktiveringen.

`Provider` er eksplicit og udledes **ikke** af, om der står en adresse. En
tastefejl ville ellers falde tilbage til containerens lokale disk, og API'et
ville se ud til at virke, indtil den første genstart tømte alt. Er `Provider`
sat til `Blob` uden en gyldig adresse, starter appen ikke:

```
System.InvalidOperationException: ContentStore:Provider er Blob, men
ContentStore:StorageAccountUri er ikke en adresse.
```

Der er ingen nøgler. `DefaultAzureCredential` bruger `az login` lokalt og
managed identity i Azure.

## Sådan udrulles der

Et push til `main`, der rører `backend/`, kører både
[`backend-deploy-dev.yml`](../../.github/workflows/backend-deploy-dev.yml) og
[`backend-deploy.yml`](../../.github/workflows/backend-deploy.yml). De tester,
publicerer og udruller til henholdsvis DEV og PROD og kontrollerer derefter, at
miljøets `/health` svarer 200. De to workflows kører indtil videre parallelt.
Planen er senere at indsætte API-tests mod DEV som gate før PROD-udrulningen.

Uden det sidste trin kan en udrulning melde grønt, mens app'en svarer 503. Det
er ikke hypotetisk — nabo-app'en `quizmaster-api-p` stod sådan i ugevis, uden at
nogen opdagede det.

Der publiceres **framework-dependent**. App Service Linux har `DOTNETCORE|10.0`,
så runtimen behøver ikke pakkes med.

### I hånden, hvis pipelinen er nede

```bash
cd backend
dotnet publish src/ByensGaader.Api -c Release -o /tmp/publish
cd /tmp/publish && zip -qr /tmp/app.zip .
az webapp deploy --name byensgaader-api-p --resource-group Gulvet \
  --src-path /tmp/app.zip --type zip
```

## Webadmin på Azure Static Web Apps

Quizmasterens Angular-app er udrullet som en separat Static Web App:

| | Værdi |
|---|---|
| Ressource | `byensgaader-admin-p` |
| Ressourcegruppe | `byensgaader-d_rg` |
| Plan og region | Free, West Europe |
| Adresse | `https://salmon-grass-0b3946003.7.azurestaticapps.net` |
| Kilde | `webApps/webadmin/` på `main` |
| Workflow | `azure-static-web-apps-salmon-grass-0b3946003.yml` |

DEV-udgaven er `byensgaader-admin-d` på
`https://ambitious-forest-0a05d7d03.7.azurestaticapps.net` og udrulles af
`azure-static-web-apps-admin-dev.yml`. Dens Angular-build bruger
`byensgaader-api-d`; PROD-buildet bruger fortsat `byensgaader-api-p`.

Workflowet installerer med Node 22, kører enhedstest og produktionsbuild og
uploader derefter det færdige `dist/webadmin/browser`-artefakt. Azure må ikke
forsøge at detektere og bygge monorepoet med Oryx; portalens første automatisk
genererede workflow valgte både en forkert kildemappe og en outputmappe fra et
andet projekt.

API'ets App Service har denne app-indstilling, så browseren må kalde skrivevejen
og læse dens `ETag`-header:

```text
Cors__AllowedOrigins__3=https://salmon-grass-0b3946003.7.azurestaticapps.net
```

Der er fortsat ingen authentication eller authorization. Webadressen er
offentlig, og dette er kun accepteret under den interne test.

## Byens Gåder web på Azure Static Web Apps

Spillerens Angular-app er udrullet som sin egen Static Web App:

| | Værdi |
|---|---|
| Ressource | `byensgaader` |
| Ressourcegruppe | `byensgaader-d_rg` |
| Plan og region | Free, West Europe |
| Adresse | `https://agreeable-island-016468f03.7.azurestaticapps.net` |
| Kilde | `webApps/byensgaaderweb/` på `main` |
| Workflow | `azure-static-web-apps-agreeable-island-016468f03.yml` |

DEV-udgaven er `byensgaader-web-d` på
`https://delightful-coast-08c419b03.7.azurestaticapps.net` og udrulles af
`azure-static-web-apps-player-dev.yml`. Også her vælges API-adressen ved build,
så et DEV-build ikke kan læse eller skrive PROD-data.

Workflowet følger samme model som webadminen: Node 22, test og produktionsbuild
før upload af `dist/byensgaaderweb/browser`. API'ets App Service tillader
spillerappens origin via:

```text
Cors__AllowedOrigins__4=https://agreeable-island-016468f03.7.azurestaticapps.net
```

Spillerprogression ligger fortsat kun i browserens `localStorage`, og GPS-data
skrives ikke til lagring. Authentication og authorization er som aftalt
udskudt under den interne test.

## To fælder, der kostede en halv dag

### GitHubs emne bærer uforanderlige id'er

Azure-login fejlede med `AADSTS700213` i tre kørsler i træk. Både den federated
credential, vi lavede i hånden, og den Azures Deployment Center oprettede, stod
med de rene navne:

```
repo:jesper-bjerre/byens-hemmeligheder:ref:refs/heads/main
```

GitHub sender i stedet:

```
repo:jesper-bjerre@260194575/byens-hemmeligheder@1310694671:ref:refs/heads/main
```

Id'erne gør, at en omdøbning af repoet ikke bryder tillidsrelationen. Fejlen var
ikke til at finde ved at sammenligne de to sider — **de var enige, bare om det
forkerte format**. Emnet står i logfilen under "Federated token details".

Flyttes repoet til en anden konto, skal credential'en
`github-main-uforanderligt-id` på `oidc-msi-8800` rettes.

### SCM-basisgodkendelse er slået fra på nye apps

`azure/webapps-deploy` kræver den og fejler med "Basic authentication is
disabled". Den nemme udvej er at slå den til igen — men så findes der en
adgangskode til app'en, som skal opbevares og roteres, og det var præcis dét,
OIDC skulle gøre overflødigt.

Workflowet bruger derfor `az webapp deploy`, som bruger den bearer-token,
`azure/login` lige har hentet.

## Fasedeling — hvor vi er

| Fase | Hvad | Status |
|---|---|---|
| 1 | DEV-storage + `BlobContentStore`, kørt lokalt | ✅ |
| 2 | API'et på App Service mod DEV-storage | ✅ — `byensgaader-api-d` |
| 3 | Indholdet flytter fra repo til blob | ✅ — se [ADR 0005](../ADR/0005-blob-er-kilden-til-indholdet.md) |
| 4 | Spillerappen henter fra tjenesten | ✅ — var allerede gjort i ADR 0004 |
| 5a | PROD-storage | ✅ — `byensgaaderp`, cutover 3. august 2026 |
| 5b | Adgangskontrol | ⬜ — bevidst udskudt under intern test |

PROD peger kun på `byensgaaderp`; DEV peger kun på `byensgaaderd`. PROD-appens
rolle på D-kontoen er fjernet. Lokal backend deler D-kontoen, men bruger de
isolerede lokalcontainere.

### Fase 5b — planlagt, ikke lavet

**Der er ingen adgangskontrol.** Hvert endepunkt står med `AllowAnonymous()` —
også `PUT` og `DELETE`. Enhver, der finder adressen, kan omskrive
indholdspakken eller slette billederne. `X-Quizmaster` er et navn, klienten selv
skriver; det er et spor, ikke en spærring.

**PRODs `httpsOnly` står på `false`.** En forespørgsel over almindelig HTTP bliver
besvaret. Det skal rettes, *før* der indføres en nøgle — ellers kan nøglen
sendes i klartekst.

**Blob-versionering er slået til på `byensgaaderp`.** Blob- og
container-soft-delete dækker 7 dage. En lifecycle-regel for gamle versioner
mangler fortsat, før data ikke længere må smides væk.

Før indholdet ikke længere må smides væk, skal en lifecycle-regel begrænse gamle
versioner, og gentagne dirty publication-states skal give alarm. Det er fortsat
bevidst udskudt under den interne test.

Løsningen er skrevet ud i [køreplanens mål 1](../plans/koereplan.md) med de
kommandoer, der mangler at blive kørt. Kort: en delt nøgle som header på alt
andet end `GET`, som en spærring mod tilfældige — ikke som en rettighedsmodel.
Rigtige konti og roller håndhævet server-side følger forfatningens princip IV og
venter på [ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md).

## Testene mod Azure

`ContentStoreContractTests` kører de samme 18 kontroller mod både filsystemet og
blob. Blob springes over, når der ikke er en konto:

```bash
BH_TEST_BLOB_URI="https://byensgaaderd.blob.core.windows.net" \
BH_TEST_BLOB_CONTAINER="content-local" \
dotnet test
```

De skriver og sletter. **Kør dem aldrig mod produktion.**

Kontrakten fandt en fejl, der havde ligget i filsystemlageret hele tiden: tolv
samtidige tilføjelser til revisionssporet gav elleve linjer. `FileMode.Append`
søger til enden, når strømmen åbnes, og husker derefter sin egen position, så to
strømme skriver oven i hinanden. Blob havde ikke problemet — `AppendBlock` er
atomisk pr. kald.
