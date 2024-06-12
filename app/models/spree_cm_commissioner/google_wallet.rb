module SpreeCmCommissioner
  class GoogleWallet < SpreeCmCommissioner::Base
    enum review_status: { DRAFT: 0, UNDER_REVIEW: 1, APPROVED: 2, REJECTED: 3 }

    TYPES = %i[event_ticket generic].freeze

    belongs_to :product, class_name: 'Spree::Product'

    has_one :logo, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GoogleWalletLogo'
    has_one :hero_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::GoogleWalletHero'

    # default to event
    def object_builder
      SpreeCmCommissioner::GoogleWallets::EventTicketObjectBuilder
    end
  end
end
