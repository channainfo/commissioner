module SpreeCmCommissioner
  module ProductDelegation
    extend ActiveSupport::Concern

    included do
      delegate :product_type,
               :need_confirmation?, :need_confirmation,
               :accommodation?, :service?, :ecommerce?,
               :kyc?, :kyc,
               to: :product
    end
  end
end
