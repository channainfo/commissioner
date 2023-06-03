module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_rich_text :body

    has_many :notifications, as: :notificable, dependent: :destroy
    has_one :feature_image, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'

    validates :title, presence: true
    validates :url, presence: true
    validates_associated :feature_image

    validates :payload, presence: true
    validates :notification_type, presence: true
  end

  def push_notification_image_url
    image_attrs = feature_image.style(:mini)
    image_attrs[:url]
  end
end
