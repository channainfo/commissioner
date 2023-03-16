require 'spec_helper'

describe 'API V2 Storefront User Deletion Reason Spec', type: :request do
  describe 'state#index' do
    it 'return 401 unauthorized when user not authenticated' do
      get "/api/v2/storefront/user_deletion_reasons"
      create(:user_deletion_reason)

      parsed_body = JSON.parse(response.body)

      expect(response.status).to eq 403
      expect(parsed_body.key?("error")).to eq true
    end
  end
end
