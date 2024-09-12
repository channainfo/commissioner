document.addEventListener("spree:load", function () {
  var useCustomDateRange = $(
    "#spree_cm_commissioner_report_use_custom_date_range"
  );

  const dateRangeFilter = document.getElementById("report-date-range-filter");
  const periodRangeFilter = document.getElementById(
    "report-period-range-filter"
  );

  const params = new URLSearchParams(window.location.search);
  const useCustomDateRangeParam = params.get(
    "spree_cm_commissioner_report[use_custom_date_range]"
  );

  // Check if the use_custom_date_range param is set to 1
  if (useCustomDateRangeParam === "1") {
    useCustomDateRange.prop("checked", true);
    dateRangeFilter.style.display = "block";
    periodRangeFilter.style.display = "none";
  } else {
    useCustomDateRange.prop("checked", false);
    dateRangeFilter.style.display = "none";
    periodRangeFilter.style.display = "block";
  }

  // Toggle the date range filter on checkbox change
  useCustomDateRange.change(function () {
    if (this.checked) {
      dateRangeFilter.style.display = "block";
      periodRangeFilter.style.display = "none";
    } else {
      dateRangeFilter.style.display = "none";
      periodRangeFilter.style.display = "block";
    }
  });
});
