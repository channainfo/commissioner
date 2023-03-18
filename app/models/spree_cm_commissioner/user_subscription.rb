require_dependency 'spree_cm_commissioner'

class SpreeCmCommissioner::UserSubscription < ApplicationRecord
  enum status: { :active => 0, :suspended => 1, :inactive => 2 }

  belongs_to :user, class_name: 'Spree::User', dependent: :destroy
  belongs_to :variant, class_name: 'Spree::Variant', dependent: :destroy
end
