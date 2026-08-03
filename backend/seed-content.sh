#!/usr/bin/env bash
#
# Lægger repoets indhold op i en blob-container.
#
#   ./backend/seed-content.sh --dry-run
#   ./backend/seed-content.sh byensgaaderd content-local authoring-local
#
# Bruges til at fylde en tom container første gang, og til at sætte en
# DEV-container tilbage til det, der står i repoet.
#
# ## Hvad den ikke gør
#
# Den rører ikke `audit.jsonl`. Revisionssporet hører til det sted, det blev
# skrevet — at overskrive det med repoets udgave ville slette svaret på, hvem
# der havde rettet hvad.
#
# ## Hvorfor `--overwrite` er bevidst
#
# Medier overskrives aldrig gennem API'et, fordi de sendes med et års cache.
# Dette script går uden om API'et og bruges kun til at så en container. Kør det
# aldrig mod produktion, når først quizmasterne er begyndt at rette — det ville
# skrive deres arbejde tilbage til repoets udgave.

set -euo pipefail

DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN=true
  shift
fi

ACCOUNT="${1:-}"
PUBLIC_CONTAINER="${2:-content}"
AUTHORING_CONTAINER="${3:-authoring}"
if [ "$DRY_RUN" = false ] && [ -z "$ACCOUNT" ]; then
  echo "Brug: seed-content.sh [--dry-run] <storage-konto> [public-container] [authoring-container]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/contracts/content"
PACK="$SOURCE/da-DK/content-pack.json"

if [ ! -d "$SOURCE" ]; then
  echo "Fandt ikke $SOURCE" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq skal være installeret for at validere og splitte indholdspakken." >&2
  exit 1
fi

SPLIT_ROOT="$(mktemp -d)"
trap 'rm -rf "$SPLIT_ROOT"' EXIT
AUTHORING_SOURCE="$SPLIT_ROOT/authoring/da-DK"
mkdir -p "$AUTHORING_SOURCE/missions" "$AUTHORING_SOURCE/media" "$AUTHORING_SOURCE/sources"

missing_locations="$(jq '[.missions[] as $mission | select(
  ([.locations[].id] | index($mission.locationId)) == null)] | length' "$PACK")"
if [ "$missing_locations" -ne 0 ]; then
  echo "Pakken har $missing_locations opgaver uden et sted og kan ikke splittes." >&2
  exit 1
fi

while IFS= read -r id; do
  if [[ ! "$id" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "Ugyldigt mission-id: $id" >&2
    exit 1
  fi
  jq --arg id "$id" '
    . as $pack
    | ($pack.missions[] | select(.id == $id)) as $mission
    | ($pack.locations[] | select(.id == $mission.locationId)) as $location
    | {schemaVersion: $pack.schemaVersion, mission: $mission, location: $location}
  ' "$PACK" > "$AUTHORING_SOURCE/missions/$id.json"
done < <(jq -r '.missions[].id' "$PACK")

for collection in media sources; do
  while IFS= read -r id; do
    if [[ ! "$id" =~ ^[A-Za-z0-9._-]+$ ]]; then
      echo "Ugyldigt $collection-id: $id" >&2
      exit 1
    fi
    jq --arg collection "$collection" --arg id "$id" \
      '.[$collection][] | select(.id == $id)' "$PACK" \
      > "$AUTHORING_SOURCE/$collection/$id.json"
  done < <(jq -r --arg collection "$collection" '.[$collection][].id' "$PACK")
done

mission_count="$(find "$AUTHORING_SOURCE/missions" -type f -name '*.json' | wc -l | tr -d ' ')"
media_count="$(find "$AUTHORING_SOURCE/media" -type f -name '*.json' | wc -l | tr -d ' ')"
source_count="$(find "$AUTHORING_SOURCE/sources" -type f -name '*.json' | wc -l | tr -d ' ')"
echo "Dry-run: $mission_count opgaver, $mission_count steder, $media_count mediebeskrivelser og $source_count kilder."

if [ "$DRY_RUN" = true ]; then
  echo "Ingen blobs er skrevet."
  exit 0
fi

echo "Sår offentlig fixture i $ACCOUNT/$PUBLIC_CONTAINER"
echo

# `--auth-mode login` frem for en nøgle. Der er ingen nøgle at lække, og den
# rolle, du allerede har på kontoen, er den, der bruges.
#
# `--pattern` frem for at udelade: `upload-batch` kan filtrere på det, der skal
# med, men ikke på det, der skal udelades. Mønstrene her rammer indholdspakken
# og medierne — og ikke `audit.jsonl`.
for pattern in "*/content-pack.json" "*/media/*"; do
  az storage blob upload-batch \
    --account-name "$ACCOUNT" \
    --destination "$PUBLIC_CONTAINER" \
    --source "$SOURCE" \
    --pattern "$pattern" \
    --auth-mode login \
    --overwrite \
    --output none
done

# Authoring skal være privat. Kommandoen angiver derfor aldrig public access.
# `--overwrite false` gør migrationen sikker at genstarte: eksisterende
# redaktionelle objekter kan ikke erstattes af en gammel fixture.
az storage container create \
  --account-name "$ACCOUNT" \
  --name "$AUTHORING_CONTAINER" \
  --auth-mode login \
  --output none
az storage blob upload-batch \
  --account-name "$ACCOUNT" \
  --destination "$AUTHORING_CONTAINER" \
  --source "$SPLIT_ROOT/authoring" \
  --pattern "*/*/*.json" \
  --auth-mode login \
  --overwrite false \
  --output none

echo
echo "Oppe:"
az storage blob list \
  --account-name "$ACCOUNT" \
  --container-name "$PUBLIC_CONTAINER" \
  --auth-mode login \
  --query "sort_by([].{navn:name, bytes:properties.contentLength}, &navn)" \
  --output table

cat <<'EOF'

Bemærk: indholdshashen står ikke som metadata på blobs, der er lagt op sådan
her. `BlobContentStore` regner den så af indholdet ved første læsning — ETag'en
bliver den samme, det koster bare én ekstra hentning, indtil API'et selv har
skrevet filen igen.
EOF
