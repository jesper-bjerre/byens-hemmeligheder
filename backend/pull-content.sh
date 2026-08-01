#!/usr/bin/env bash
#
# Henter indholdet fra kilden ned i repoet.
#
#   ./backend/pull-content.sh byensgaaderd
#
# Den modsatte vej af `seed-content.sh`.
#
# ## Hvorfor der overhovedet ligger en kopi i repoet
#
# Blob er kilden. Men testene skal kunne køre uden en Azure-konto og uden net —
# `swift test` i BHKit, admin-appens 62 tests og backendens egne læser alle
# `contracts/content/da-DK/content-pack.json`. En test, der henter over
# netværket, fejler tilfældigt og bliver slået fra inden for en uge.
#
# Kopien i repoet er derfor en **fixtur**, ikke kilden. Den opdateres med dette
# script, når quizmasterne har rettet noget, testene bør kende til.
#
# ## Hvad du gør bagefter
#
#   swift test --package-path iOS/Packages/BHKit
#   python3 contracts/arkiver-indhold.py
#
# Den første siger, om det nye indhold stadig overholder kontrakten. Den anden
# opdaterer det læsbare arkiv, så git viser hvad der ændrede sig.

set -euo pipefail

ACCOUNT="${1:?Brug: pull-content.sh <storage-konto> [container]}"
CONTAINER="${2:-content}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT/contracts/content"

echo "Henter $ACCOUNT/$CONTAINER → $TARGET"
echo

# Kun pakken og medierne. `audit.jsonl` bærer navne på quizmastere og
# tidspunkter for deres arbejde — personoplysninger, som ikke hører hjemme i et
# public repo (forfatningens princip VI). Den er også gitignoreret.
for pattern in "*/content-pack.json" "*/media/*"; do
  az storage blob download-batch \
    --account-name "$ACCOUNT" \
    --source "$CONTAINER" \
    --destination "$TARGET" \
    --pattern "$pattern" \
    --auth-mode login \
    --overwrite \
    --output none
done

echo "Hentet. Forskellen mod det, der stod i repoet:"
echo
git -C "$ROOT" status --porcelain contracts/content || true

cat <<'EOF'

Kør derefter:

  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
    swift test --package-path iOS/Packages/BHKit
  python3 contracts/arkiver-indhold.py
EOF
