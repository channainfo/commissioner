document.addEventListener("spree:load", function () {
  const captureLinks = document.querySelectorAll('a[data-toggle="modal"]');

  captureLinks.forEach(function (link) {
    link.addEventListener("click", function (event) {
      event.preventDefault();

      const modalTarget = link.getAttribute("data-target");
      const paymentId = modalTarget.replace("#capture-modal-", "");

      const enCurrencyField = document.getElementById(
        paymentId + "_en_currency"
      );
      const khCurrencyField = document.getElementById(
        paymentId + "_kh_currency"
      );
      const totalField = document.getElementById(paymentId + "_total");
      const amountToBePaidElement = document.getElementById(
        paymentId + "_amount_to_be_paid"
      );
      const amountRemainingField = document.getElementById(
        paymentId + "_amount_remaining"
      );

      const amountToBePaid = parseFloat(amountToBePaidElement.placeholder) || 0;

      function updateTotal() {
        const enCurrency = parseFloat(enCurrencyField.value) || 0;
        const khCurrency = parseFloat(khCurrencyField.value) || 0;

        const total = enCurrency * 4100 + khCurrency;
        const amountRemaining = amountToBePaid - total;

        totalField.value = total.toFixed(2);
        amountRemainingField.value = amountRemaining.toFixed(2);
      }

      enCurrencyField.addEventListener("input", updateTotal);
      khCurrencyField.addEventListener("input", updateTotal);
    });
  });
});
