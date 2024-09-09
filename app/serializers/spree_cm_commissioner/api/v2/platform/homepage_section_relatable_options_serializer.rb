module SpreeCmCommissioner
  module Api
    module V2
      module Platform
        class HomepageSectionRelatableOptionsSerializer < ::Spree::Api::V2::Platform::BaseSerializer
          attribute :name do |object|
            if object.respond_to?(:pretty_name)
              object.pretty_name
            elsif object.respond_to?(:name)
              object.name
            end
          end
        end
      end
    end
  end
end
