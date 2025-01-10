module SpreeCmCommissioner
  class OptionValueVariantsPublicMetadataUpdaterJob < ApplicationUniqueJob
    def perform(option_value_id)
      option_value = ::Spree::OptionValue.find(option_value_id)
      option_value.variants.find_each(&:set_options_to_public_metadata!)
    end
  end
end
