module SpreeCmCommissioner
  module GuestCardClasses
    class BibCardClass < SpreeCmCommissioner::GuestCardClass
      belongs_to :taxon, class_name: 'Spree::Taxon', optional: true
      preference :background_color, :string

      has_one_attached :background_image do |attachable|
        attachable.variant :mini, resize_to_limit: [400, 600]
        attachable.variant :small, resize_to_limit: [800, 1200]
      end
    end
  end
end
