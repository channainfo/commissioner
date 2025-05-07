require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TaxonOptionValue, type: :model do
  describe 'associations' do
    it { should belong_to(:taxon).class_name('Spree::Taxon').dependent(:destroy) }
    it { should belong_to(:option_value).class_name('Spree::OptionValue').dependent(:destroy)}
  end
end