require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class DeviceToken < ApplicationRecord
    belongs_to :user, class_name: 'Spree::User'

    validates :registration_token, uniqueness: { scope: %i[user_id client_name] }
    validates :registration_token, presence: true
  end
end
