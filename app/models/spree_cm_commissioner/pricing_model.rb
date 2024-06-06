module SpreeCmCommissioner
  class PricingModel < Base
    include PricingRuleable

    belongs_to :pricing_modelable, optional: false, polymorphic: true, inverse_of: :pricing_models, touch: true

    has_many :pricing_actions, autosave: true, class_name: 'SpreeCmCommissioner::PricingAction', dependent: :destroy
    has_many :applied_pricing_models, class_name: 'SpreeCmCommissioner::AppliedPricingModel', dependent: :restrict_with_error

    before_create -> { pricing_actions.new(type: default_pricing_actions.first) }

    # override
    def product_type
      pricing_modelable.respond_to?(:product_type) ? pricing_modelable.product_type : nil
    end

    # available only action that not created.
    def available_pricing_actions
      existing_actions = pricing_actions.map { |action| action.class.name }
      default_pricing_actions.reject { |r| existing_actions.include? r }
    end

    def default_pricing_actions
      [
        'SpreeCmCommissioner::PricingActions::CalculateAdjustment'
      ]
    end
  end
end
