module SpreeCmCommissioner
  module UserPreference
    extend ActiveSupport::Concern

    included do
      preference :payment_method_id, :integer
    end
  end
end
