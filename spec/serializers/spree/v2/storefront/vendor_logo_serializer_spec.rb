require 'spec_helper'

describe Spree::V2::Storefront::VendorLogoSerializer do
  let!(:vendor_logo) { create(:vendor_logo) }
  let!(:vendor) { create(:active_vendor, name: 'vendor', logo: vendor_logo) }

  subject { described_class.new(vendor_logo) }

  it { expect(subject.serializable_hash).to be_kind_of(Hash) }

  it 'returns right data attributes' do
    expect(subject.serializable_hash[:data].keys).to contain_exactly(:id, :type, :attributes)
  end

  it 'returns right vendor_logo attributes' do
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(:styles)
  end
end
