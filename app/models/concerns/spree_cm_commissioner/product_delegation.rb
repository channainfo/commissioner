module SpreeCmCommissioner
  module ProductDelegation
    extend ActiveSupport::Concern

    included do
      delegate :product_type,
               :subscribable?,
               :allowed_upload_later?,
               :need_confirmation?, :need_confirmation, :kyc,
               :allow_anonymous_booking,
               :accommodation?, :service?, :ecommerce?,
               :associated_event,
               :allow_self_check_in,
               to: :product
    end
  end
end
