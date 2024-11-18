module SpreeCmCommissioner
  module ActionController
    module ApiDecorator
      def self.prepended(base)
        base.include SpreeCmCommissioner::ExceptionNotificable
        base.include SpreeCmCommissioner::ContentCachable
      end

      # Annonymous block: https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Naming/BlockForwarding
      def set_writing_role(&)
        ActiveRecord::Base.connected_to(role: :writing, &)
      end
    end
  end
end

unless ActionController::API.included_modules.include?(SpreeCmCommissioner::ActionController::ApiDecorator)
  ActiveSupport.on_load(:action_controller) do
    prepend SpreeCmCommissioner::ActionController::ApiDecorator
  end
end
