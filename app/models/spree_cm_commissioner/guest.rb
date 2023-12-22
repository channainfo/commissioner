module SpreeCmCommissioner
  class Guest < SpreeCmCommissioner::Base
    enum gender: { :other => 0, :male => 1, :female => 2 }

    belongs_to :line_item, class_name: 'Spree::LineItem'
    belongs_to :occupation, class_name: 'Spree::Taxon'

    has_one :id_card, class_name: 'SpreeCmCommissioner::IdCard', dependent: :destroy
  end
end
