module SpreeCmCommissioner
  class GoogleWallet < SpreeCmCommissioner::Base
    enum review_status: { DRAFT: 0, APPROVED: 1 }

    TYPES = %i[event_ticket].freeze

    belongs_to :product, class_name: 'Spree::Product'

    has_one :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GoogleWalletLogo'
    has_one :hero_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GoogleWalletHero'

    validates :hero_image, presence: true, on: :update

    # default to event
    def object_builder
      SpreeCmCommissioner::GoogleWallets::EventTicketObjectBuilder
    end
  end
end
