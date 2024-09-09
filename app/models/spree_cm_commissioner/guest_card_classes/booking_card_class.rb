module SpreeCmCommissioner
  module GuestCardClasses
    class BookingCardClass < GuestCardClass
      has_one :background_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GuestCardClasses::BookingCardBackgroundImage'

      def class_type
        type.demodulize
      end
    end
  end
end
