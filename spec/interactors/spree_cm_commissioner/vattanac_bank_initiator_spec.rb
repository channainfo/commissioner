require 'spec_helper'

RSpec.describe SpreeCmCommissioner::VattanacBankInitiator do
  let(:user_data) do
    {
      'firstName' => 'John',
      'lastName' => 'Doe',
      'email' => 'john@example.com',
      'phoneNum' => '0123456789'
    }
  end

  let(:context) { Interactor::Context.new(user_data: user_data) }

  describe '#find_or_create_user' do
    subject(:interactor) do
      described_class.new(context)
    end

    before do
      allow(context).to receive(:fail!).and_call_original
    end

    context 'when user is found by identity provider' do
      let(:user) { create(:user) }
      let!(:identity) do
        create(:user_identity_provider, :vattanac_bank, sub: '0123456789', user: user)
      end

      it 'assigns the user from the identity' do
        interactor.send(:find_or_create_user)
        expect(context.user).to eq(user)
      end
    end

    context 'when user is found by email or phone' do
      let!(:user) do
        create(:user, email: 'john@example.com', phone_number: '987654321')
      end

      it 'finds and assigns the user' do
        interactor.send(:find_or_create_user)
        expect(context.user).to eq(user)
      end
    end

    context 'when user is not found and needs to be created' do
      it 'creates a new user and assigns it' do
        expect {
          interactor.send(:find_or_create_user)
        }.to change(Spree::User, :count).by(1)

        new_user = context.user
        expect(new_user.first_name).to eq('John')
        expect(new_user.last_name).to eq('Doe')
        expect(new_user.email).to eq('john@example.com')
        expect(new_user.phone_number).to eq('0123456789')

        expect(new_user.user_identity_providers.first.sub).to eq('0123456789')
      end
    end
  end
end
