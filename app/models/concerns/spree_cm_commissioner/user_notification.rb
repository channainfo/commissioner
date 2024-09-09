module SpreeCmCommissioner
  module UserNotification
    extend ActiveSupport::Concern

    included do
      has_many :notifications, class_name: 'SpreeCmCommissioner::Notification', as: :recipient, dependent: :destroy
      has_many :device_tokens, class_name: 'SpreeCmCommissioner::DeviceToken'

      scope :push_notificable, -> { where('device_tokens_count > 0') }

      def self.end_users_push_notificable
        end_users.push_notificable
      end
    end
  end
end
