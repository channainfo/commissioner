require "spec_helper"
require "csv"

RSpec.describe SpreeCmCommissioner::Imports::ImportOrderService do
  let(:variant1) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:variant3) { create(:variant) }

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
      csv << ['order_channel', 'order_email', 'order_phone_number', 'variant_sku']
      csv << ['google_form', 'user1@gmail.com', '012000001', variant1.sku]
      csv << ['google_form', 'user2@gmail.com', '012000002', variant2.sku]
      csv << ['google_form', 'user3@gmail.com', '012000003', variant3.sku]
    end
  end

  let(:existing_orders_data) do
    CSV.generate do |csv|
      csv << ['order_number','order_channel', 'order_email', 'order_phone_number', 'first_name', 'last_name', 'age']
      csv << [existing_order1.number,existing_order1.channel, 'existing_user1@gmail.com', '023000001', 'Guest', 'Name 1', '21']
      csv << [existing_order2.number,existing_order2.channel, 'existing_user2@gmail.com', '023000002', 'Guest', 'Name 2', '22']
      csv << [existing_order3.number,existing_order3.channel, 'existing_user3@gmail.com', '023000003', 'Guest', 'Name 3', '23']
    end
  end


  let(:import_new_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'Import New Order') }
  let(:import_exist_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'Import Existing Order') }

  let(:user) { create(:user) }

  describe "#import new orders" do

    subject { described_class.new(import_order_id: import_new_order.id, import_by_user_id: user.id, import_type: 'new_order') }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(new_orders_data)
    end

    it "updates import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_new_order.reload.status).to eq("progress")
    end

    it "imports orders" do
      subject.import_orders

      orders = Spree::Order.complete.order(:id)

      expect(orders.count).to eq(3)
      expect(Spree::Order.pluck(:email)).to match_array(['user1@gmail.com', 'user2@gmail.com', 'user3@gmail.com'])
      expect(Spree::Order.pluck(:phone_number)).to match_array(['012000001', '012000002', '012000003'])
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

  describe "#existing_order_import" do

    subject { described_class.new(import_order_id: import_exist_order.id , import_by_user_id: user.id, import_type: 'existing_order') }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(existing_orders_data)
    end

    it "updates import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_exist_order.reload.status).to eq("progress")
    end

    it "imports orders" do
      subject.import_orders

      expect(existing_order1.reload.email).to eq 'existing_user1@gmail.com'
      expect(existing_order1.reload.phone_number).to eq '023000001'
      expect(existing_order1.reload.line_items.first.guests.first.full_name).to eq 'Guest Name 1'

      expect(existing_order2.reload.email).to eq 'existing_user2@gmail.com'
      expect(existing_order2.reload.phone_number).to eq '023000002'
      expect(existing_order2.reload.line_items.first.guests.first.full_name).to eq 'Guest Name 2'

      expect(existing_order3.reload.email).to eq 'existing_user3@gmail.com'
      expect(existing_order3.reload.phone_number).to eq '023000003'
      expect(existing_order3.reload.line_items.first.guests.first.full_name).to eq 'Guest Name 3'
    end

    it "updates import status to done" do
      subject.update_import_status_when_finish(:done)
      expect(import_exist_order.reload.status).to eq("done")
    end

    context "when an error occurs during import" do
      before do
        allow(subject).to receive(:import_orders).and_raise(StandardError)
      end

      it "updates the import status to failed" do
        expect { subject.call }.to raise_error(StandardError)
        expect(import_exist_order.reload.status).to eq("failed")
      end
    end
  end

  describe "#recalculate_order for existing order type" do
    let(:line_item) { create(:line_item) }
    let(:existing_order) { create(:order, state: 'cart', line_items: [line_item]) }

    subject { described_class.new(import_order_id: import_exist_order.id, import_by_user_id: user.id, import_type: 'existing_order') }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(existing_orders_data)
    end
    
    it "recalculates the order successfully with line items" do
      expect(existing_order).to receive(:update_with_updater!)
      subject.recalculate_order(existing_order)
    end
  end
end
