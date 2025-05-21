require "spec_helper"
require "csv"

RSpec.describe SpreeCmCommissioner::Imports::CreateOrderService do
  let(:variant1) { create(:cm_variant) }
  let(:variant2) { create(:cm_variant) }
  let(:variant3) { create(:cm_variant) }

  let(:guest1) { create(:guest) }
  let(:guest2) { create(:guest) }
  let(:guest3) { create(:guest) }

  let(:line_item1) { create(:line_item , guests: [guest1]) }
  let(:line_item2) { create(:line_item , guests: [guest2]) }
  let(:line_item3) { create(:line_item , guests: [guest3]) }

  let(:existing_order1) { create(:order, state: "complete", channel: "spree" , line_items: [line_item1])}
  let(:existing_order2) { create(:order, state: "complete", channel: "spree" , line_items: [line_item2])}
  let(:existing_order3) { create(:order, state: "complete", channel: "spree" , line_items: [line_item3])}

  let(:new_orders_data) do
    CSV.generate do |csv|
      csv << ['order_channel', 'variant_sku', 'quantity',       'email',         'phone_number',  'first_name',  'last_name']
      csv << ['google_form',    variant1.sku,    2,        'user1@gmail.com',     '012000001' ,   'Panha 1',      'Chom 1']
      csv << ['google_form',    variant2.sku,    2,        'user2@gmail.com',     '012000002',    'Panha 2' ,     'Chom 2']
      csv << ['google_form',    variant3.sku,    2,        'user3@gmail.com',     '012000003',    'Panha 3' ,     'Chom 3']
      csv << ['google_form',    'invalid',       1,        'user4@gmail.com',     '012000004',    'Panha 4' ,     'Chom 4']
      csv << ['google_form',    variant3.sku,    1,               ''          ,         ''        'Panha 5' ,     'Chom 5']
    end
  end

  let(:import_new_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'Import New Order') }

  let(:user) { create(:user) }

  describe "#import new orders" do

    subject { described_class.new(import_order_id: import_new_order.id, import_by_user_id: user.id) }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(new_orders_data)
    end

    it "updates import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_new_order.reload.status).to eq("progress")
    end

    it "records error when variant not found" do
      subject.call
      expect(import_new_order.reload.preferred_fail_rows).to include('5')  # row 5
    end

    it "records error when email/phone_number not found" do
      subject.call
      expect(import_new_order.reload.preferred_fail_rows).to include('6')  # row 6
    end

    it "imports orders" do
      subject.import_orders
      orders = Spree::Order.complete.order(:id)
      expect(orders.count).to eq(3)
      expect(orders.sum { |order| order.line_items.sum(:quantity) }).to eq(6)

      orders.each do |order|
        expect(order.payment_state).to eq('paid')
        expect(order.state).to eq('complete')
      end
    end

    it "updates import status to done" do
      subject.update_import_status_when_finish(:done)
      expect(import_new_order.reload.status).to eq("done")
    end

    context "when an error occurs during import" do
      before do
        allow(subject).to receive(:import_orders).and_raise(StandardError)
      end

      it "updates the import status to failed" do
        expect { subject.call }.to raise_error(StandardError)
        expect(import_new_order.reload.status).to eq("failed")
      end
    end
  end
end
