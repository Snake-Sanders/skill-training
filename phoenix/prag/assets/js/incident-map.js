import L from "../vendor/leaflet";

class IncidentMap {
  constructor(element, center, markerClickedCallback) {
    this.map = L.map(element).setView(center, 13);

    L.tileLayer(
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      {
        maxZoom: 18,
        attribution:
          '©<a href="https://www.openstreetmap.org/copyright/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
      }
    ).addTo(this.map);

    this.markerClickedCallback = markerClickedCallback;
  }

  addMarker(incident) {
    const marker_options = {
      incidentId: incident.id,
      icon: L.icon({
        iconUrl: 'images/map/marker-icon.png',
        shadowUrl: 'images/map/marker-shadow.png'
      })
    }
    
    const marker =
      L.marker([incident.lat, incident.lng], marker_options)
        .addTo(this.map)
        .bindPopup(incident.description)

    marker.on("click", e => {
      marker.openPopup();
      this.markerClickedCallback(e);
    });

    return marker;
  }

  highlightMarker(incident) {
    const marker = this.getMarkerForIncident(incident);

    marker.openPopup();

    this.map.panTo(marker.getLatLng());
  }

  getMarkerForIncident(incident) {
    let markerLayer;
    this.map.eachLayer(layer => {
      if (layer instanceof L.Marker) {
        const markerPosition = layer.getLatLng();
        if (markerPosition.lat === incident.lat &&
          markerPosition.lng === incident.lng) {
          markerLayer = layer;
        }
      }
    });

    return markerLayer;
  }
}

export default IncidentMap;
