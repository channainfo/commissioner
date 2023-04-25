require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class MarketingNotification < ApplicationRecord
    has_rich_text :exerpt
    has_rich_text :body

    has_many :notifications, as: :notificable, class_name: 'SpreeCommission::Notification', dependent: :destroy

    validates :title, presence: true
    validates :url, presence: true

    validates :payload, presence: true
  end
end
