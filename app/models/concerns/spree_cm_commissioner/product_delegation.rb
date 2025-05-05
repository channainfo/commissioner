module SpreeCmCommissioner
  module ProductDelegation
    extend ActiveSupport::Concern

    included do
      delegate :subscribable?,
               :allowed_upload_later?,
               :need_confirmation?, :need_confirmation, :kyc,
               :allow_anonymous_booking,
               :associated_event,
               :allow_self_check_in,
               :allow_self_check_in?,
               :required_self_check_in_location,
               :required_self_check_in_location?,
               to: :product
    end
  end
end
