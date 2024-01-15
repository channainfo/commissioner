var SelectFieldFilterOriginDestination = {
  initialize: function (originSelector, destinationSelector, selectedOriginId, selectedDestinationId) {
    function filterOptions(originId, destinationSelector) {
      $(destinationSelector + ' option').each(function () {
        if ($(this).val() == originId) {
          $(this).prop('disabled', true).hide();
        }
        else {
          $(this).prop('disabled', false).show();
        }
      });
    }

    $(originSelector).val(selectedOriginId);
    $(destinationSelector).val(selectedDestinationId);

    filterOptions(selectedOriginId, destinationSelector);
    filterOptions(selectedDestinationId, originSelector);


    $(document).on('change', originSelector, function () {
      var originId = $(this).val();
      filterOptions(originId, destinationSelector);
    });

    $(document).on('change', destinationSelector, function () {
      var destinationId = $(this).val();
      filterOptions(destinationId, originSelector);
    });
  }
}

document.addEventListener("spree:load", function () {
  var selectedOriginId = $('#product_origin_id').val();
  var selectedDestinationId = $('#product_destination_id').val();
  SelectFieldFilterOriginDestination.initialize('#product_origin_id', '#product_destination_id', selectedOriginId, selectedDestinationId);
});