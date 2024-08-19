module SpreeCmCommissioner
  module V2
    module Storefront
      class ProductPlaceSerializer < BaseSerializer
        attributes :place, :type, :checkinable_distance
      end
    end
  end
end
