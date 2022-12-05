require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VendorSearch, type: :service do
  let(:params) { {name: 'White Mansion', province_id: 22} }

  context '#method_missing - use attribute in params as method call' do
    let(:subject) { described_class.new(params) }
    it 'returns White Mansion' do
      expect(subject.name).to eq('White Mansion')
    end
    it 'returns 22' do
      expect(subject.province_id).to eq(22)
    end

    it 'error MethodNoFund' do
      expect { subject.unknown }.to raise_error(NoMethodError)
    end
  end

  context '#call' do
    it 'call search on Vendor' do
      expect(Spree::Vendor).to receive(:search)
      described_class.new(params).call
    end
  end
end
