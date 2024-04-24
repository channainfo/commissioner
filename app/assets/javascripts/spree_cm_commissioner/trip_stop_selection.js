var boardingAndDropOffSelectionFilter = {
  initialize: function (boardingSelector, dropOffSelector) {
    var selectedOriginIds = $(boardingSelector).val();
    var selectedDestinationIds = $(dropOffSelector).val();

    function filterOptions(selectedIds, selector) {
      $(selector + " option").each(function () {
        var optionValue = $(this).val();
        // Check if the optionValue exists in the selectedIds array
        if (selectedIds.includes(optionValue)) {
          $(this).prop("disabled", true).hide();
        } else {
          $(this).prop("disabled", false).show();
        }
      });
    }

    $(boardingSelector).val(selectedOriginIds);
    $(dropOffSelector).val(selectedDestinationIds);

    filterOptions(selectedOriginIds, dropOffSelector);
    filterOptions(selectedDestinationIds, boardingSelector);

    $(document).on("change", boardingSelector, function () {
      var originIds = $(this).val();
      filterOptions(originIds, dropOffSelector);
    });

    $(document).on("change", dropOffSelector, function () {
      var destinationIds = $(this).val();
      filterOptions(destinationIds, boardingSelector);
    });
  },
};

document.addEventListener("spree:load", function () {
  boardingAndDropOffSelectionFilter.initialize(
    "#boarding_stops",
    "#drop-off_stops"
  );
});
