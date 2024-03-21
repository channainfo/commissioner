module SpreeCmCommissioner
  class PricingModel < Base
    include PricingConcern

    belongs_to :modelable, polymorphic: true, inverse_of: :pricing_models, touch: true

    has_many :pricing_actions, autosave: true, class_name: 'SpreeCmCommissioner::PricingAction', dependent: :destroy
    has_many :applied_pricing_models, class_name: 'SpreeCmCommissioner::AppliedPricingModel', dependent: :restrict_with_error
  end
end
