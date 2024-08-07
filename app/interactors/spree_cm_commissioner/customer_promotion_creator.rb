module SpreeCmCommissioner
  class CustomerPromotionCreator < BaseInteractor
    CUSTOMER_PROMOTION_RULE_TYPE = 'SpreeCmCommissioner::Promotion::Rules::Customers'.freeze
    PROMOTION_ACTION_TYPE = 'Spree::Promotion::Actions::CreateAdjustment'.freeze
    CALCULATOR_TYPE = 'Spree::Calculator::FlatRate'.freeze

    def call
      customer = SpreeCmCommissioner::Customer.find(context.customer_id)
      if customer.blank?
        context.fail!(message: 'Customer not found')
        return
      end

      promotion = find_or_initialize_promotion(customer)
      if promotion.new_record?
        create_promotion(promotion, customer, context.reason, context.discount_amount, context.store)
      else
        update_promotion(promotion, customer, context.reason, context.discount_amount)
      end

      context.success = true
    rescue StandardError => e
      context.fail!(message: e.message)
    end

    private

    def find_or_initialize_promotion(customer)
      Spree::Promotion.find_or_initialize_by(code: customer.number)
    end

    def create_promotion(promotion, customer, reason, discount_amount, store)
      ActiveRecord::Base.transaction do
        promotion_name = reason.to_s
        description = "Billing Promotion #{discount_amount} for #{customer.number}"
        promotion.assign_attributes(
          name: promotion_name,
          description: description,
          stores: [store],
          code: customer.number
        )
        promotion.save!

        create_promotion_rule(promotion, customer)
        create_promotion_action(promotion, discount_amount)
      end
    end

    def create_promotion_rule(promotion, customer)
      rule = Spree::PromotionRule.create!(
        promotion_id: promotion.id,
        type: CUSTOMER_PROMOTION_RULE_TYPE,
        preferences: { match_policy: 'any' }
      )
      rule.customer_promotion_rules.create!(customer_id: customer.id)
    end

    def create_promotion_action(promotion, discount_amount)
      action = Spree::PromotionAction.create(
        promotion_id: promotion.id,
        type: PROMOTION_ACTION_TYPE
      )
      action.calculator.update!(
        type: CALCULATOR_TYPE,
        preferences: { amount: BigDecimal(discount_amount),
                       currency: 'KHR'
                     }
      )
    end

    def update_promotion(promotion, customer, reason, discount_amount)
      ActiveRecord::Base.transaction do
        promotion.update(name: reason,
                         description: "Billing Promotion #{discount_amount} for #{customer.number}"
                        )
        promotion.actions.first.calculator.update(preferences: { amount: BigDecimal(discount_amount) })
      end
    end
  end
end
