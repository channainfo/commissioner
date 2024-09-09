module SpreeCmCommissioner
  module ExceptionNotificable
    extend ActiveSupport::Concern

    included do
      before_action :prepare_exception_notifier
    end

    private

    def prepare_exception_notifier
      exception_data = {}

      exception_data[:user] = [try_spree_current_user&.id].compact.join('-') if defined?(try_spree_current_user)
      exception_data[:order] = [spree_current_order&.number].compact.join('-') if defined?(spree_current_order)

      request.env['exception_notifier.exception_data'] = exception_data
    end
  end
end
