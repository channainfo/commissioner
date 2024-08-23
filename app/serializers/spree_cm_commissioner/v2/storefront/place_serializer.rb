module SpreeCmCommissioner
  module V2
    module Storefront
      class PlaceSerializer < BaseSerializer
        attributes :id, :name, :vicinity, :lat, :lon
      end
    end
  end
end
