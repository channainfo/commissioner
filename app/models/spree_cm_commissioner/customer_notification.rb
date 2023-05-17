module SpreeCmCommissioner
  class CustomerNotification < SpreeCmCommissioner::Base
    has_rich_text :excerpt
    has_rich_text :body

    has_many :notifications, as: :notificable, dependent: :destroy

    validates :title, presence: true
    validates :url, presence: true

    validates :payload, presence: true
    validates :notification_type, presence: true
  end
end
