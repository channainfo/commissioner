require 'spec_helper'

RSpec.describe Spree::Api::Webhook::BaseController, type: :controller do
  controller do
    # Defining a dummy action for an anynomous controller which inherits from the described class.
    def index
      head :ok
    end
  end

  let!(:webhook_subscriber) { create(:cm_webhook_subscriber) }

  context 'when headers are correct' do
    it 'return success' do
      request.headers['X-Api-Name'] = webhook_subscriber.name
      request.headers['X-Api-Key'] = webhook_subscriber.api_key

      get :index

      expect(response).to have_http_status(200)
    end
  end

  context 'when headers are missing' do
    it 'return error' do
      get :index
      expect(response).to have_http_status(403)
    end
  end

  context 'when headers are incorrect' do
    it 'return error' do
      request.headers['X-Api-Name'] = webhook_subscriber.name
      request.headers['X-Api-Key'] = 'incorrect'

      get :index
      expect(response).to have_http_status(403)
    end
  end
end
