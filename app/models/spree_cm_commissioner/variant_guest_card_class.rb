module SpreeCmCommissioner
  class VariantGuestCardClass < SpreeCmCommissioner::Base
    belongs_to :variant, class_name: 'Spree::Variant'
    belongs_to :guest_card_class, class_name: 'SpreeCmCommissioner::GuestCardClass'

    validates :variant_id, uniqueness: { scope: :guest_card_class_id }
  end
end
