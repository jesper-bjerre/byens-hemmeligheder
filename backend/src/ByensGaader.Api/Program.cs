using Azure.Data.Tables;
using Azure.Storage.Blobs;
using ByensGaader.Api.Features.Accounts;
using ByensGaader.Api.Features.Authentication;
using ByensGaader.Api.Features.Engagement;
using ByensGaader.Api.Features.Scoring;
using ByensGaader.Api.Security;
using ByensGaader.Api.Storage;
using FastEndpoints;
using FastEndpoints.Swagger;
using Microsoft.AspNetCore.Authentication;
using NSwag;
using ProjectAuthenticationOptions = ByensGaader.Api.Features.Authentication.AuthenticationOptions;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .Configure<ContentStoreOptions>(builder.Configuration.GetSection(ContentStoreOptions.Section));

var authentication = builder.Configuration
    .GetSection(ProjectAuthenticationOptions.Section)
    .Get<ProjectAuthenticationOptions>() ?? new ProjectAuthenticationOptions();
authentication.ValidateForStartup(builder.Environment);
builder.Services.Configure<ProjectAuthenticationOptions>(
    builder.Configuration.GetSection(ProjectAuthenticationOptions.Section));

TableServiceClient? accountTables = null;
if (authentication.Provider is AuthenticationStoreProvider.Table)
{
    accountTables = new TableServiceClient(
        new Uri(authentication.TableServiceUri!),
        new Azure.Identity.DefaultAzureCredential());
    builder.Services.AddSingleton(accountTables);
}

builder.Services.AddSingleton<IAuthenticationRepository>(services => authentication.Provider switch
{
    AuthenticationStoreProvider.Disabled or AuthenticationStoreProvider.InMemory =>
        new InMemoryAuthenticationRepository(),
    AuthenticationStoreProvider.Table => new TableAuthenticationRepository(
        services.GetRequiredService<TableServiceClient>(), authentication),
    _ => throw new InvalidOperationException("Ukendt authentication-provider."),
});
builder.Services.AddSingleton<IMissionEngagementRepository>(services => authentication.Provider switch
{
    AuthenticationStoreProvider.Table => new TableMissionEngagementRepository(
        services.GetRequiredService<TableServiceClient>(), authentication),
    _ => new InMemoryMissionEngagementRepository(),
});
builder.Services.AddMemoryCache();
builder.Services.AddSingleton<MissionEngagementService>();
builder.Services.AddSingleton<IScoreRepository>(services => authentication.Provider switch
{
    AuthenticationStoreProvider.Table => new TableScoreRepository(
        services.GetRequiredService<TableServiceClient>(), authentication),
    _ => new InMemoryScoreRepository(),
});
builder.Services.AddSingleton<ScoreService>();
builder.Services.AddSingleton<SessionAuthenticator>();
builder.Services.AddHttpClient<IAppleIdentityValidator, AppleIdentityValidator>(client =>
    client.Timeout = TimeSpan.FromSeconds(15));
builder.Services.AddHttpClient<IAppleTokenClient, AppleTokenClient>(client =>
    client.Timeout = TimeSpan.FromSeconds(15));
builder.Services.AddSingleton<IProviderTokenProtector, ProviderTokenProtector>();
builder.Services.AddSingleton<SessionService>();
builder.Services.AddSingleton<AccountService>();
builder.Services.AddSingleton<AccountAdministrationService>();
builder.Services.AddSingleton<AccountLifecycleService>();
builder.Services.AddSingleton<IAccountAuditRepository>(services => authentication.Provider switch
{
    AuthenticationStoreProvider.Table => new TableAccountAuditRepository(
        services.GetRequiredService<TableServiceClient>(), authentication),
    _ => new InMemoryAccountAuditRepository(),
});
builder.Services
    .AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = AuthenticationPolicies.Scheme;
        options.DefaultChallengeScheme = AuthenticationPolicies.Scheme;
    })
    .AddScheme<AuthenticationSchemeOptions, OpaqueBearerHandler>(
        AuthenticationPolicies.Scheme, _ => { });
builder.Services.AddAuthorizationBuilder()
    .AddPolicy(AuthenticationPolicies.User, policy => policy
        .RequireAuthenticatedUser())
    .AddPolicy(AuthenticationPolicies.DesignerOrAdmin, policy => policy
        .RequireRole(AccountRole.Designer.ToString(), AccountRole.Admin.ToString()))
    .AddPolicy(AuthenticationPolicies.AdminOnly, policy => policy
        .RequireRole(AccountRole.Admin.ToString()));

// Webadminen kører på en anden origin end API'et — lokalt på port 4200 og
// senere som Azure Static Web App. Listen er konfiguration, så den fremtidige
// Azure-adresse kan tilføjes som `Cors__AllowedOrigins__3` uden en kodeændring.
// Der bruges ikke wildcard: skrive-API'et er stadig anonymt under den interne
// test, og en åben CORS-politik ville gøre det kaldeligt fra enhver webside.
var webAdminOrigins = builder.Configuration
    .GetSection("Cors:AllowedOrigins")
    .Get<string[]>() ?? [];

builder.Services.AddCors(options =>
{
    options.AddPolicy("WebAdmin", policy =>
    {
        if (webAdminOrigins.Length > 0)
        {
            policy
                .WithOrigins(webAdminOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod()
                // Browserklienten skal læse ETag for at undgå, at to
                // quizmastere overskriver hinanden.
                .WithExposedHeaders("ETag", "X-Content-Publication");
        }
    });
});

// Filbaseret i udvikling, blob i Azure. Endepunkterne kender kun grænsefladen.
//
// Valget er eksplicit og ikke udledt af, om der står en adresse i
// konfigurationen: en tastefejl ville ellers falde tilbage til filsystemet, og
// API'et ville se ud til at virke, mens det skrev et sted, ingen læser.
var storage = builder.Configuration.GetSection(ContentStoreOptions.Section)
    .Get<ContentStoreOptions>() ?? new ContentStoreOptions();

if (storage.Provider is ContentStoreProvider.Blob)
{
    if (!Uri.TryCreate(storage.StorageAccountUri, UriKind.Absolute, out var account))
    {
        throw new InvalidOperationException(
            "ContentStore:Provider er Blob, men ContentStore:StorageAccountUri er ikke en "
            + "adresse. Sæt den med `dotnet user-secrets` lokalt eller som app-indstilling "
            + "i Azure.");
    }

    // `DefaultAzureCredential` er `az login` lokalt og managed identity i
    // Azure. Ingen nøgle at lække — og intet at rotere, hvis repoet er public.
    var service = new BlobServiceClient(account, new Azure.Identity.DefaultAzureCredential());
    var publicStore = new BlobContentStore(
        service.GetBlobContainerClient(storage.Container));
    var authoringStore = new BlobContentStore(
        service.GetBlobContainerClient(storage.AuthoringContainer));
    builder.Services.AddSingleton(service);
    builder.Services.AddSingleton<IContentStore>(publicStore);
    builder.Services.AddSingleton(new ContentStores(publicStore, authoringStore));
}
else
{
    if (builder.Environment.IsDevelopment())
    {
        SeedLocalPublicStore(storage);
    }
    var publicStore = new FileSystemContentStore(
        Microsoft.Extensions.Options.Options.Create(storage));
    var authoringStore = new FileSystemContentStore(
        Microsoft.Extensions.Options.Options.Create(new ContentStoreOptions
        {
            RootPath = storage.AuthoringRootPath,
        }));
    builder.Services.AddSingleton<IContentStore>(publicStore);
    builder.Services.AddSingleton(new ContentStores(publicStore, authoringStore));
}

builder.Services.AddSingleton<ByensGaader.Api.Features.Content.AuditTrail>();
builder.Services.Configure<ByensGaader.Api.Features.Content.AuthoringOptions>(
    builder.Configuration.GetSection(ByensGaader.Api.Features.Content.AuthoringOptions.Section));
builder.Services.AddSingleton(TimeProvider.System);
builder.Services.AddSingleton<ByensGaader.Api.Features.Content.AuthoringRepository>();
builder.Services.AddSingleton<ByensGaader.Api.Features.Content.ContentPublisher>();
builder.Services.AddHostedService<ByensGaader.Api.Features.Content.PublicationReconciler>();
builder.Services.AddSingleton<
    ByensGaader.Api.Features.Content.IAudioTranscoder,
    ByensGaader.Api.Features.Content.FfmpegAudioTranscoder>();

builder.Services
    .AddFastEndpoints()
    .SwaggerDocument(o =>
    {
        o.DocumentSettings = s =>
        {
            s.Title = "Byens Gåder — quizmaster-API";
            s.Version = "v1";
            s.Description =
                "Skrivevejen. Spillernes læsevej går uden om dette API: "
                + "indholdspakker og billeder hentes som statiske blobs med ETag. "
                + "User kræver login, DesignerOrAdmin beskytter redaktionelle ruter, "
                + "og AdminOnly beskytter bruger- og rolleadministration.";
            s.AddAuth("bearerAuth", new OpenApiSecurityScheme
            {
                Type = OpenApiSecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "opaque",
                Description = "Kortlivet session udstedt af Byens Gåder-API'et.",
            });
        };
    });

var app = builder.Build();

app.UseCors("WebAdmin");
app.UseAuthentication();
app.UseAuthorization();

// Ingen globalt rutepræfiks og ingen versionering endnu.
//
// Begge dele blev prøvet og fjernet igen: de omskrev ruterne bag ryggen på
// endepunkterne, så `/health` blev til noget andet, end der stod i koden.
// Hvert endepunkt angiver sin fulde rute — så er der ét sted at læse den.
// Versionering tilføjes, når der findes et endepunkt, der skal versioneres.
app.UseFastEndpoints();

// Swagger kun uden for produktion. En API-beskrivelse er en køreplan for den,
// der vil finde huller.
if (app.Environment.IsDevelopment())
{
    app.UseSwaggerGen();
}

app.Run();

static void SeedLocalPublicStore(ContentStoreOptions storage)
{
    var target = Path.GetFullPath(storage.RootPath);
    var pack = Path.Combine(target, "da-DK", "content-pack.json");
    if (File.Exists(pack)) return;

    var fixture = Path.GetFullPath(storage.FixtureRootPath);
    var fixturePack = Path.Combine(fixture, "da-DK", "content-pack.json");
    if (!File.Exists(fixturePack))
    {
        throw new InvalidOperationException(
            $"Den lokale indholdsfixture findes ikke: {fixturePack}");
    }

    // Public-lageret er skrivbart gennem admin-API'et. Det må derfor være en
    // ignoreret arbejdskopi og aldrig contracts-fixturen, som testene læser.
    foreach (var directory in Directory.EnumerateDirectories(fixture, "*", SearchOption.AllDirectories))
    {
        Directory.CreateDirectory(Path.Combine(target, Path.GetRelativePath(fixture, directory)));
    }
    foreach (var source in Directory.EnumerateFiles(fixture, "*", SearchOption.AllDirectories))
    {
        var destination = Path.Combine(target, Path.GetRelativePath(fixture, source));
        Directory.CreateDirectory(Path.GetDirectoryName(destination)!);
        File.Copy(source, destination, overwrite: true);
    }
}

/// <summary>
/// Gør værtsklassen synlig for <c>WebApplicationFactory</c> i testprojektet.
/// Uden den kan integrationstestene ikke starte appen.
/// </summary>
public partial class Program;
