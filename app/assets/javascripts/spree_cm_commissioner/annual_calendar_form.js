const AnnualCalendarForm = {
  daySelector: '.c-annual-day',
  initialize: function ({ startDateFieldSelector, lengthFieldSelector }) {
    this.startDateFieldSelector = startDateFieldSelector;
    this.lengthFieldSelector = lengthFieldSelector;
    this.selectedDates = [];

    this.listenToDateClick();
  },
  listenToDateClick: function () {
    const self = this;

    $(this.daySelector).click(function () {
      // reset UI
      if (self.selectedDates.length >= 2) {
        $('.c-selecting-day').removeClass('c-selecting-day');
        $(this).parent('td').addClass('c-selecting-day');
      } else {
        $(this).parent('td').toggleClass('c-selecting-day');
      }

      self.selectedDates = self.getCurrentSelectedDatesFromUI();
      if (self.selectedDates.length >= 1) {
        let startDate = self.selectedDates[0];
        let endDate = self.selectedDates[self.selectedDates.length - 1];

        self.setSelectedValuesToForm(startDate, endDate);
        self.displaySelectedDatesBetween(startDate, endDate);
      }
    });
  },
  setSelectedValuesToForm: function (startDate, endDate) {
    let startDateValue = startDate.toISOString().split('T')[0];
    let lengthValue = this.getLengthBetween(startDate, endDate);

    $(this.startDateFieldSelector).val(startDateValue);
    $(this.lengthFieldSelector).val(lengthValue);
  },
  displaySelectedDatesBetween: function (startDate, endDate) {
    $('.c-selecting-day').removeClass('c-selecting-day');

    let selectedDates = this.getDatesBetween(startDate, endDate);
    selectedDates.forEach((date) => {
      // [data-date="2023-12-07"]
      $('[data-date="' + date.toISOString().slice(0, 10) + '"]')
        .parent('td')
        .addClass('c-selecting-day');
    });
  },
  getCurrentSelectedDatesFromUI: function () {
    let selectedDates = [];

    $('.c-selecting-day').each(function (_, element) {
      const childElement = $(element).find('.c-annual-day');
      const dateValue = childElement.data('date');

      selectedDates.push(new Date(dateValue));
      selectedDates.sort(function (a, b) {
        return a.date - b.date;
      });
    });

    return selectedDates;
  },
  getDatesBetween: function (startDate, endDate) {
    startDate = Date.parse(startDate);
    endDate = Date.parse(endDate);

    let currentDate = new Date(startDate);
    const result = [];

    while (currentDate <= endDate) {
      result.push(new Date(currentDate));
      currentDate.setDate(currentDate.getDate() + 1);
    }

    return result;
  },
  getLengthBetween: function (startDate, endDate) {
    let timeDifference = endDate.getTime() - startDate.getTime();
    let daysDifference = Math.ceil(timeDifference / (1000 * 60 * 60 * 24));
    return daysDifference + 1;
  },
};
