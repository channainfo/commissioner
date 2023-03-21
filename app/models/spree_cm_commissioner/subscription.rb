module SpreeCmCommissioner
  class Subscription < SpreeCmCommissioner::Base
    enum status: { :active => 0, :suspended => 1, :inactive => 2 }

    belongs_to :variant, class_name: 'Spree::Variant'
    belongs_to :customer, class_name: 'SpreeCmCommissioner::Customer'

    validates :start_date, :status, presence: true
  end
end
