require 'spec_helper'

describe Spree::V2::Storefront::VendorPhotoSerializer do
  let!(:vendor_photo) { create(:vendor_photo) }

  subject { described_class.new(vendor_photo) }

  it { expect(subject.serializable_hash).to be_kind_of(Hash) }

  it 'returns right data attributes' do
    expect(subject.serializable_hash[:data].keys).to contain_exactly(:id, :type, :attributes)
  end

  it 'returns right vendor_photo attributes' do
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(
      :alt,
      :original_url,
      :position,
      :styles,
      :transformed_url
    )
  end

  it 'returns expected 4x3 image styles' do
    styles = subject.serializable_hash[:data][:attributes][:styles]

    mini = styles[0]
    small = styles[1]
    medium = styles[2]

    expect(styles.size).to eq 3

    expect(mini[:width]).to eq "160"
    expect(mini[:height]).to eq "120"

    expect(small[:width]).to eq "480"
    expect(small[:height]).to eq "360"

    expect(medium[:width]).to eq "960"
    expect(medium[:height]).to eq "720"
  end
end
