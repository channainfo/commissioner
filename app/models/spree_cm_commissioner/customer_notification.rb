module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_many :notifications, as: :notificable, dependent: :destroy
    has_one :feature_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'

    validates :title, presence: true
    validates :url, presence: true
    validates_associated :feature_image

    validates :payload, presence: true
    validates :notification_type, presence: true

    def push_notification_image_url
      image_attrs = feature_image.style(:mini)
      image_attrs[:url]
    end

    def self.scheduled_items
      where(['sent_at IS NULL AND started_at <= ? AND send_all = ?', Time.current, true])
    end
  end
end
