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
  { path: '', component: Explore, title: 'Byens Gåder' },
  { path: 'opgave/:id', component: MissionDetail, title: 'Opgave · Byens Gåder' },
  { path: 'opgave/:id/find', component: Approach, title: 'Find stedet · Byens Gåder' },
  { path: 'opgave/:id/spil', component: Play, title: 'Løs gåden · Byens Gåder' },
  { path: 'opgave/:id/loest', component: Reward, title: 'Løst · Byens Gåder' },
  { path: 'point', component: Scoreboard, title: 'Dine point · Byens Gåder' },
  { path: 'privatliv', component: Privacy, title: 'Privatlivspolitik · Vejles Gåder' },
  { path: 'vilkaar', component: Terms, title: 'Vilkår · Vejles Gåder' },
  { path: '**', redirectTo: '' },
];
