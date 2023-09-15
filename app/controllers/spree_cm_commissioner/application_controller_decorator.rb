module SpreeCmCommissioner
  module ApplicationControllerDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ExceptionNotificable
    end
  end
end

unless ApplicationController.included_modules.include?(SpreeCmCommissioner::ApplicationControllerDecorator)
  ApplicationController.prepend(SpreeCmCommissioner::ApplicationControllerDecorator)
end
