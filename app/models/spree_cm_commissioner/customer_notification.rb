module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_many :notifications, as: :notificable, dependent: :destroy, class_name: 'SpreeCmCommissioner::Notification'

    # deprecated
    has_one :feature_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'

    has_many :feature_images, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'
    has_many :notification_taxons, dependent: :destroy, class_name: 'SpreeCmCommissioner::NotificationTaxon'
    has_many :taxons, through: :notification_taxons, class_name: 'Spree::Taxon'

    belongs_to :vendor, class_name: 'Spree::Vendor'

    validates :title, presence: true
    validates :url, presence: true

    validates :notification_type, presence: true

    self.whitelisted_ransackable_attributes = %w[title excerpt notification_type]
    self.whitelisted_ransackable_associations = %w[notification_taxons taxons]

    enum notification_type: { :promotion => 0, :announcement => 1 }

    def push_notification_image_url
      return nil if feature_images.empty?

      main_image_url
    end

    def main_image_url
      feature_images.first.styles.last[:url]
    end

    def self.scheduled_items
      where(['sent_at IS NULL AND started_at <= ?', Time.current])
    end
  end
end
