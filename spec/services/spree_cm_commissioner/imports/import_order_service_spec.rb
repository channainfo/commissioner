require "spec_helper"

RSpec.describe SpreeCmCommissioner::Imports::ImportOrderService do
  let(:variant1) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:variant3) { create(:variant) }
  let(:orders) {
    [
      {
        order_channel: 'web',
        order_email: 'abc@gmail.com',
        order_phone_number: '1234567890',
        variant_id: variant1.id,
        first_name: 'John',
        last_name: 'Doe',
        age: 10,
      },
      {
        order_channel: 'app',
        order_email: 'valo@gmail.com',
        order_phone_number: '1234567890',
        variant_id: variant2.id,
        first_name: 'Foo',
        last_name: 'Bar',
        age: 10,
      },
      {
        order_channel: 'mobile',
        order_email: 'zerko@gmail.com',
        order_phone_number: '1234567890',
        variant_id: variant3.id,
        first_name: 'Zakk',
        last_name: 'Ko',
        age: 10,
      }
    ]
  }

  let(:import_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'test-import')}
  let(:user) { create(:user) }

  subject { described_class.new(import_order_id: import_order.id, orders: orders, import_by: user) }

  describe "#call" do
    it "update import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_order.reload.status).to eq("progress")
    end

    it "import orders" do
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

    it "update import status to done" do
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
end
