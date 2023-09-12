module SpreeCmCommissioner
  class TelegramWebAppVendorUserAuthorizer
    include Interactor::Organizer

    organize TelegramWebAppInitDataValidator, TelegramWebAppVendorUserChecker
  end
end
