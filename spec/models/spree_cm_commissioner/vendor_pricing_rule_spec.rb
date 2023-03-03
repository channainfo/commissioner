require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorPricingRule, type: :model do
  describe 'associations' do
    it { should belong_to(:vendor).class_name('Spree::Vendor').dependent(:destroy) }
  end

  describe 'attributes' do
    subject { described_class.new }

    it { should have_db_column(:date_rule) }
    it { should have_db_column(:operator) }
    it { should have_db_column(:amount) }
    it { should have_db_column(:length) }
    it { should have_db_column(:position) }
    it { should have_db_column(:free_cancellation) }
    it { should have_db_column(:vendor_id) }
  end

  describe 'virtual attributes' do
    subject { described_class.new }

    it { should have_attr_accessor(:price_by_dates) }
    it { should have_attr_accessor(:min_price_by_rule) }
    it { should have_attr_accessor(:max_price_by_rule) }
  end
end
