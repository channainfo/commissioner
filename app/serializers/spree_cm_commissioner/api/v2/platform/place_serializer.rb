module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        class PlaceSerializer < ::Spree::Api::V2::Platform::BaseSerializer
          attributes :name, :base_64_content
        end
      end
    end
  end
end
