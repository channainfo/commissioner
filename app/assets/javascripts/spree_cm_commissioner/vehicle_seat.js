document.addEventListener("DOMContentLoaded", function () {
  var modalButton = document.querySelector(".btn-primary");
  var row = document.getElementById("row");
  var column = document.getElementById("column");
  var seatsContainer = document.querySelector(".seatsContainer");
  var label = document.getElementById("label");
  var layer = document.getElementById("layer");
  var seats = [];

  modalButton.addEventListener("click", function () {
    $("#createSeatModal").modal("show");
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
    if (row.value > 0 && column.value > 0) {
      constructSeats();
      getSeats();
    }
  });

  class Seat {
    constructor(row, column, label) {
      this.row = row;
      this.column = column;
      this.status = true;
      this.label = label + row + column;
      this.layer = layer;
    }
    type;
  }

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
      },
      error: function (xhr, status, error) {
        show_flash("error", error);
      },
    });
  }

  function addSeatClickListener() {
    document.querySelectorAll(".seat-icon").forEach((seat) => {
      seat.addEventListener("click", function () {
        clickedRow = this.dataset.seatRow;
        clickedColumn = this.dataset.seatColumn;
        clickedSeatStatus = seats[clickedRow - 1][clickedColumn - 1].status;
        seats[clickedRow - 1][clickedColumn - 1].status = !clickedSeatStatus;
        getSeats();
      });
    });
  }
});
