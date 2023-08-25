const OrderConfirmation = {
  initialize: function ({ canApprove, canCancel, onApprove, onReject }) {
    self = this;

    this.canApprove = canApprove == "true";
    this.canCancel = canCancel == "true";
    this.onApprove = onApprove;
    this.onReject = onReject;

    window.Telegram.WebApp.MainButton.onClick(() => {
      self.mainButtonClickListener();
    });

    window.Telegram.WebApp.onEvent("viewportChanged", (params) =>
      this.viewportChangedListener(params)
    );
  },
  viewportChangedListener: function (params) {
    if (!params.isStateStable) return this.hideMainButton();
    if (this.currentMainButtonAction() == "confirm") {
      this.showMainButton({
        text: "Confirm",
        color: window.Telegram.WebApp.themeParams.button_color,
        text_color: window.Telegram.WebApp.themeParams.button_text_color,
      });
    } else {
      this.showMainButton({
        text: "Reject",
        color: "#F5564D",
      });
    }
  },
  currentMainButtonAction: function () {
    if (window.Telegram.WebApp.isExpanded) {
      return "confirm";
    } else {
      return "reject";
    }
  },
  mainButtonClickListener: function () {
    if (this.currentMainButtonAction() == "confirm") {
      this.confirm();
    } else {
      this.reject();
    }
  },
  confirm: function () {
    window.Telegram.WebApp.showPopup(
      {
        title: "Are you sure to confirm?",
        message: "You can't undo this action.",
        buttons: [
          { id: "close", type: "close" },
          { id: "confirm", type: "default", text: "Confirm" },
        ],
      },
      function (buttonId) {
        if (buttonId == "confirm") self.onApprove();
      }
    );
  },
  reject: function () {
    window.Telegram.WebApp.showPopup(
      {
        title: "Are you sure to reject?",
        message: "You can't undo this action.",
        buttons: [
          { id: "close", type: "close" },
          { id: "reject", type: "destructive", text: "Reject" },
        ],
      },
      function (buttonId) {
        if (buttonId == "reject") self.onReject();
      }
    );
  },
  hideMainButton: function () {
    if (window.Telegram.WebApp.MainButton.isVisible) {
      window.Telegram.WebApp.MainButton.hide();
    }
  },
  showMainButton: function (params) {
    window.Telegram.WebApp.MainButton.setParams(params);
    window.Telegram.WebApp.MainButton.show();
  },
};
