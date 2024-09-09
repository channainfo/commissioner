module SpreeCmCommissioner
  module GuestCardClasses
    class BibCardClass < SpreeCmCommissioner::GuestCardClass
      belongs_to :taxon, class_name: 'Spree::Taxon', optional: true
      preference :background_color, :string

      has_one :background_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GuestCardClasses::BibCardBackgroundImage'

      def class_type
        type.demodulize
      end

      def background_color
        preferred_background_color
      end
    end
  end
end
