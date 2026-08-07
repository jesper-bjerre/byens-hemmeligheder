# Quickstart: Authentication og roller

## Forudsætninger

- .NET 10 og Xcode valgt som beskrevet i `AGENTS.md`.
- Ingen Apple-nøgle må oprettes i repoet. Hvis en lokal `.p8` bruges, skal
  `git check-ignore -v <sti>` først bevise, at filen ignoreres.
- Før rigtig Apple-test skal App IDs, Services ID, return URLs og nøgle være
  oprettet i Apple Developer-portalen.
- Authentication må ikke aktiveres i DEV/PROD før forfatningsgaten i
  [plan.md](./plan.md) er godkendt.

## 1. Isolerede backendtests

```bash
cd backend
dotnet test
```

Forventet:

- offentligt pack/health virker uden token;
- alle authoring-endpoints giver `401` uden token;
- User giver `403`;
- Designer/Admin kan læse og skrive;
- rolleændring og sessionrotation har negative replaytests.

## 2. Lokal backend med authentication slukket

```bash
./backend/run.sh
```

Authentication skal fejle lukket: auth- og authoringfunktioner må ikke blive
anonyme, blot fordi Apple- eller Table-konfiguration mangler.

## 3. DEV end-to-end

Konfigurer værdierne som App Service settings/Key Vault references, aldrig som
sporede filer:

```text
Authentication__Enabled=true
Authentication__Apple__TeamId=<konfiguration>
Authentication__Apple__KeyId=<konfiguration>
Authentication__Apple__PrivateKey=<Key Vault reference>
Authentication__Apple__ProviderTokenEncryptionKey=<Key Vault reference til 32 tilfældige bytes i base64>
Authentication__Apple__AllowedClientIds__0=<spiller App ID>
Authentication__Apple__AllowedClientIds__1=<admin App ID>
Authentication__Apple__AllowedClientIds__2=<web-admin Services ID>
Authentication__Apple__AllowedWebRedirectUris__0=<eksakt web-admin callback-URL>
Authentication__Apple__BootstrapAdminEmail=<ikke i repo>
Authentication__TableServiceUri=https://<dev-konto>.table.core.windows.net
```

Valider derefter kontrakten i [contracts/auth-api.yaml](./contracts/auth-api.yaml):

1. Første allowlistede Apple-login bliver Admin præcis én gang.
2. Admin kan gøre en testkonto til Designer.
3. Designer kan gemme en kladde; User kan ikke.
4. Gæst/User får ikke `fieldTestReady` fra offentlig læsevej.
5. Logout og refresh-replay afviser tokenet.

## 4. Klientvalidering

Åbn altid begge apps gennem repoets fælles workspace:

```bash
open ByensGaader.xcworkspace
```

Spiller- og adminprojektet bruger den samme lokale `BHKit`-pakke. Åbnes de som
to separate `.xcodeproj`-vinduer, forsøger Xcode at eje pakken to gange og
fejler med "Couldn't load BHKit because it is already opened from another
project or workspace".

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  swift test --package-path iOS/Packages/BHKit

cd webApps/webadmin && npm test -- --watch=false && npm run build
cd ../byensgaaderweb && npm test -- --watch=false && npm run build
```

Byg begge iOS-apps mod simulatoren **iPhone 17**. Rigtig Apple-login testes
derefter på en signeret fysisk enhed, fordi simulatoren ikke er releasebevis.

## 5. Releasegate

- Forfatningsændring og databehandlings-/slettepolitik er menneskeligt godkendt.
- DEV end-to-end og negative API-tests er grønne.
- App Service har HTTPS-only.
- Ingen hemmeligheder eller konkrete bootstrapidentiteter er staged.
- Et menneske reviewer og godkender PROD-release; AI deployer ikke direkte.
