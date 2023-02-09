require 'spec_helper' 

describe Spree::V2::Storefront::UserSerializer, type: :serializer do 
  let(:user) { create(:user) }

  subject { described_class.new(user) }

  it 'returns right data attributes' do 
    expect(subject.serializable_hash[:data].keys). to contain_exactly(:attributes, :id, :relationships, :type)
  end

  it 'returns right user attributes' do 
    expect(subject.serializable_hash[:data][:attributes].keys).to contain_exactly(
      :completed_orders, 
      :email, 
      :first_name,
      :last_name, 
      :public_metadata, 
      :store_credits
    )
  end
end