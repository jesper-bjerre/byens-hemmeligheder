import {
  AfterViewInit,
  Component,
  ElementRef,
  EventEmitter,
  OnDestroy,
  Output,
  ViewChild,
  effect,
  inject,
} from '@angular/core';
import * as L from 'leaflet';
import { ContentService } from '../core/content.service';
import { GameStoreService } from '../core/game-store.service';
import { LocationService } from '../core/location.service';
import { Mission } from '../core/models';

@Component({
  selector: 'app-explore-map',
  standalone: true,
  template: '<div #map class="map" aria-label="Kort over gådernes placering"></div>',
  styles: ['.map { width:100%; height:100%; min-height:420px; background:#dce7df; }'],
})
export class ExploreMap implements AfterViewInit, OnDestroy {
  @ViewChild('map', { static: true }) element!: ElementRef<HTMLElement>;
  @Output() missionSelected = new EventEmitter<Mission>();
  private readonly content = inject(ContentService);
  private readonly game = inject(GameStoreService);
  private readonly location = inject(LocationService);
  private map?: L.Map;
  private missionLayer = L.layerGroup();
  private playerLayer = L.layerGroup();
  private fitted = false;

  constructor() {
    effect(() => {
      this.content.playableMissions();
      this.game.completedIds();
      this.location.fix();
      if (this.map) queueMicrotask(() => this.render());
    });
  }

  ngAfterViewInit(): void {
    this.map = L.map(this.element.nativeElement, {
      zoomControl: false,
      attributionControl: true,
    }).setView([55.72, 9.59], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '© OpenStreetMap',
    }).addTo(this.map);
    L.control.zoom({ position: 'bottomright' }).addTo(this.map);
    this.missionLayer.addTo(this.map);
    this.playerLayer.addTo(this.map);
    this.render();
  }

  ngOnDestroy(): void {
    this.map?.remove();
  }

  centreOnPlayer(): void {
    const fix = this.location.fix();
    if (fix) this.map?.flyTo([fix.latitude, fix.longitude], 16, { duration: 0.8 });
  }

  private render(): void {
    if (!this.map) return;
    this.missionLayer.clearLayers();
    this.playerLayer.clearLayers();
    const points: L.LatLngExpression[] = [];
    for (const mission of this.content.playableMissions()) {
      const place = this.content.locationFor(mission);
      if (place?.latitude == null || place.longitude == null) continue;
      const point: L.LatLngExpression = [place.latitude, place.longitude];
      points.push(point);
      const solved = this.game.isCompleted(mission);
      const icon = L.divIcon({
        className: '',
        iconSize: [46, 46],
        iconAnchor: [23, 42],
        html: `<span class="mission-pin ${solved ? 'solved' : ''}"><b>${solved ? '✓' : '?'}</b></span>`,
      });
      const marker = L.marker(point, { icon, title: mission.title }).on('click', () =>
        this.missionSelected.emit(mission),
      );
      marker.addTo(this.missionLayer);
    }
    const fix = this.location.fix();
    if (fix) {
      const point: L.LatLngExpression = [fix.latitude, fix.longitude];
      L.circle(point, {
        radius: fix.accuracy,
        color: '#2f73a5',
        fillColor: '#8fc8e9',
        fillOpacity: 0.16,
        weight: 1,
      }).addTo(this.playerLayer);
      L.circleMarker(point, {
        radius: 8,
        color: 'white',
        weight: 3,
        fillColor: '#2878b4',
        fillOpacity: 1,
      }).addTo(this.playerLayer);
    }
    if (!this.fitted && points.length) {
      this.map.fitBounds(L.latLngBounds(points), { padding: [55, 55], maxZoom: 14 });
      this.fitted = true;
    }
  }
}
