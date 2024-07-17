module SpreeCmCommissioner
  class HotelGoogleWallet < GoogleWallet
    preference :hotel_name, :string
    preference :hotel_address, :string
    preference :background_color, :string

    validates :preferred_hotel_name, presence: true, on: :update
    validates :preferred_hotel_address, presence: true, on: :update
    validates :preferred_background_color, presence: true, on: :update

    before_save :set_class_id
    before_create :set_default_preferences

    def set_default_preferences
      self.preferred_hotel_name ||= product.vendor.name
      self.preferred_hotel_address ||= product.vendor.stock_location.address1
      self.preferred_background_color = '#000000'
    end

    def set_class_id
      return unless class_id.nil?

      self.class_id = product.slug
    end

    def object_builder
      SpreeCmCommissioner::GoogleWallets::HotelObjectBuilder
    end

    def class_creator
      SpreeCmCommissioner::GoogleWallets::HotelClassCreator.new(self)
    end

    def class_updater
      SpreeCmCommissioner::GoogleWallets::HotelClassUpdater.new(self)
    end
  end
end
