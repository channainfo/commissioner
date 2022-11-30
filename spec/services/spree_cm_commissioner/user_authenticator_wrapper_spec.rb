require 'spec_helper'

RSpec.describe SpreeCmCommissioner::UserAuthenticatorWrapper do
  let!(:user) { create(:user, password: '12345678', email: 'abc@vtenh.com') }

  it 'returns log into user when email & password valid' do
    params = { 
      username: user.email,
      password: user.password
    }

    authenticated_user = described_class.call?(params)
    expect(authenticated_user.email).to eq 'abc@vtenh.com'
  end
end
