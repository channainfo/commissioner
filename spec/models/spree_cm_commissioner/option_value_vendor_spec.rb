require 'spec_helper'

RSpec.describe SpreeCmCommissioner::OptionValueVendor, type: :model do
  describe 'associations' do 
    it { should belong_to(:vendor).class_name('Spree::Vendor').dependent(:destroy) }
    it { should belong_to(:option_value).class_name('Spree::OptionValue').dependent(:destroy)}
  end
end
