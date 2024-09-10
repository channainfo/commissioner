require "spec_helper"
require "csv"

RSpec.describe SpreeCmCommissioner::Imports::UpdateOrderService do
  let(:variant1) { create(:variant) }
  let(:variant2) { create(:variant) }
  let(:variant3) { create(:variant) }

  let(:guest1) { create(:guest) }
  let(:guest2) { create(:guest) }
  let(:guest3) { create(:guest) }
  let(:guest4) { create(:guest) }

  let(:line_item1) { create(:line_item , guests: [guest1]) }
  let(:line_item2) { create(:line_item , guests: [guest2]) }
  let(:line_item3) { create(:line_item , guests: [guest3]) }
  let(:line_item4) { create(:line_item , guests: [guest4]) }

  let(:existing_order1) { create(:order, state: "complete", channel: "spree" , line_items: [line_item1])}
  let(:existing_order2) { create(:order, state: "complete", channel: "spree" , line_items: [line_item2])}
  let(:existing_order3) { create(:order, state: "complete", channel: "spree" , line_items: [line_item3])}
  let(:existing_order4) { create(:order, state: "complete", channel: "spree" , line_items: [line_item3])}

  let(:data) do
    CSV.generate do |csv|
      csv << ['order_number',          'phone_number',  'first_name',   'last_name'  ]
      csv << [existing_order1.number,   '012000001' ,    'Panha 1',      'Chom 1'   ]
      csv << [existing_order2.number,   '012000002' ,    'Panha 2',      'Chom 2'   ]
      csv << [existing_order3.number,   '012000003' ,    'Panha 3',      'Chom 3'   ]
      csv << ['R0000001',               '012000004' ,    'Panha 5',      'Chom 5'   ]
    end
  end

  let(:import_order) { SpreeCmCommissioner::Imports::ImportOrder.create(name: 'Update Orders') }

  let(:user) { create(:user) }

  describe "#bulk update orders" do

    subject { described_class.new(import_order_id: import_order.id) }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(data)
    end

    it "updates import status" do
      subject.update_import_status_when_start(:progress)
      expect(import_order.reload.status).to eq("progress")
    end

    it "imports orders" do
      subject.import_orders
      expect(existing_order1.reload.guests.first.phone_number).to eq '012000001'
      expect(existing_order1.reload.line_items.first.guests.first.full_name).to eq 'Panha 1 Chom 1'

      expect(existing_order2.reload.guests.first.phone_number).to eq '012000002'
      expect(existing_order2.reload.line_items.first.guests.first.full_name).to eq 'Panha 2 Chom 2'
    end


    it 'return record error when have order not found' do
      subject.call
      expect(import_order.reload.preferred_fail_rows).to include('5')  # row 5
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

  describe "#recalculate_order for update order type" do
    let(:line_item) { create(:line_item) }
    let(:existing_order) { create(:order, state: 'cart', line_items: [line_item]) }

    subject { described_class.new(import_order_id: import_order.id) }

    before do
      allow_any_instance_of(described_class).to receive(:fetch_content).and_return(data)
    end

    it "recalculates the order successfully with line items" do
      expect(existing_order).to receive(:update_with_updater!)
      subject.recalculate_order(existing_order)
    end
  end
end
