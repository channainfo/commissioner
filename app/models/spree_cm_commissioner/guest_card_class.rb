module SpreeCmCommissioner
  class GuestCardClass < SpreeCmCommissioner::Base
    belongs_to :taxon, class_name: 'Spree::Taxon'

    TYPES = [
      SpreeCmCommissioner::GuestCardClasses::BibCardClass,
      SpreeCmCommissioner::GuestCardClasses::BookingCardClass
    ].map(&:to_s)
  end
end
