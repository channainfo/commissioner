document.addEventListener("spree:load", function () {
  var useCustomDateRange = $(
    "#spree_cm_commissioner_report_use_custom_date_range"
  );

  const dateRangeFilter = $(".date-range-filter");
  const periodRangeFilter = $(".period-range-filter");

  const params = new URLSearchParams(window.location.search);
  const useCustomDateRangeParam = params.get(
    "spree_cm_commissioner_report[use_custom_date_range]"
  );

  // Check if the use_custom_date_range param is set to 1
  if (useCustomDateRangeParam === "1") {
    useCustomDateRange.prop("checked", true);
    dateRangeFilter.show();
    periodRangeFilter.hide();
  } else {
    dateRangeFilter.hide();
    periodRangeFilter.show();
  }

  // Toggle the date range filter on checkbox change
  useCustomDateRange.change(function () {
    if (this.checked) {
      dateRangeFilter.show();
      periodRangeFilter.hide();
    } else {
      dateRangeFilter.hide();
      periodRangeFilter.show();
    }
  });
});
