import { Component } from '@angular/core';
import { LegalPage } from './legal-page';

@Component({
  selector: 'app-terms',
  imports: [LegalPage],
  template: `
    <app-legal-page title="Vilkår for brug">
      <p>
        Ved at bruge Vejles Gåder accepterer du disse enkle vilkår. Appen er en
        stedsbaseret oplevelse og kan bruges som gæst uden login.
      </p>

      <h2>Sikkerhed og færdsel</h2>
      <p>
        Se dig for, følg skiltning og færdselsregler, respekter afspærringer og privat
        ejendom, og hold afstand til trafik og vand. Børn bør bruge appen sammen med en
        ansvarlig voksen. En opgave er aldrig en opfordring til at gå et farligt eller
        utilgængeligt sted hen.
      </p>

      <h2>Konto og adfærd</h2>
      <p>
        Login med Apple er frivilligt og bruges til favoritter, point og highscore. Du må
        ikke forsøge at omgå adgangskontrol, manipulere point eller bruge et profilnavn,
        der krænker andre. Misbrug kan medføre, at en konto blokeres.
      </p>

      <h2>Indhold og tilgængelighed</h2>
      <p>
        Opgaver og oplysninger leveres som en oplevelse og kan ændres eller fjernes.
        Steder, åbningstider, adgang og omgivelser kan ændre sig uden varsel. Vi bestræber
        os på korrekt indhold, men garanterer ikke, at alle oplysninger altid er komplette.
      </p>

      <h2>Rettigheder og ansvar</h2>
      <p>
        Appens design, tekst og software må ikke kopieres eller videredistribueres uden
        tilladelse, medmindre loven giver ret til det. Intet i vilkårene begrænser ansvar,
        som ikke lovligt kan begrænses efter dansk ret.
      </p>

      <h2>Ændringer</h2>
      <p>
        Vilkårene kan blive opdateret, når funktioner eller regler ændres. Datoen øverst
        viser den seneste version. Dansk ret gælder for vilkårene.
      </p>
    </app-legal-page>
  `,
})
export class Terms {}
