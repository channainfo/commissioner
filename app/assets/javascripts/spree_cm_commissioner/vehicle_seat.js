const VehcileSeatLayoutHandler = {
  Seat: class {
    constructor(row, column, label) {
      this.row = row;
      this.column = column;
      this.label = label;
      this.layer = VehcileSeatLayoutHandler.layer;
      this.seat_type = 0;
      this.vehicle_type_id = VehcileSeatLayoutHandler.vehicleTypeId;
    }
  },

  initialize: function () {
    this.keyInit();
    this.listenToRow();
    this.listenToColumn();
    this.listenToSuffix();
    this.listenToLayer();
    this.listenToLabel();
    this.listenToSubmitButton();
  },

  keyInit: function () {
    this.row = document.getElementById("row");
    this.column = document.getElementById("column");
    this.seatsContainer = document.querySelector(".seatsContainer");
    this.label = document.getElementById("label");
    this.layer = document.getElementById("layer");
    this.submitButton = document.querySelector(".saveButton");
    this.segments = window.location.pathname.split("/");
    this.vehicleTypeId = this.segments[this.segments.length - 2];
    this.suffix = document.getElementById("suffix");
    this.selectedRow = null;
    this.selectedColumn = null;
    this.seats = [];
  },

  listenToSuffix: function () {
    this.suffix.addEventListener("input", () => {
      let newLabel = this.labelGenerator(this.suffix.checked);
      if (
        this.row.value > 0 &&
        this.column.value > 0 &&
        this.seats &&
        this.label.value
      ) {
        for (let i = 0; i < this.row.value; i++) {
          for (let j = 0; j < this.column.value; j++) {
            if (
              this.seats[i][j].seat_type != 1 &&
              this.seats[i][j].seat_type != 3
            ) {
              let tmpLabel = this.seats[i][j].label.replace(label.value, "");
              this.seats[i][j].label = newLabel(tmpLabel, label.value);
            }
          }
        }
        this.getSeats();
      }
    });
  },

  listenToLayer: function () {
    this.layer.addEventListener("input", () => {
      if (this.row.value > 0 && this.column.value > 0 && this.seats) {
        this.addLayer();
      }
    });
  },

  listenToRow: function () {
    this.row.addEventListener("input", () => {
      if (this.row.value > 0 && this.column.value > 0) {
        this.constructSeats();
        this.getSeats();
      }
    });
  },

  listenToColumn: function () {
    this.column.addEventListener("input", () => {
      if (this.row.value > 0 && this.column.value > 0) {
        this.constructSeats();
        this.getSeats();
      }
    });
  },

  listenToLabel: function () {
    this.label.addEventListener("input", () => {
      let newLabel = this.labelGenerator(this.suffix.checked);
      if (this.row.value > 0 && this.column.value > 0 && this.seats) {
        let tmpLabel = 0;
        this.seats.forEach((seatRow) => {
          seatRow.forEach((seat) => {
            if (seat.seat_type != 1 && seat.seat_type != 3) {
              seat.label = newLabel(++tmpLabel, label.value);
            } else {
              seat.label = "NA";
            }
          });
        });
        this.getSeats();
      }
    });
  },

  listenToSubmitButton: function () {
    this.submitButton.addEventListener("click", () => {
      if (seats.length > 0) {
        this.submit();
      }
    });
  },

  labelGenerator: function (isSuffix) {
    let newLabel;
    isSuffix
      ? (newLabel = (tmpLabel, labelValue) => `${tmpLabel}${labelValue}`)
      : (newLabel = (tmpLabel, labelValue) => `${labelValue}${tmpLabel}`);
    return newLabel;
  },

  constructSeats: function () {
    seats = [];
    let tmpLabel = 0;
    let newLabel = this.labelGenerator(suffix.checked);
    for (let i = 1; i <= this.row.value; i++) {
      let columns = [];
      for (let j = 1; j <= this.column.value; j++) {
        columns.push(new this.Seat(i, j, newLabel(++tmpLabel, label.value)));
      }
      seats.push(columns);
    }
    this.seats = seats;
  },

  getSeats: function () {
    $.ajax({
      url: "/transit/vehicle_types/vehicle_seats/load_seat",
      type: "POST",
      data: {
        row: this.row.value,
        column: this.column.value,
        label: this.label.value,
        seats: JSON.stringify(this.seats),
      },
      success: (response) => {
        this.seatsContainer.innerHTML = response;
        this.addSeatClickListener();
        this.typeSelect();
        this.editLabel();
        this.addLayer();
      },
      error: function (xhr, status, error) {
        show_flash("error", error);
      },
    });
  },

  submit: function () {
    $.ajax({
      url: `/transit/vehicle_types/${this.vehicleTypeId}/vehicle_seats`,
      type: "POST",
      data: {
        seats: JSON.stringify(this.seats),
      },
      success: (response) => {
        location.reload();
      },
      error: (xhr, status, error) => {
        console.error("Error updating seat layer:", error);
      },
    });
  },

  addLayer: function () {
    this.seats.forEach((seatRow) => {
      seatRow.forEach((seat) => {
        seat.layer = layer.value;
      });
    });
  },

  addSeatClickListener: function () {
    let self = this;
    let selectedSeat = null;
    document.querySelectorAll(".seat-container").forEach((seat) => {
      let seatIcon = (seat) => {
        return seat.querySelector(".seat-icon");
      };
      let seatLabel = (seat) => {
        return seat.querySelector(".seat-label");
      };

      seat.addEventListener("click", function () {
        if (selectedSeat && selectedSeat != this) {
          seatIcon(selectedSeat).classList.remove("selected-seat");
          seatLabel(selectedSeat).disabled = true;
        }

        seatIcon(this).classList.add("selected-seat");
        seatLabel(this).disabled = false;
        selectedSeat = this;

        self.selectedRow =
          parseInt(this.querySelector(".seat-icon").dataset.seatRow) - 1;
        self.selectedColumn =
          parseInt(this.querySelector(".seat-icon").dataset.seatColumn) - 1;
        let seat_type =
          self.seats[self.selectedRow][self.selectedColumn].seat_type;
        document.getElementById("type").value = seat_type;
      });
    });
  },
  editLabel: function () {
    let self = this;
    document.querySelectorAll(".seat-label").forEach((label) => {
      label.addEventListener("change", () => {
        self.seats[self.selectedRow][self.selectedColumn].label =
          document.getElementById(
            `${self.selectedRow + 1}${self.selectedColumn + 1}`
          ).value;
        self.getSeats();
      });
    });
  },
  typeSelect: function () {
    document.getElementById("type").addEventListener("input", () => {
      this.seats[this.selectedRow][this.selectedColumn].seat_type = parseInt(
        document.getElementById("type").value
      );
      let newLabel = this.labelGenerator(this.suffix.checked);
      let tmpLabel = 0;

      for (let i = 0; i < this.row.value; i++) {
        for (let j = 0; j < this.column.value; j++) {
          if (
            this.seats[i][j].seat_type != 1 &&
            this.seats[i][j].seat_type != 3
          ) {
            this.seats[i][j].label = newLabel(++tmpLabel, label.value);
          } else {
            this.seats[i][j].label = "NA";
          }
        }
      }
      this.getSeats();
    });
  },
};

const VehicleSeatViewHandler = {
  initialize: function () {
    $(document).ready(function () {
      if ($(".view-layer-btn").length > 0) {
        $(".view-layer-btn").click(function () {
          let layer = $(this).data("layer");
          let layer_name = $(this).data("layer-name");
          let column = $(this).data("layer-column");
          let row = $(this).data("layer-row");
          let seatsViewContainer = document.querySelector(".modal-body");
          $.ajax({
            url: "/transit/vehicle_types/layer",
            type: "POST",
            data: {
              row: row,
              layer_name: layer_name,
              column: column,
              seats: JSON.stringify(layer),
            },
            success: function (response) {
              seatsViewContainer.innerHTML = response;
            },
            error: function (xhr, status, error) {
              show_flash("error", error);
            },
          });
        });
      }
    });
  },
};

document.addEventListener("spree:load", function () {
  VehcileSeatLayoutHandler.initialize();
  VehicleSeatViewHandler.initialize();
});
