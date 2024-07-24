module SpreeCmCommissioner
  module Promotion
    module Rules
      class Customers < Spree::PromotionRule
        belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'

        has_many :customer_promotion_rules, class_name: 'SpreeCmCommissioner::CustomerPromotionRule',
                                            foreign_key: :promotion_rule_id,
                                            dependent: :destroy
        has_many :customers, through: :customer_promotion_rules, class_name: 'SpreeCmCommissioner::Customer'

        def applicable?(promotable)
          promotable.is_a?(SpreeCmCommissioner::Customer)
        end

        def eligible?(order, _options = {})
          customers.include?(order.customer)
        end

        def customer_ids_string
          customer_ids.join(',')
        end

        def customer_ids_string=(value)
          # check this
          self.customer_ids = value
        end
      end
    end
  end
end
