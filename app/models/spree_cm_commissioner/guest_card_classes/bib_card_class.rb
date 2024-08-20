module SpreeCmCommissioner
  module GuestCardClasses
    class BibCardClass < SpreeCmCommissioner::GuestCardClass
      belongs_to :taxon, class_name: 'Spree::Taxon', optional: true
      preference :background_color, :string

      has_one :background_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GuestCardClasses::BibCardBackgroundImage'
    end
  end
end
