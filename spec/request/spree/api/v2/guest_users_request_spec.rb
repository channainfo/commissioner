require 'spec_helper'

RSpec.describe "Spree::Api::V2::Storefront::GuestUsersController", type: :request do
  describe "POST /api/v2/storefront/guest_users" do
    let(:headers) { { "Authorization" => "Bearer #{token}" } }

    subject(:send_request) { post "/api/v2/storefront/guest_users", headers: headers }

    context "when the token does not belong to a valid application" do
      let(:token) { create(:oauth_access_token, application: nil).token }

      it "raises a DoorkeeperError" do
        send_request

        expect(response).to have_http_status(401)
      end
    end

    context "when the token is valid" do
      let(:oauth_token) { create_application_token }
      let(:token) { oauth_token.token }

      context "when the guest user is successfully created" do
        it "returns a 201 status and the token response" do
          send_request

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body)).to have_key("access_token")
        end

        it "creates a guest user" do
          expect { send_request }.to change { Spree::User.where(guest: true).count }.by(1)
        end
      end

      context "when the guest user creation fails" do
        let(:user) { build(:user).tap { |u| u.errors.add(:email, "is already taken") } }
        let(:context) { double(:context, success?: false, message: "message") }

        before do
          allow(SpreeCmCommissioner::GuestUserCreation).to receive(:call).once.and_return(context)
        end

        it "returns a 422 status and the error messages" do
          send_request

          expect(response).to have_http_status(422)
          expect(JSON.parse(response.body)).to eq("error" => "message")
        end
      end
    end
  end
end
