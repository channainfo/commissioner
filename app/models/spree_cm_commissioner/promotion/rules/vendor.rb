module SpreeCmCommissioner
  module Promotion
    module Rules
      class Vendor < Spree::PromotionRule
        belongs_to :vendor, class_name: 'Spree::Vendor'

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, _options = {})
          order.variants.pluck(:vendor_id).include?(vendor.id)
        end
      end
    end
  end
end
