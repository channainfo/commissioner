module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_rich_text :excerpt
    has_rich_text :body

    has_many :notifications, as: :notificable, dependent: :destroy
    has_many :feature_images, -> { order(:position) }, as: :viewable, dependent: :destroy, class_name: 'SpreeCmCommissioner::FeatureImage'

    validates :title, presence: true
    validates :url, presence: true
    validates_associated :feature_image

    validates :payload, presence: true
    validates :notification_type, presence: true
  end
end
