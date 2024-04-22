document.addEventListener("spree:load", function () {
  TripStopSelectionHandler.initialize();
});

const TripStopSelectionHandler = {
  initialize: function () {
    this.keyInit();
  },

  boarding_stop_ids: function () {
    return Array.from(this.boarding_stop.selectedOptions).map(
      ({ value }) => value
    );
  },

  drop_off_stop_ids: function () {
    return Array.from(this.drop_off_stop.selectedOptions).map(
      ({ value }) => value
    );
  },

  keyInit: function () {
    this.boarding_stop = document.getElementById("boarding_stops");
    this.drop_off_stop = document.getElementById("drop-off_stops");
  },
};
