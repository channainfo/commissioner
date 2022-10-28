// https://developers.google.com/maps/documentation/javascript/geolocation
// https://developers.google.com/maps/documentation/javascript/examples/control-custom

const MapControlButton = {
  init: function (picker) {
    this.initialMap = picker.initialMap;
    this.map = picker.map;
    this.marker = picker.marker;
    this.picker = picker;
    this.initButtons();
  },
  initButtons: function () {
    const buttons = this.controlButtons();

    for (const [index, button] of buttons.entries()) {
      if (index == 0) {
        button.style.borderTopLeftRadius = "2px";
        button.style.borderBottomLeftRadius = "2px";
      }

      if (index == buttons.length - 1) {
        button.style.borderTopRightRadius = "2px";
        button.style.borderBottomRightRadius = "2px";
      }

      this.map.controls[google.maps.ControlPosition.TOP_LEFT].push(button);
    }
  },
  controlButtons: function () {
    infoWindow = new google.maps.InfoWindow();
    const self = this;

    const currentLocationButton = this.createCenterControl(
      "Current position",
      function (_) {
        if (navigator.geolocation) self.requestCurrentPosition();
      }
    );

    const resetButton = this.createCenterControl("Reset", function (_) {
      const cachePosition = {
        lat: self.initialMap.lat,
        lon: self.initialMap.lng,
      };
      self.moveToPosition(cachePosition, "Initial position");
    });

    return [currentLocationButton, resetButton];
  },
  moveToPosition: function (position, tooltip) {
    this.marker.setPosition(new google.maps.LatLng(position.lat, position.lon));
    this.marker.setTitle(tooltip);

    this.map.setCenter(this.marker.getPosition());
    this.map.setZoom(this.picker.zoom);

    this.picker.refreshFields();
  },
  requestCurrentPosition: function () {
    const self = this;
    navigator.geolocation.getCurrentPosition(
      (position) => {
        currentPosition = {
          lat: position.coords.latitude,
          lon: position.coords.longitude,
        };
        self.moveToPosition(currentPosition, "Current Position");
      },
      console.error,
      { enableHighAccuracy: false, timeout: 10000, maximumAge: Infinity }
    );
  },
  createCenterControl: function (textContent, event) {
    const controlButton = document.createElement("button");

    // Set CSS for the control.
    controlButton.style.background = "none padding-box rgb(255, 255, 255)";
    controlButton.style.border = "0px";
    controlButton.style.margin = "10px 0px 0px 0px";
    controlButton.style.padding = "0px 17px";
    controlButton.style.position = "relative";
    controlButton.style.height = "40px";
    controlButton.style.color = "rgb(86, 86, 86)";
    controlButton.style.fontFamily = "Roboto,Arial,sans-serif";
    controlButton.style.fontSize = "18px";
    controlButton.style.boxShadow = "rgb(0 0 0 / 30%) 0px 1px 4px -1px";
    controlButton.style.minWidth = "66px";
    controlButton.textContent = textContent;
    controlButton.type = "button";

    controlButton.addEventListener("click", (e) => {
      e.preventDefault();
      event();
    });

    return controlButton;
  },
};
