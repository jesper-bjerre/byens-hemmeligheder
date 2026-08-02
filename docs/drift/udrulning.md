# Udrulning af backenden

Hvad der kører hvor, hvordan det kommer derop, og hvad der gik galt undervejs.

## Hvad der findes i Azure

Alt ligger i abonnementet *Jespers private Azure subscription*. Abonnements- og
tenant-id står i GitHub-secrets og ikke her — repoet er public.

| | Navn | Bemærkning |
|---|---|---|
| App Service Plan | `ASP-Gulvet-8d7b` | B1, Linux, West Europe, ressourcegruppe `Gulvet` |
| Web app | `byensgaader-api-p` | `DOTNETCORE:10.0`, samme plan som fire andre apps |
| Storage (DEV) | `byensgaaderd` | ressourcegruppe `byensgaader-d_rg`, container `content` |
| App'ens identitet | system-assigned på `byensgaader-api-p` | *Storage Blob Data Contributor* på `byensgaaderd` |
| Udrulningens identitet | `oidc-msi-8800` | user-assigned, *Website Contributor* på app'en alene |

**Planen deles med fire andre apps.** B1 er én kerne og 1,75 GB til dem alle.
Bliver API'et langsomt, er det dér, der skal kigges — ikke i koden.

**B1 har ingen deployment slots.** En udrulning går direkte i luften. Derfor kan
workflowet også køres manuelt: det skal være en beslutning og ikke en bivirkning
af en rettet stavefejl.

## App-indstillinger

```
ContentStore__Provider          = Blob
ContentStore__StorageAccountUri = https://byensgaaderd.blob.core.windows.net
ContentStore__Container         = content
ASPNETCORE_ENVIRONMENT          = Production
```

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

Et push til `main`, der rører `backend/`, kører
[`backend-deploy.yml`](../../.github/workflows/backend-deploy.yml): tests,
publicering, udrulning, og derefter **en kontrol af at `/health` svarer 200**.

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
| 2 | API'et på App Service mod DEV-storage | ✅ |
| 3 | Indholdet flytter fra repo til blob | ✅ — se [ADR 0005](../ADR/0005-blob-er-kilden-til-indholdet.md) |
| 4 | Spillerappen henter fra tjenesten | ✅ — var allerede gjort i ADR 0004 |
| 5 | PROD-storage og adgangskontrol | ⬜ |

**App'en peger stadig på DEV-storage.** Det var med vilje: hele kæden kunne
køres igennem mod en rigtig server uden noget at ødelægge. Skiftet til en
PROD-konto er én app-indstilling.

### Fase 5 — planlagt, ikke lavet

**Der er ingen adgangskontrol.** Hvert endepunkt står med `AllowAnonymous()` —
også `PUT` og `DELETE`. Enhver, der finder adressen, kan omskrive
indholdspakken eller slette billederne. `X-Quizmaster` er et navn, klienten selv
skriver; det er et spor, ikke en spærring.

**`httpsOnly` står på `false`.** En forespørgsel over almindelig HTTP bliver
besvaret. Det skal rettes, *før* der indføres en nøgle — ellers kan nøglen
sendes i klartekst.

**Blob-versionering er slået fra.** Soft delete dækker 7 dage.

Løsningen er skrevet ud i [køreplanens mål 1](../plans/koereplan.md) med de
kommandoer, der mangler at blive kørt. Kort: en delt nøgle som header på alt
andet end `GET`, som en spærring mod tilfældige — ikke som en rettighedsmodel.
Rigtige konti og roller håndhævet server-side følger forfatningens princip IV og
venter på [ADR 0007](../ADR/0007-blob-nu-relationelt-naar-der-er-konti.md).

## Testene mod Azure

`ContentStoreContractTests` kører de samme 18 kontroller mod både filsystemet og
blob. Blob springes over, når der ikke er en konto:

```bash
BH_TEST_BLOB_URI="https://byensgaaderd.blob.core.windows.net" dotnet test
```

De skriver og sletter. **Kør dem aldrig mod produktion.**

Kontrakten fandt en fejl, der havde ligget i filsystemlageret hele tiden: tolv
samtidige tilføjelser til revisionssporet gav elleve linjer. `FileMode.Append`
søger til enden, når strømmen åbnes, og husker derefter sin egen position, så to
strømme skriver oven i hinanden. Blob havde ikke problemet — `AppendBlock` er
atomisk pr. kald.
