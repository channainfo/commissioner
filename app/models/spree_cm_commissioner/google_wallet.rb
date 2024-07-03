module SpreeCmCommissioner
  class GoogleWallet < SpreeCmCommissioner::Base
    enum review_status: { DRAFT: 0, APPROVED: 1 }

    TYPES = %i[event_ticket].freeze

    belongs_to :product, class_name: 'Spree::Product'

    has_one_attached :logo do |attachable|
      attachable.variant :thumb, resize_to_limit: [60, 60]
      attachable.variant :small, resize_to_limit: [180, 180]
    end
    has_one_attached :hero_image do |attachable|
      attachable.variant :mini, resize_to_limit: [240, 120]
      attachable.variant :small, resize_to_limit: [180, 180]
      attachable.variant :large, resize_to_limit: [960, 480]
    end

    validates :hero_image, presence: true, on: :update

    # default to event
    def object_builder
      SpreeCmCommissioner::GoogleWallets::EventTicketObjectBuilder
    end

    def class_creator
      SpreeCmCommissioner::GoogleWallets::EventTicketClassCreator.new(self)
    end

    def class_updater
      SpreeCmCommissioner::GoogleWallets::EventTicketClassUpdater.new(self)
    end
  end
end
