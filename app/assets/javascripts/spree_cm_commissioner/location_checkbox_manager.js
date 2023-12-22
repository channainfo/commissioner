const LocationCheckboxManager = {
  initialize: function () {
    const locationCheckboxes = document.querySelectorAll('.location');

    locationCheckboxes.forEach(function (locationCheckbox) {
      locationCheckbox.addEventListener('change', function () {
        LocationCheckboxManager.handleCheckboxChange(this);
      });

      LocationCheckboxManager.handleCheckboxChange(locationCheckbox);
    });
  },

  handleCheckboxChange: function (changedCheckbox) {
    const stopCheckbox = document.querySelector('.stop');
    const branchCheckbox = document.querySelector('.branch');

    if (!stopCheckbox || !branchCheckbox) {
      alert("Please select at the last one.");
      event.preventDefault();
    }

    const isLocationChecked = changedCheckbox.checked;

    if (isLocationChecked) {
      stopCheckbox.checked = false;
      stopCheckbox.disabled = true;

      branchCheckbox.checked = false;
      branchCheckbox.disabled = true;
    } else {
      stopCheckbox.disabled = false;
      branchCheckbox.disabled = false;
    }
  }
};

document.addEventListener("spree:load", function () {
  LocationCheckboxManager.initialize();
});
