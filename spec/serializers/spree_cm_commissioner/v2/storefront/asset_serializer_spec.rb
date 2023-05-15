require 'spec_helper'

describe SpreeCmCommissioner::V2::Storefront::AssetSerializer do
  let!(:vendor_logo) { create(:vendor_logo) }
  let!(:vendor) { create(:active_vendor, name: 'vendor', logo: vendor_logo) }

  subject { described_class.new(vendor_logo) }

  it { expect(subject.serializable_hash).to be_kind_of(Hash) }

  it 'returns right data attributes' do
    expect(subject.serializable_hash[:data].keys).to contain_exactly(:id, :type, :attributes)
  end

  it 'returns right asset attributes' do
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(
      :alt,
      :original_url,
      :position,
      :styles,
      :transformed_url
    )
  end
end
