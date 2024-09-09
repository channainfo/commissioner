require 'spec_helper'

RSpec.describe Spree::Api::V2::Storefront::IdCardsController, type: :controller do
  let(:id_card) { create(:id_card, card_type: 'passport') }

  let(:guest) { create(:guest) }

  let(:card_type) { 'student_id_card' }
  let(:front_image_url) { "https://example/front_image.jpg" }
  let(:back_image_url)  { "https://example/front_image.jpg" }

  context 'POST' do
    it 'return status code 200 ' do
      options = {
      card_type: card_type,
      front_image_url: front_image_url,
      back_image_url: back_image_url,
      guest_id: guest.id
      }

      post :create, params: options

      expect(response.status).to eq 200
    end

    it 'return status code 422 when front_image_url is nil  ' do
      options = {
      card_type: card_type,
      back_image_url: back_image_url,
      guest_id: guest.id
      }

      post :create, params: options

      expect(response.status).to eq 422
    end
  end

  context 'PATCH' do
    it 'return status code 200 ' do
      options = {
      id: id_card.id,
      card_type: card_type,
      front_image_url: front_image_url,
      back_image_url: back_image_url,
      guest_id: guest.id
      }

      patch :update, params: options

      expect(response.status).to eq 200
    end
  end

  context 'DELETE' do
    it 'return status code 204 ' do

      delete :destroy, params: { guest_id: guest.id, id: id_card.id }

      expect(response.status).to eq 204
    end
  end
end