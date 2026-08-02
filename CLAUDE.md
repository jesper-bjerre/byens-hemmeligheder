# Byens Hemmeligheder — instruktioner til Claude Code

**Læs [AGENTS.md](./AGENTS.md).** Den gælder også for Claude Code, og den er
den fulde arbejdsinstruks.

Instruktionerne stod tidligere her. De blev flyttet, fordi de gælder uanset
hvilken klient der arbejder i repoet, og fordi to filer med den samme politik
driver fra hinanden. Én fil, ét sted.

Det vigtigste i den, hvis du kun læser én ting:

- **Repoet er PUBLIC.** En hemmelighed, der committes og derefter slettes, er
  stadig kompromitteret. Gitignore **før** filen oprettes, og bekræft med
  `git check-ignore -v <sti>`.
- Kontrollér `git status --porcelain` og `git diff --cached` før hvert commit.
  `git add -A` er farlig her.
- `.specify/memory/constitution.md` er projektets øverste normative dokument.
  Ved konflikt gælder forfatningen.
- Hvad der arbejdes på nu står i
  [docs/plans/koereplan.md](./docs/plans/koereplan.md).
