module SpreeCmCommissioner
  class OptionTypeVariantsPublicMetadataUpdaterJob < ApplicationJob
    def perform(option_type_id)
      optino_type = ::Spree::OptionType.find(option_type_id)
      optino_type.variants.find_each(&:set_options_to_public_metadata!)
    end
  end
end
