using Azure.Storage.Blobs;
using ByensGaader.Api.Storage;
using FastEndpoints;
using FastEndpoints.Swagger;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .Configure<ContentStoreOptions>(builder.Configuration.GetSection(ContentStoreOptions.Section));

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
    builder.Services.AddSingleton(
        new BlobServiceClient(account, new Azure.Identity.DefaultAzureCredential()));
    builder.Services.AddSingleton<IContentStore, BlobContentStore>();
}
else
{
    builder.Services.AddSingleton<IContentStore, FileSystemContentStore>();
}

builder.Services.AddSingleton<ByensGaader.Api.Features.Content.AuditTrail>();

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
                + "indholdspakker og billeder hentes som statiske blobs med ETag.";
        };
    });

var app = builder.Build();

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

/// <summary>
/// Gør værtsklassen synlig for <c>WebApplicationFactory</c> i testprojektet.
/// Uden den kan integrationstestene ikke starte appen.
/// </summary>
public partial class Program;
