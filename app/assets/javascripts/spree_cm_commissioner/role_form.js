const RoleForm = {
  permissionCheckboxSelector: ".permission-checkbox",
  initialize: function () {
    this.listenToSelectOne();
    this.listenToSelectRow();
    this.listenToSelectAll();
  },
  listenToSelectOne: function () {
    // Select/deselect a single permission checkbox
    $(document).on("change", this.permissionCheckboxSelector, function () {
      var $checkbox = $(this),
        $targetRow = $checkbox.closest("tr"),
        $targetSelectAll = $targetRow.find(".select-all[data-row]"),
        allChecked = true,
        row = $targetSelectAll.data("row");

      $targetRow.find(".permission-checkbox." + row).each(function () {
        if (!$(this).prop("checked")) {
          allChecked = false;
          return false;
        }
      });
    });
  },
  listenToSelectRow: function () {
    // Select/deselect all checkboxes in the same row as the clicked select-all button
    $(document).on("change", ".select-all[data-row]", function () {
      var $checkbox = $(this),
        checked = $checkbox.prop("checked"),
        row = $checkbox.data("row");

      $("." + row.split("/").join("\\/")).prop("checked", checked);
    });
  },
  listenToSelectAll: function () {
    self = this;

    // Select/deselect all permission checkboxes
    $(document).on("change", ".select-all:not([data-row])", function () {
      const checked = $(this).prop("checked");
      $(self.permissionCheckboxSelector).prop("checked", checked);
      $(".select-all[data-row]").prop("checked", checked).trigger("change");
    });

    $targetSelectAll.prop("checked", allChecked);
  },
};

document.addEventListener("spree:load", function () {
  RoleForm.initialize();
});
