module SpreeCmCommissioner
  module ApplicationControllerDecorator
    def self.prepended(base)
      base.include SpreeCmCommissioner::ExceptionNotificable
      base.include SpreeCmCommissioner::ContentCachable
    end

    # Annonymous block: https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Naming/BlockForwarding
    def set_writing_role(&block)
      ActiveRecord::Base.connected_to(role: :writing, &block)
    end

    def after_sign_in_path_for(_)
      if spree_current_user.admin?
        admin_path
      elsif spree_current_user.organizer? && spree_current_user.events.present?
        event_guests_path(spree_current_user.events.first.slug)
      else
        '/'
      end
    end
  end
end

unless ApplicationController.included_modules.include?(SpreeCmCommissioner::ApplicationControllerDecorator)
  ApplicationController.prepend(SpreeCmCommissioner::ApplicationControllerDecorator)
end
