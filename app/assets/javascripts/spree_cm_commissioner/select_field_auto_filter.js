document.addEventListener("spree:load", function () {
  $(".select_field_auto_filter").on("change", function () {
    let params = new URLSearchParams(window.location.search);
    params.set($(this).data("param-name"), $(this).val());
    window.location.search = params.toString();
  });
});
