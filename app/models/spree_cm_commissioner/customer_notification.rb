module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_many :notifications, as: :notificable, dependent: :destroy, class_name: 'SpreeCmCommissioner::Notification'
    has_one :feature_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'

    has_many :notification_taxons, class_name: 'SpreeCmCommissioner::NotificationTaxon'
    has_many :taxons, through: :notification_taxons, class_name: 'Spree::Taxon'

    validates :title, presence: true
    validates :url, presence: true
    validates_associated :feature_image

    validates :payload, presence: true
    validates :notification_type, presence: true

    enum notification_type: { :promotion => 0, :announcement => 1 }

    def default_notification_image_url
      Spree::Store.default.default_notification_image&.styles&.first&.[](:url)
    end

    def push_notification_image_url
      return default_notification_image_url if feature_image.nil?

      image_attrs = feature_image.styles.first
      image_attrs[:url]
    end

    def self.scheduled_items
      where(['sent_at IS NULL AND started_at <= ? AND send_all = ?', Time.current, true])
    end
  end
end
