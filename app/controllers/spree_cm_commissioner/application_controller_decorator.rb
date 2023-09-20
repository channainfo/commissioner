module SpreeCmCommissioner
  module ApplicationControllerDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ExceptionNotificable
    end

    # Annonymous block: https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Naming/BlockForwarding
    def set_writing_role(&)
      ActiveRecord::Base.connected_to(role: :writing, &)
    end
  end
end

unless ApplicationController.included_modules.include?(SpreeCmCommissioner::ApplicationControllerDecorator)
  ApplicationController.prepend(SpreeCmCommissioner::ApplicationControllerDecorator)
end
