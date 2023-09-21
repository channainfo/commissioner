$(document).on('change', function () {
  const switchElement = $('#service_id');
  const datePickerElement = $('#datePicker');
  const serviceCalendarSelect = $('#seviceCalendarSelect');

  if (switchElement.is(':checked')) {
    serviceCalendarSelect.hide();
    datePickerElement.show();
  } else {
    serviceCalendarSelect.show();
    datePickerElement.hide();
  }
});
