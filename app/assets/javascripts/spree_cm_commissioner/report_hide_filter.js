document.addEventListener("spree:load", function () {
  var useCustomDateRange = $(
    "#spree_cm_commissioner_report_use_custom_date_range"
  );

  if (useCustomDateRange.length <= 0) return;

  $("#spree_cm_commissioner_report_use_custom_date_range").removeAttr(
    "checked"
  );

  // Hide the date range filter by default
  $(".date-range-filter").hide();

  // Show the date range filter if the checkbox is checked
  if (useCustomDateRange.is(":checked")) {
    $(".date-range-filter").show();
  }

  // Toggle the date range filter on checkbox change
  useCustomDateRange.change(function () {
    if (this.checked) {
      $(".date-range-filter").show();
      $(".period-range-filter").hide();
    } else {
      $(".date-range-filter").hide();
      $(".period-range-filter").show();
    }
  });
});
