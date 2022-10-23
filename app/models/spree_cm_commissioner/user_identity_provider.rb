require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class UserIdentityProvider < ApplicationRecord
    enum identity_type: %i[google apple facebook]

    belongs_to :user, class_name: "#{Spree.user_class}", foreign_key: :user_id

    validates :sub, presence: true
    validates :sub, uniqueness: { scope: :identity_type }

    validates :identity_type, presence: true
    validates :identity_type, uniqueness: { scope: :user_id }
  end
end
