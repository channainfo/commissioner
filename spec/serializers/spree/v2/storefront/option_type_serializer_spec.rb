require 'spec_helper'

describe Spree::V2::Storefront::OptionTypeSerializer, type: :serializer do
  let(:option_type) { create(:option_type, attr_type: "string") }

  subject { described_class.new(option_type) }

  it { expect(subject.serializable_hash).to be_kind_of(Hash) }

  it 'returns right data attributes' do
    expect(subject.serializable_hash[:data].keys).to contain_exactly(:attributes, :id, :relationships, :type)
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(
      :attr_type, 
      :is_master, 
      :name, 
      :position, 
      :presentation, 
      :public_metadata
    )
  end
end
