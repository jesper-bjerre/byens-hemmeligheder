#!/usr/bin/env bash
# Starter backenden, så appen virker i simulatoren.
#
# Porten skal stemme med BH_CONTENT_BASE_URL i iOS/Config/Local.xcconfig.
# Gør den ikke det, henter appen ingenting, og fejlen ser ud som manglende
# indhold frem for en forkert port.
set -euo pipefail

PORT="${PORT:-5199}"

# .NET ligger i hjemmemappen, fordi Homebrews cask kræver sudo.
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"

cd "$(dirname "$0")"

EXPECTED="http://localhost:$PORT"
CONFIGURED=$(grep -h "BH_CONTENT_BASE_URL" ../iOS/Config/Local.xcconfig 2>/dev/null \
  | tail -1 | sed 's/.*= *//' | sed 's|/\$()/|//|' || true)

if [ -n "$CONFIGURED" ] && [ "$CONFIGURED" != "$EXPECTED" ]; then
  echo "⚠️  Appen peger på '$CONFIGURED', men serveren starter på '$EXPECTED'."
  echo "    Ret BH_CONTENT_BASE_URL i iOS/Config/Local.xcconfig, eller kør: PORT=<port> ./run.sh"
  echo
fi

echo "Byens Gåder — backend"
echo "  indhold:  $EXPECTED/content/da-DK/pack"
echo "  status:   $EXPECTED/health"
echo "  swagger:  $EXPECTED/swagger"
echo "  stop med Ctrl-C"
echo

# Development-miljø, så Swagger er med. Forespørgsler logges, så det kan ses,
# at appen faktisk ringer — uden det ligner en tavs server en app, der ikke
# prøver.
env ASPNETCORE_ENVIRONMENT=Development \
    "Logging__LogLevel__Microsoft.AspNetCore=Information" \
    dotnet run --project src/ByensGaader.Api --urls "$EXPECTED"
