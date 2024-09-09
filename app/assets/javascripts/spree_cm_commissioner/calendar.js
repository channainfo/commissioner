const Calendar = {
  sidebarSelector: "#c-sidebar",
  dateSelector: ".c-date",
  activeDateQuerySelector: "active_date",
  initialize: function () {
    this.url = new window.URL(document.location);
    this.listenToDateClick();
    this.initialSidebar();
  },
  initialSidebar: function () {
    const dateSelectorId = "#c-date-" + this.activeDate();
    const content = $(dateSelectorId).data("content");
    this.updateDateSidebarContent(content);
  },
  listenToDateClick: function () {
    const self = this;

    $(self.dateSelector).click(function () {
      const content = $(this).data("content");
      const date = $(this).data("date");

      if (self.activeDate() === date) return;

      self.updateDateSidebarContent(content);
      self.updateCurrentUrlActiveDate(date);

      self.renderDateAsActive(this);
    });
  },
  updateCurrentUrlActiveDate: function (date) {
    this.url.searchParams.set(this.activeDateQuerySelector, date);
    history.pushState(null, null, this.url);
  },
  updateDateSidebarContent: function (content) {
    const selector = this.sidebarSelector;
    $(selector)
      .fadeOut("fast", function () {
        $(selector).html(content);
      })
      .fadeIn("fast");
  },
  renderDateAsActive: function (element) {
    const parentSelector = ".day";
    const parent = $(element).parent().closest(parentSelector);

    $(parentSelector).removeClass("start-date");
    parent.addClass("start-date");

    // in case there is input form
    $("#active_date").val(this.activeDate());
  },
  activeDate: function () {
    return this.url.searchParams.get(this.activeDateQuerySelector);
  },
};

document.addEventListener("spree:load", function () {
  Calendar.initialize();
});
