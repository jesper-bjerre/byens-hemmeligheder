using ByensGaader.Api.Features.Accounts;
using FastEndpoints;

namespace ByensGaader.Api.Features.Authentication;

internal sealed record AppleNotificationRequest(string Payload);

/// <summary>Modtager Apples signerede kontoændringer. Endpointet er offentligt,
/// men ingen handling udføres, før JWS-signatur, issuer og audience er valideret.</summary>
internal sealed class AppleNotificationEndpoint(
    IAppleIdentityValidator validator,
    IAuthenticationRepository repository,
    AccountLifecycleService lifecycle)
    : Endpoint<AppleNotificationRequest>
{
    public override void Configure()
    {
        Post("/auth/apple/notifications");
        AllowAnonymous();
        Description(builder => builder.WithTags("Authentication"));
    }

    public override async Task HandleAsync(
        AppleNotificationRequest request, CancellationToken ct)
    {
        var notification = await validator.ValidateNotificationAsync(
            request.Payload, ct);
        if (notification is null)
        {
            AddError("Apple-notifikationen kunne ikke valideres.");
            await SendErrorsAsync(StatusCodes.Status400BadRequest, cancellation: ct);
            return;
        }

        if (notification.EventType is "consent-revoked" or "account-deleted")
        {
            var identity = await repository.GetIdentityAsync(
                "apple", notification.SubjectHash, ct);
            if (identity is not null)
            {
                // Apples privacyhændelse har forrang for en redaktionel rolle.
                // Hvis sidste Admin rammes, skal en ny bootstrap håndteres som
                // en eksplicit driftsopgave frem for at beholde persondata.
                var result = await lifecycle.DeleteFromProviderAsync(identity.AccountId, ct);
                if (result is DeleteAccountResult.Conflict)
                {
                    AddError("Kontoen blev ændret samtidig; Apple kan prøve igen.");
                    await SendErrorsAsync(
                        StatusCodes.Status503ServiceUnavailable, cancellation: ct);
                    return;
                }
            }
        }

        await SendNoContentAsync(ct);
    }
}
