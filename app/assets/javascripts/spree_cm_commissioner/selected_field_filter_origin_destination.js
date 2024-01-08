var SelectFieldFilterOriginDestination = {
  initialize: function (originSelector, destinationSelector) {
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
  SelectFieldFilterOriginDestination.initialize('#product_origin_id', '#product_destination_id');
});