import {
  AfterViewInit,
  Component,
  ElementRef,
  Input,
  OnChanges,
  OnDestroy,
  ViewChild,
} from '@angular/core';
import * as L from 'leaflet';

@Component({
  selector: 'app-location-map',
  standalone: true,
  template: '<div #map class="map" aria-label="Kort over opgavens startsted"></div>',
  styleUrl: './location-map.scss',
})
export class LocationMap implements AfterViewInit, OnChanges, OnDestroy {
  @Input({ required: true }) latitude!: number;
  @Input({ required: true }) longitude!: number;
  @Input() radius = 45;
  @ViewChild('map', { static: true }) mapElement!: ElementRef<HTMLDivElement>;

  private map?: L.Map;
  private marker?: L.Marker;
  private circle?: L.Circle;

  ngAfterViewInit(): void {
    this.map = L.map(this.mapElement.nativeElement, {
      scrollWheelZoom: false,
      zoomControl: true,
    }).setView([this.latitude, this.longitude], 17);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap-bidragsydere',
    }).addTo(this.map);
    this.draw();
  }

  ngOnChanges(): void {
    this.draw();
  }

  ngOnDestroy(): void {
    this.map?.remove();
  }

  private draw(): void {
    if (!this.map || !Number.isFinite(this.latitude) || !Number.isFinite(this.longitude)) return;
    const point = L.latLng(this.latitude, this.longitude);
    this.marker?.remove();
    this.circle?.remove();
    this.marker = L.marker(point, {
      interactive: false,
      icon: L.divIcon({
        className: 'start-marker',
        html: '<span aria-hidden="true"></span>',
        iconSize: [28, 28],
        iconAnchor: [14, 14],
      }),
    }).addTo(this.map);
    this.circle = L.circle(point, {
      radius: this.radius || 0,
      color: '#e76f3d',
      fillColor: '#e76f3d',
      fillOpacity: 0.12,
      weight: 2,
      interactive: false,
    }).addTo(this.map);
    this.map.setView(point, 17, { animate: false });
  }
}
