module SpreeCmCommissioner
  class GuestCardClass < SpreeCmCommissioner::Base
    TYPES = [
      SpreeCmCommissioner::GuestCardClasses::BibCardClass
    ].map(&:to_s)

    belongs_to :taxon, class_name: 'Spree::Taxon', optional: true
  end
end
