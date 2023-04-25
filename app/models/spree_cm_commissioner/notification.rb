require_dependency 'spree_cm_commissioner'

module SpreeCmCommissioner
  class Notification < ApplicationRecord
    include Noticed::Model

    belongs_to :recipient, polymorphic: true
    belongs_to :notificable, polymorphic: true
  end
end
