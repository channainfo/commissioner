module SpreeCmCommissioner
  class ApplyVendorPromotions < BaseInteractor
    delegate :from_date, :to_date, :user, :vendors, to: :context

    # base rules that does not required line items or date for check eligbility.
    # for date rules, we can check later to return to recommend user even some date not eligble.
    BASE_RULES = [
      Spree::Promotion::Rules::ItemTotal,
      Spree::Promotion::Rules::User,
      Spree::Promotion::Rules::FirstOrder,
      Spree::Promotion::Rules::UserLoggedIn,
      Spree::Promotion::Rules::OneUsePerUser,
      Spree::Promotion::Rules::Country
    ].freeze

    def call
      vendors.map { |vendor| vendor.promotions = apply_promotions(vendor) }
    end

    def apply_promotions(vendor)
      vendor.active_promotions.filter_map do |promotion|
        next unless promotion.vendor_eligible?(vendor, BASE_RULES, user: user)

        date_eligibles = (from_date..to_date).map { |date| promotion.date_eligible?(date) }
        next if promotion.date_rule_exists? && date_eligibles.none?

        promotion.actions.map do |action|
          apply_action(vendor, promotion, action, date_eligibles)
        end
      end.flatten
    end

    def apply_action(vendor, promotion, action, date_eligibles)
      offer = { :name => promotion.name, :action_type => action.class.name.underscore }

      case action
      when Spree::Promotion::Actions::CreateAdjustment,
        Spree::Promotion::Actions::CreateItemAdjustments,
        SpreeCmCommissioner::Promotion::Actions::CreateDateSpecificItemAdjustments

        context = PromotionCalculatorSummarizer.call(
          calculator: action.calculator,
          original_amount: vendor.min_price,
          original_amount_currency: vendor.currency,
          match_all: promotion.date_rule_exists? ? date_eligibles.all? : true
        )

        offer[:caculator_type] = action.calculator.class.name.underscore
        offer[:advertised_text] = context.advertised_text

        offer[:computed_amount] = context.computed_amount
        offer[:price] = context.price
        offer[:compare_at_price] = context.compare_at_price

        offer[:display_computed_amount] = Spree::Money.new(context.computed_amount, currency: vendor.currency)
        offer[:display_price] = Spree::Money.new(context.price, currency: vendor.currency)
        offer[:display_compare_at_price] = Spree::Money.new(context.compare_at_price, currency: vendor.currency)

      when Spree::Promotion::Actions::FreeShipping
        offer[:free_shipping] = true
      when Spree::Promotion::Actions::CreateLineItems
        offer[:required_items] = true
      end

      offer
    end
  end
end
