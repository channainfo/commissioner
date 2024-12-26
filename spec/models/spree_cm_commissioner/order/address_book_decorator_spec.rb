require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Order::AddressBookDecorator, type: :model do
  describe '#bill_address_attributes=' do
    let!(:existing_address) { create(:address, first_name: "Panha", last_name: "Chom", city: "Poi Pet") }

    context 'when it is guest order' do
      context 'when no existing billing address' do
        let!(:order1) { create(:order, billing_address: nil, user_id: nil) }
        let(:address_attributes) do
          { city: "Phnom Penh", address1: "Lovely Street", state_id: existing_address.state_id, country_id: existing_address.country_id, zipcode: existing_address.zipcode }
        end

        it 'reject bill address when basic info is not provided' do
          order1.bill_address_attributes = address_attributes

          expect(order1.save).to be true
          expect(order1.bill_address.nil?).to be true
        end

        it 'saved new bill address when basic info is provided' do
          order1.bill_address_attributes = address_attributes.merge({ firstname: "Thea", lastname: "Choem", phone: "012345678" })

          expect(order1.save).to be true
          expect(order1.bill_address.id).to be_present
        end
      end

      context 'when is existing billing address' do
        let!(:order1) { create(:order, billing_address: existing_address, user_id: nil) }

        it 'just save bill address (bill_address.id is all it need)' do
          order1.bill_address_attributes = { city: "New Phnom Penh", address1: "New Address Right Here" }

          expect(order1.save).to be true
          expect(order1.bill_address.city).to eq "New Phnom Penh"
          expect(order1.bill_address.address1).to eq "New Address Right Here"
          expect(order1.bill_address.id).to eq existing_address.id
        end
      end
    end
  end

  describe '#ship_address_attributes=' do
    let!(:existing_address) { create(:address, first_name: "Panha", last_name: "Chom", city: "Poi Pet") }

    context 'when it is guest order' do
      context 'when no existing billing address' do
        let!(:order1) { create(:order, billing_address: nil, ship_address: nil, user_id: nil) }
        let(:address_attributes) do
          { city: "Phnom Penh", address1: "Lovely Street", state_id: existing_address.state_id, country_id: existing_address.country_id, zipcode: existing_address.zipcode }
        end

        it 'reject shipping address when basic info is not provided' do
          order1.ship_address_attributes = address_attributes

          expect(order1.save).to be true
          expect(order1.ship_address.nil?).to be true
        end

        it 'saved new shipping address when basic info is provided' do
          order1.ship_address_attributes = address_attributes.merge({ firstname: "Thea", lastname: "Choem", phone: "012345678" })

          expect(order1.save).to be true
          expect(order1.ship_address.id).to be_present
        end
      end

      context 'when is existing billing address' do
        let!(:order1) { create(:order, billing_address: existing_address, ship_address: existing_address, user_id: nil) }

        it 'just save shipping address (shipping_address.id is all it need)' do
          order1.ship_address_attributes = { city: "New Phnom Penh", address1: "New Address Right Here" }

          expect(order1.save).to be true
          expect(order1.ship_address.city).to eq "New Phnom Penh"
          expect(order1.ship_address.address1).to eq "New Address Right Here"
          expect(order1.ship_address.id).to eq existing_address.id
        end
      end
    end
  end
end
