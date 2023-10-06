document.addEventListener("DOMContentLoaded", function () {
  var row = document.getElementById("row");
  var column = document.getElementById("column");
  var seatsContainer = document.querySelector(".seatsContainer");
  var label = document.getElementById("label");
  var layer = document.getElementById("layer");
  var submitButton = document.querySelector(".saveButton");
  var segments = window.location.pathname.split("/");
  var vehicleTypeId = segments[segments.length - 2];
  var selectedRow;
  var selectedColumn;
  var seats = [];
  class Seat {
    constructor(row, column, label) {
      this.row = row;
      this.column = column;
      this.label = label + row + column;
      this.layer = layer;
      this.seat_type = 0;
      this.vehicle_type_id = vehicleTypeId;
    }
  }

  layer.addEventListener("input", function () {
    if (row.value > 0 && column.value > 0 && seats) {
      addLayer();
    }
  });

  row.addEventListener("input", function () {
    if (row.value > 0 && column.value > 0) {
      constructSeats();
      getSeats();
    }
  });
  column.addEventListener("input", function () {
    if (row.value > 0 && column.value > 0) {
      constructSeats();
      getSeats();
    }
  });
  label.addEventListener("input", function () {
    if (row.value > 0 && column.value > 0 && seats) {
      seats.forEach((r, rIndex) => {
        r.forEach((seat, cIndex) => {
          seat.label = `${label.value}${rIndex + 1}${cIndex + 1}`;
        });
      });
      getSeats();
    }
  });

  submitButton.addEventListener("click", function () {
    if (seats.length > 0) {
      submit();
    }
  });

  function constructSeats() {
    seats = [];
    for (let i = 1; i <= row.value; i++) {
      let columns = [];
      for (let j = 1; j <= column.value; j++) {
        columns.push(new Seat(i, j, label.value));
      }
      seats.push(columns);
    }
  }

  function getSeats() {
    $.ajax({
      url: "/transit/vehicle_types/vehicle_seats/load_seat",
      type: "POST",
      data: {
        row: row.value,
        column: column.value,
        label: label.value,
        seats: JSON.stringify(seats),
      },
      success: function (response) {
        seatsContainer.innerHTML = response;
        addSeatClickListener();
        typeSelect();
        editLabel();
        addLayer();
        console.log(seats);
      },
      error: function (xhr, status, error) {
        show_flash("error", error);
      },
    });
  }

  function submit() {
    $.ajax({
      url: `/transit/vehicle_types/${vehicleTypeId}/vehicle_seats`,
      type: "POST",
      data: {
        seats: JSON.stringify(seats),
      },
      success: function (response) {
        console.log("Seat layer updated successfully");
        console.log("Attempting to hide modal...");
        location.reload();
      },
      error: function (xhr, status, error) {
        console.error("Error updating seat layer:", error);
      },
    });
  }

  function addLayer() {
    seats.forEach((r) => {
      r.forEach((seat) => {
        seat.layer = layer.value;
      });
    });
  }

  function addSeatClickListener() {
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

        selectedRow =
          parseInt(this.querySelector(".seat-icon").dataset.seatRow) - 1;
        selectedColumn =
          parseInt(this.querySelector(".seat-icon").dataset.seatColumn) - 1;
        let seat_type = seats[selectedRow][selectedColumn].seat_type;
        document.getElementById("type").value = seat_type;
      });
    });
  }

  function editLabel() {
    document.querySelectorAll(".seat-label").forEach((label) => {
      label.addEventListener("change", function () {
        seats[selectedRow][selectedColumn].label = document.getElementById(
          `${selectedRow + 1}${selectedColumn + 1}`
        ).value;
        getSeats();
      });
    });
  }

  function typeSelect() {
    document.getElementById("type").addEventListener("input", function () {
      seats[selectedRow][selectedColumn].seat_type = parseInt(
        document.getElementById("type").value
      );
      getSeats();
    });
  }
});

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
      });
    });
  }
});

// function viewseat() {
//   $.ajax({
//     url: "/transit/vehicle_types/vehicle_seats/load_seat",
//     type: "POST",
//     data: {
//       row: row.value,
//       column: column.value,
//       label: label.value,
//       seats: JSON.stringify(seats),
//     },
//     success: function (response) {
//       seatsContainer.innerHTML = response;
//       addSeatClickListener();
//       typeSelect();
//       editLabel();
//       addLayer();
//       console.log(seats);
//     },
//     error: function (xhr, status, error) {
//       show_flash("error", error);
//     },
//   });
// }
