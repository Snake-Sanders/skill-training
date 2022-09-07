import L from "../vendor/leaflet";

class IncidentMap {
  constructor(element, center, markerClickedCallback) {
    this.map = L.map(element).setView(center, 13);

    // const accessToken = "your-access-token-goes-here";

    L.tileLayer(
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      {
        maxZoom: 18,
        attribution: 
        '©<a href="https://www.openstreetmap.org/copyright/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
        // id: "mapbox/streets-v11",
        // zoomOffset: -1,
        // referrerPolicy: false
        // accessToken: accessToken,
        // tileSize: 512,
      }
    ).addTo(this.map);

    this.markerClickedCallback = markerClickedCallback;
  }

  addMarker(incident) {
    const marker =
      L.marker([incident.lat, incident.lng], { incidentId: incident.id })
        .addTo(this.map)
        .bindPopup(incident.description)

    marker.on("click", e => {
      marker.openPopup();
      this.markerClickedCallback(e);
    });

    return marker;
  }

  highlightMarker(incident) {
    const marker = this.markerForIncident(incident);

    marker.openPopup();

    this.map.panTo(marker.getLatLng());
  }

  markerForIncident(incident) {
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
