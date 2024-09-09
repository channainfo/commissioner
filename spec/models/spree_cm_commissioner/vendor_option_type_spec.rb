require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorOptionType, type: :model do
  describe 'associations' do 
    it { should belong_to(:vendor).class_name('Spree::Vendor').dependent(:destroy) }
    it { should belong_to(:option_type).class_name('Spree::OptionType').dependent(:destroy) }
  end
end
