require 'spec_helper'

describe 'API V2 Storefront Account Checker Spec', type: :request do
  describe '#index' do
    let!(:user) { create(:cm_user, email: "l.regene10@gmail.com", login: 'l.regene', phone_number: "012934190" ) }

    it 'returns 422 when email already exists' do
      get "/api/v2/storefront/account_checker?login=l.regene10@gmail.com"

      json_response = JSON.parse(response.body)

      expect(response.status).to eq 422
      expect(json_response).to match({"error"=>"l.regene10@gmail.com already exist"})
    end

    it 'returns 200 when user already exists' do
      get "/api/v2/storefront/account_checker?login=wrong.email@gmail.com"

      expect(response.status).to eq 200
      expect(response.body).to eq ''
    end
  end
end
