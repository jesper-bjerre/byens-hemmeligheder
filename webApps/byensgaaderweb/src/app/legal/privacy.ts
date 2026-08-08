import { Component } from '@angular/core';
import { LegalPage } from './legal-page';

@Component({
  selector: 'app-privacy',
  imports: [LegalPage],
  template: `
    <app-legal-page title="Privatlivspolitik">
      <p>
        Vejles Koder kan bruges uden en konto. Denne politik forklarer, hvilke data der
        behandles, hvis du vælger at logge ind, og hvordan appens positionsfunktion virker.
      </p>

      <h2>Dataansvarlig</h2>
      <p>
        Jesper Hyldenbrandt Bjerre er dataansvarlig for Vejles Koder.
        Kontaktadressen står nederst på siden.
      </p>

      <h2>Hvis du spiller som gæst</h2>
      <p>
        Din spilfremgang gemmes lokalt på din enhed. Der oprettes ingen konto, og du
        kommer ikke på highscorelisterne.
      </p>

      <h2>Hvis du logger ind med Apple</h2>
      <p>Vi behandler kun de oplysninger, der er nødvendige for kontooplevelsen:</p>
      <ul>
        <li>et tilfældigt internt konto-id og en beskyttet reference til din Apple-konto,</li>
        <li>din verificerede e-mailadresse, hvis Apple udleverer den,</li>
        <li>kontoens rolle og status,</li>
        <li>dine favoritter, løste opgaver, point og nødvendige sessionstider.</li>
      </ul>
      <p>
        Oplysningerne bruges til login, synkronisering, highscore og sikker drift. De
        sælges ikke, bruges ikke til reklamer og bruges ikke til sporing på tværs af apps.
      </p>

      <h2>Position</h2>
      <p>
        Appen bruger din aktuelle position på telefonen for at afgøre, om du står ved en
        opgave. Position og GPS-spor sendes ikke til serveren og gemmes ikke som historik.
      </p>

      <h2>Leverandører og opbevaring</h2>
      <p>
        Apple leverer loginfunktionen. Microsoft Azure bruges til hosting og lagring.
        Kontodata opbevares, mens kontoen er aktiv, eller så længe det er nødvendigt for
        sikker drift og lovpligtige krav.
      </p>

      <h2>Dine valg og rettigheder</h2>
      <p>
        Login er frivilligt. Du kan logge ud eller slette en almindelig spillerkonto
        direkte under Profil i iPhone-appen. Sletning fjerner loginforbindelsen og dine
        personlige serverdata. Du kan også kontakte os om indsigt, rettelse, sletning,
        begrænsning eller indsigelse. Du kan klage til Datatilsynet.
      </p>
    </app-legal-page>
  `,
})
export class Privacy {}
