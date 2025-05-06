module Spree
  module V2
    module Organizer
      class OptionTypesSerializer < BaseSerializer
        attributes :name, :presentation, :kind
      end
    end
  end
end
