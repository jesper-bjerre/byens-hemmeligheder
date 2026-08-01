#!/usr/bin/env python3
"""Skriver indholdspakken ud som et læsbart arkiv.

    python3 contracts/arkiver-indhold.py

Henter fra kilden — blob gennem API'et — og skriver
`docs/arkiv/indholdspakke.md`.

## Hvorfor et arkiv

Indholdet bor i Azure Blob Storage. Repoet er ikke længere kilden, og det er
med vilje: quizmasterne retter gennem appen, ikke gennem git. Men et
indholdspakke i JSON kan ingen læse hen over skulderen, og en blob-container
har ingen historik, nogen gider bladre i.

Arkivet er derfor to ting på én gang: en læsbar gengivelse af hver opgave —
gåde, facit, hints og belønning — og hele pakken som JSON til sidst, så
ingenting går tabt. Kør scriptet igen, og git viser præcis, hvad der ændrede
sig, og hvem der gjorde det.

Det er **ikke** en backup, der kan spilles tilbage. Vil du sætte en container
tilbage til repoets udgave, er det `backend/seed-content.sh`.
"""

import datetime
import json
import pathlib
import sys
import urllib.request

API = "https://byensgaader-api-p.azurewebsites.net"
LOCALE = "da-DK"


def hent(kilde: str):
    """Pakken og dens ETag. Fra API'et, eller fra en fil hvis der gives en."""
    if kilde.startswith("http"):
        request = urllib.request.Request(f"{kilde}/content/{LOCALE}/pack")
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response), response.headers.get("ETag", "ukendt")
    return json.load(open(kilde)), "(fra fil)"


def afsnit(titel: str, niveau: int = 2) -> str:
    return f"\n{'#' * niveau} {titel}\n\n"


def render(pack: dict, etag: str, kilde: str) -> str:
    steder = {location["id"]: location for location in pack.get("locations", [])}
    medier = {asset["id"]: asset for asset in pack.get("media", [])}
    kilder = {source["id"]: source for source in pack.get("sources", [])}

    ud = [
        "# Indholdspakken — arkiv\n",
        "> Genereret af `contracts/arkiver-indhold.py`. Rediger ikke i hånden.\n",
        "\n| | |\n|---|---|\n",
        f"| Kilde | `{kilde}` |\n",
        f"| Hentet | {datetime.date.today().isoformat()} |\n",
        f"| Indholdsversion | `{pack.get('contentVersion', '?')}` |\n",
        f"| ETag | `{etag}` |\n",
        f"| Opgaver | {len(pack.get('missions', []))} |\n",
        f"| Medier | {len(pack.get('media', []))} |\n",
        "\nIndholdet bor i Azure Blob Storage. Denne fil er en læsbar gengivelse,\n"
        "ikke kilden — se `contracts/README.md`.\n",
    ]

    for mission in pack.get("missions", []):
        sted = steder.get(mission.get("locationId"), {})
        ud.append(afsnit(mission.get("title", "Uden titel")))
        ud.append(f"*{mission.get('description', '')}*\n\n")

        ud.append("| | |\n|---|---|\n")
        ud.append(f"| Id | `{mission.get('id')}` |\n")
        ud.append(f"| Status | {mission.get('status')} |\n")
        ud.append(f"| Sted | {sted.get('name', '?')}, {sted.get('address', '?')} |\n")
        ud.append(f"| Postnummer | {sted.get('postalCode', '?')} |\n")
        ud.append(f"| Koordinat | {sted.get('latitude')}, {sted.get('longitude')} |\n")
        ud.append(f"| Sværhedsgrad | {mission.get('difficulty')} af 5 |\n")
        ud.append(f"| Grundpoint | {mission.get('basePoints')} |\n")

        if mission.get("fictionLabel"):
            ud.append(f"\n**Fiktionsmarkering.** {mission['fictionLabel']}\n")

        for step in mission.get("steps", []):
            regel = step.get("answerRule", {})
            if not regel:
                continue
            ud.append(afsnit(f"Spørgsmål — {step.get('title', '')}", 3))
            if step.get("question"):
                ud.append(f"{step['question']}\n\n")
            ud.append(f"- **Facit:** `{regel.get('canonicalAnswer')}`\n")
            accepteret = ", ".join(f"`{a}`" for a in regel.get("acceptedAnswers", []))
            ud.append(f"- **Accepteres også:** {accepteret or '—'}\n")

            for near in regel.get("nearMissResponses", []):
                ud.append(f"- **Nær ved `{near['answer']}`:** {near['feedback']}\n")

        if mission.get("hints"):
            ud.append(afsnit("Hints", 3))
            for hint in sorted(mission["hints"], key=lambda h: h.get("order", 0)):
                ud.append(
                    f"{hint.get('order')}. **{hint.get('title')}** "
                    f"(−{hint.get('penaltyPercent')} %) — {hint.get('text')}\n")

        afslutning = mission.get("completion", {})
        if afslutning:
            ud.append(afsnit("Belønning", 3))
            ud.append(f"**{afslutning.get('headline')}** — {afslutning.get('subheadline')}\n\n")
            ud.append(f"{afslutning.get('message')}\n\n")
            ud.append(f"*{afslutning.get('historyFact')}*\n")

        if mission.get("cards"):
            ud.append(afsnit("Kort", 3))
            for card in sorted(mission["cards"], key=lambda c: c.get("order", 0)):
                fil = medier.get(card.get("mediaId"), {}).get("filename", "—")
                tekst = (card.get("text") or "").replace("\n", " ")
                ud.append(f"{card.get('order')}. `{fil}` — {tekst}\n")

        if mission.get("sourceIds"):
            ud.append(afsnit("Kilder", 3))
            for sid in mission["sourceIds"]:
                s = kilder.get(sid, {})
                ud.append(f"- [{s.get('title', sid)}]({s.get('url', '')}) — {s.get('publisher', '')}\n")

    ud.append(afsnit("Medier og rettigheder"))
    ud.append("| Fil | Slags | Ejer | Licens |\n|---|---|---|---|\n")
    for asset in sorted(pack.get("media", []), key=lambda a: a.get("filename", "")):
        ud.append(
            f"| `{asset.get('filename')}` | {asset.get('kind')} | "
            f"{asset.get('owner')} | {asset.get('licence')} |\n")

    ud.append(afsnit("Hele pakken"))
    ud.append("Til fuldstændighed. Det er denne, der ligger i blob.\n\n")
    ud.append("```json\n")
    ud.append(json.dumps(pack, ensure_ascii=False, indent=2, sort_keys=True))
    ud.append("\n```\n")

    return "".join(ud)


def main() -> int:
    kilde = sys.argv[1] if len(sys.argv) > 1 else API
    pack, etag = hent(kilde)

    target = pathlib.Path(__file__).resolve().parents[1] / "docs/arkiv/indholdspakke.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(render(pack, etag, kilde), encoding="utf-8")

    print(f"Skrev {target} — {len(pack.get('missions', []))} opgaver, ETag {etag}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
