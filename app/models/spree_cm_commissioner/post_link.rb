module SpreeCmCommissioner
  class PostLink < ApplicationRecord
    belongs_to :product, class_name: 'Spree::Product'
  end
end
