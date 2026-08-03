namespace ByensGaader.Api.Storage;

/// <summary>
/// Hvor indholdspakker og medier ligger.
/// </summary>
/// <remarks>
/// Grænsefladen findes, fordi lageret skal skiftes: i dag filer på disk, i
/// morgen Azure Blob Storage. Skiftet må ikke røre endepunkterne.
///
/// Bemærk at der returneres bytes og ikke afkodede modeller. Serveren har intet
/// ærinde at forstå en indholdspakke — den leverer den. Så kan kontrakten
/// udvides i appen uden en serverudrulning.
/// </remarks>
internal interface IContentStore
{
    /// <returns><c>null</c> hvis filen ikke findes.</returns>
    public Task<StoredFile?> ReadAsync(string relativePath, CancellationToken ct);

    /// <summary>Skriver en fil og returnerer dens nye ETag.</summary>
    /// <param name="expectedETag">
    /// Den udgave, skribenten troede hen rettede i. <c>null</c> betyder "filen
    /// fandtes ikke". Stemmer den ikke, har en anden skrevet i mellemtiden, og
    /// skrivningen afvises.
    ///
    /// Uden dette taber den, der gemmer sidst, den andens arbejde uden at nogen
    /// opdager det — og alle quizmastere kan rette i alt.
    /// </param>
    public Task<WriteOutcome> WriteAsync(
        string relativePath, byte[] content, string? expectedETag, CancellationToken ct);

    /// <summary>Opretter en fil, der ikke findes i forvejen.</summary>
    /// <remarks>
    /// Adskilt fra <see cref="WriteAsync"/>, fordi medier er **uforanderlige**.
    /// Serveren sender dem med et års cache; en fil, der skifter indhold uden
    /// at skifte navn, ville stå gammel på telefonerne i et år uden at nogen
    /// kunne gøre noget. Skal billedet være et andet, skal det hedde noget
    /// andet — derfor hedder filerne `boelgen-001` og ikke `boelgen`.
    /// </remarks>
    public Task<WriteOutcome> CreateAsync(
        string relativePath, byte[] content, CancellationToken ct);

    /// <summary>Føjer bytes til enden af en fil og opretter den, hvis den mangler.</summary>
    /// <remarks>
    /// Findes for revisionssporet og kun for det. Sporet har hverken ETag eller
    /// samtidighedskontrol, fordi to quizmastere, der gemmer samtidig, begge
    /// skal ende i sporet — en <see cref="WriteAsync"/> ville lade den ene
    /// linje overskrive den anden, og en tabt linje i et revisionsspor er
    /// værre end ingen.
    /// </remarks>
    public Task<WriteOutcome> AppendAsync(
        string relativePath, byte[] content, CancellationToken ct);

    public Task<bool> DeleteAsync(string relativePath, CancellationToken ct);

    /// <summary>Sletter kun, hvis filen stadig har den forventede ETag.</summary>
    public Task<WriteOutcome> DeleteIfMatchAsync(
        string relativePath, string expectedETag, CancellationToken ct);

    /// <summary>Filnavne i en mappe, sorteret. Tom hvis mappen ikke findes.</summary>
    public Task<IReadOnlyList<string>> ListAsync(string relativeDirectory, CancellationToken ct);

    /// <summary>
    /// Tager en advisory lease. Alle authoring-skrivninger respekterer den;
    /// lageret låser ikke andre filer af sig selv.
    /// </summary>
    public Task<IContentLease> AcquireLeaseAsync(string relativePath, CancellationToken ct);
}

internal interface IContentLease : IAsyncDisposable
{
    /// <summary>Om kaldet måtte vente på en anden publicering.</summary>
    public bool WasContended { get; }
}

/// <summary>De to dataområder har samme teknik, men aldrig samme rettigheder.</summary>
internal sealed record ContentStores(IContentStore Public, IContentStore Authoring);

internal enum WriteOutcome
{
    Written,
    /// <summary>En anden har skrevet siden. Skribenten skal hente igen.</summary>
    Conflict,
    /// <summary>Stien pegede uden for indholdsmappen.</summary>
    Rejected,
    /// <summary>Filen findes allerede. Medier overskrives ikke.</summary>
    AlreadyExists,
}

/// <param name="Content">Filens bytes.</param>
/// <param name="ETag">
/// Stabilt kendetegn for indholdet. Beregnes af indholdet selv og ikke af
/// ændringstidspunktet: en fil, der kopieres eller genskabes uændret, skal have
/// samme ETag, ellers henter alle apps alt igen uden grund.
/// </param>
internal sealed record StoredFile(byte[] Content, string ETag, string ContentType);
