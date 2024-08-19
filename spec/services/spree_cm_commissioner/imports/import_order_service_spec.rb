require "spec_helper"

RSpec.describe SpreeCmCommissioner::Imports::ImportOrderService do
  let(:variant1) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:variant3) { create(:variant) }
  let(:orders) {
    [
      {
        order_channel: 'google_form',
        order_email: 'abc@gmail.com',
        order_phone_number: '1234567890',
        variant_sku: variant1.sku,
        first_name: 'John',
        last_name: 'Doe',
        age: 10,
      },
      {
        order_channel: 'spree',
        order_email: 'valo@gmail.com',
        order_phone_number: '1234567890',
        variant_sku: variant2.sku,
        first_name: 'Foo',
        last_name: 'Bar',
        age: 10,
      },
      {
        order_channel: 'telegram',
        order_email: 'zerko@gmail.com',
        order_phone_number: '1234567890',
        variant_sku: variant3.sku,
        first_name: 'Zakk',
        last_name: 'Ko',
        age: 10,
      }
    ]
  }

  let(:import_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'test-import') }
  let(:user) { create(:user) }

  subject { described_class.new(import_order_id: import_order.id, orders: orders, import_by: user, import_type: 'new_order') }

  describe "#call" do
    it "updates import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_order.reload.status).to eq("progress")
    end

    it "imports orders" do
      subject.import_orders(orders)

      expect(Spree::Order.count).to eq(3)

      orders.each_with_index do |order, index|
        expect(order[:order_channel]).to eq(orders[index][:order_channel])
        expect(order[:order_email]).to eq(orders[index][:order_email])
        expect(order[:order_phone_number]).to eq(orders[index][:order_phone_number])
        expect(order[:variant_id]).to eq(orders[index][:variant_id])
        expect(order[:first_name]).to eq(orders[index][:first_name])
        expect(order[:last_name]).to eq(orders[index][:last_name])
        expect(order[:age]).to eq(orders[index][:age])
      end
    end

    it "updates import status to done" do
      subject.update_import_status_when_finish(:done)
      expect(import_order.reload.status).to eq("done")
    end

    context "when an error occurs during import" do
      before do
        allow(subject).to receive(:import_orders).and_raise(StandardError)
      end

      it "updates the import status to failed" do
        expect { subject.call }.to raise_error(StandardError)
        expect(import_order.reload.status).to eq("failed")
      end
    end
  end

  describe "#existing_order_import" do
    let(:guest) { create(:guest) }
    let(:line_item) { create(:line_item , guests: [guest]) }
    let(:existing_order) { create(:order, number: "R123456789", state: "complete", channel: "spree" , line_items: [line_item])}
    let(:orders) {
      [
        {
          order_number: existing_order.number,
          order_channel: 'google_form',
          order_email: 'new@gmail.com',
          order_phone_number: '9876543210',
          first_name: 'Panha',
          last_name: 'Chom',
          age: 21,
        }
      ]
    }

    subject { described_class.new(import_order_id: import_order.id, orders: orders, import_by: user, import_type: 'existing_order') }

    it "updates existing order details" do
      subject.import_orders(orders)
      existing_order.reload

      expect(existing_order.channel).to eq('google_form')
      expect(existing_order.email).to eq('new@gmail.com')
      expect(existing_order.phone_number).to eq('9876543210')
    end

    it "update guest details" do
      subject.import_orders(orders)

      guest = existing_order.reload.line_items.first.guests.first
      expect(guest.first_name).to eq('Panha')
      expect(guest.last_name).to eq('Chom')
      expect(guest.age).to eq(21)
    end
  end

  describe "#call" do
    context "when orders array is empty" do
      let(:orders) { [] }
      it "does not create any orders" do
        subject.import_orders(orders)
        expect(Spree::Order.count).to eq(0)
      end

      it "updates the import status to done" do
        subject.call
        expect(import_order.reload.status).to eq("done")
      end
    end
  end
end
