module SpreeCmCommissioner
  class InventoryItemGeneratorJob < ApplicationUniqueJob
    def perform
      InventoryItemGenerator.call
    end
  end
end
