require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class UserIdentityProvider < ApplicationRecord
    enum identity_type: { :google => 0, :apple => 1, :facebook => 2 }

    belongs_to :user, class_name: Spree.user_class.to_s

    validates :sub, presence: true
    validates :sub, uniqueness: { scope: :identity_type }

    validates :identity_type, presence: true
    validates :identity_type, uniqueness: { scope: :user_id }
  end
end
