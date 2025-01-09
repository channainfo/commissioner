module SpreeCmCommissioner
  class EventTicketGoogleWallet < GoogleWallet
    preference :issuer_name, :string
    preference :event_name, :string
    preference :venue_name, :string
    preference :venue_address, :string
    preference :start_date, :string
    preference :end_date, :string
    preference :background_color, :string
    preference :response, :string
    preference :verified_at, :string

    validates :preferred_issuer_name, presence: true, on: :update
    validates :preferred_event_name, presence: true, on: :update
    validates :preferred_venue_name, presence: true, on: :update
    validates :preferred_venue_address, presence: true, on: :update
    validates :preferred_start_date, presence: true, on: :update
    validates :preferred_end_date, presence: true, on: :update
    validates :preferred_background_color, presence: true, on: :update

    before_save :set_class_id
    before_create :set_default_preferences

    def set_default_preferences
      self.preferred_issuer_name ||= product.vendor.name
      self.preferred_event_name ||= product.name
      self.preferred_venue_name ||= product.venue.place.name
      self.preferred_venue_address ||= product.venue.place.vicinity
      self.preferred_start_date = event_start_date unless event_start_date.nil?
      self.preferred_end_date = event_end_date unless event_end_date.nil?
      self.preferred_background_color = '#000000'
      self.preferred_response = nil
      self.preferred_verified_at = nil
    end

    def verified?
      preferred_verified_at.present? && preferred_response.present?
    end

    def verify_create!(response)
      self.preferred_verified_at = DateTime.current
      self.preferred_response = response if response.present?
      save!
    end

    def verify!
      self.preferred_verified_at = DateTime.current
      save!
    end

    def verified_at
      DateTime.parse(preferred_verified_at).strftime('%B %d, %Y %I:%M %p') if preferred_verified_at.present?
    end

    def event_start_date
      product.taxons.first&.from_date
    end

    def event_end_date
      product.taxons.first&.to_date
    end

    def set_class_id
      return unless class_id.nil?

      self.class_id = product.slug
    end

    def class_creator
      SpreeCmCommissioner::GoogleWallets::EventTicketClassCreator.new(self)
    end

    def class_updater
      SpreeCmCommissioner::GoogleWallets::EventTicketClassUpdater.new(self)
    end

    def object_builder
      SpreeCmCommissioner::GoogleWallets::EventTicketObjectBuilder
    end
  end
end
