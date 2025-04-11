module SpreeCmCommissioner
  module Stock
    class PermanentInventoryItemsGeneratorJob < ApplicationUniqueJob
      def perform
        SpreeCmCommissioner::Stock::PermanentInventoryItemsGenerator.call
      end
    end
  end
end
