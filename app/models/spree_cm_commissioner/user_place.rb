module SpreeCmCommissioner
  class UserPlace < ApplicationRecord
    belongs_to :user, class_name: 'Spree::User'
    belongs_to :place, class_name: 'SpreeCmCommissioner::Place'
  end
end
