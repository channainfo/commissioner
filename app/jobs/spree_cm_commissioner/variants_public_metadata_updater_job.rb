# We can use this for migrating old datas.
module SpreeCmCommissioner
  class VariantsPublicMetadataUpdaterJob < ApplicationJob
    def perform
      Spree::Variant.find_each do |variant|
        variant.set_options_to_public_metadata

        # can skip even it failed
        variant.save
      end
    end
  end
end
