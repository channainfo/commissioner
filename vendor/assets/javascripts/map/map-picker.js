const MapPicker = {
  selector: ".map-selector",
  init: function () {
    this.registerProperties();
    this.initMap();
    this.initButtons();
    this.registerEventHandler();
  },
  registerProperties: function () {
    this.element = $(this.selector);

    const lat = parseFloat(this.element.data("lat"));
    const lon = parseFloat(this.element.data("lon"));

    this.initialMap = { lat: lat, lng: lon };
    this.map = null;
    this.marker = null;
    this.zoom = 18;
  },
  initButtons: function () {
    MapControlButton.init(this);
  },
  registerEventHandler: function () {
    self = this;
    $("[id$='_lat']").on("change", function () {
      self.refreshMarker();
    });
    $("[id$='_lon']").on("change", function () {
      self.refreshMarker();
    });
  },
  refreshFields: function () {
    const position = this.marker.getPosition();
    $("[id$='_lat']").val(position.lat);
    $("[id$='_lon']").val(position.lng);
  },
  initMap: function () {
    this.map = new google.maps.Map(document.getElementById("map"), {
      zoom: this.zoom,
      center: this.initialMap,
    });

    this.marker = new google.maps.Marker({
      position: this.initialMap,
      map: this.map,
      optimized: false,
    });
  },
  refreshMarker: function () {
    const lat = $("[id$='_lat']").val();
    const lon = $("[id$='_lon']").val();
    this.marker.setPosition(new google.maps.LatLng(lat, lon));
    this.map.setCenter(this.marker.getPosition());
  },
};

window.initMap = function () {
  MapPicker.init();
};
