#!/usr/bin/env bash
#
# Lægger repoets indhold op i en blob-container.
#
#   ./backend/seed-content.sh byensgaaderd
#   ./backend/seed-content.sh byensgaaderp content
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

ACCOUNT="${1:?Brug: seed-content.sh <storage-konto> [container]}"
CONTAINER="${2:-content}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/contracts/content"

if [ ! -d "$SOURCE" ]; then
  echo "Fandt ikke $SOURCE" >&2
  exit 1
fi

echo "Sår $SOURCE → $ACCOUNT/$CONTAINER"
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
    --destination "$CONTAINER" \
    --source "$SOURCE" \
    --pattern "$pattern" \
    --auth-mode login \
    --overwrite \
    --output none
done

echo
echo "Oppe:"
az storage blob list \
  --account-name "$ACCOUNT" \
  --container-name "$CONTAINER" \
  --auth-mode login \
  --query "sort_by([].{navn:name, bytes:properties.contentLength}, &navn)" \
  --output table

cat <<'EOF'

Bemærk: indholdshashen står ikke som metadata på blobs, der er lagt op sådan
her. `BlobContentStore` regner den så af indholdet ved første læsning — ETag'en
bliver den samme, det koster bare én ekstra hentning, indtil API'et selv har
skrevet filen igen.
EOF
