require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserIdentityProvider, type: :model do
  let(:user) { create(:user) }
  let(:user_identity_provider) { create(:user_identity_provider, user: user) }

  describe 'test association' do
    it { should belong_to(:user) }
  end

  describe 'test scope and validation' do
    it { should validate_presence_of(:sub) }
    it { should validate_presence_of(:identity_type) }
    it { should validate_uniqueness_of(:sub).scoped_to([:identity_type]) }
  end

  describe 'create user identity provider' do
    context 'return error when sub redundant' do
      it 'when sub is not unique' do
        user_1 = create(:user)
        user_2 = create(:user)
        uip_1 = create(:user_identity_provider, user: user_1)

        expect{create(:user_identity_provider, sub: uip_1.sub, user: user_2)}.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context 'return success' do
      it 'can create uid' do
        user = create(:user)
        uip = create(:user_identity_provider, user: user)

        expect(uip.user_id).to eq(user.id)
        expect(uip.sub).to be_present
      end
    end
  end
end
