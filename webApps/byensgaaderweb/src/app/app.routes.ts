import { Routes } from '@angular/router';
import { Approach } from './approach/approach';
import { Explore } from './explore/explore';
import { MissionDetail } from './mission-detail/mission-detail';
import { Play } from './play/play';
import { Reward } from './reward/reward';
import { Scoreboard } from './scoreboard/scoreboard';
import { Privacy } from './legal/privacy';
import { Terms } from './legal/terms';

export const routes: Routes = [
  { path: '', component: Explore, title: 'Vejles Koder' },
  { path: 'opgave/:id', component: MissionDetail, title: 'Opgave · Vejles Koder' },
  { path: 'opgave/:id/find', component: Approach, title: 'Find stedet · Vejles Koder' },
  { path: 'opgave/:id/spil', component: Play, title: 'Løs koden · Vejles Koder' },
  { path: 'opgave/:id/loest', component: Reward, title: 'Løst · Vejles Koder' },
  { path: 'point', component: Scoreboard, title: 'Dine point · Vejles Koder' },
  { path: 'privatliv', component: Privacy, title: 'Privatlivspolitik · Vejles Koder' },
  { path: 'vilkaar', component: Terms, title: 'Vilkår · Vejles Koder' },
  { path: '**', redirectTo: '' },
];
