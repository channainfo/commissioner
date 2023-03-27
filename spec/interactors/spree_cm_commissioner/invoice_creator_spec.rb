require 'spec_helper'

RSpec.describe SpreeCmCommissioner::InvoiceCreator do
  let(:vendor) { create(:active_vendor, name: 'vendor') }
  let(:product) { create(:cm_product ) }
  let(:line_item1) { create(:line_item, variant: product.master, from_date: '2023-06-23') }
  let(:line_item2) { create(:line_item, variant: product.master, from_date: '2023-07-18') }

  let(:order1) { create(:order, line_items: [line_item1]) }
  let(:order2) { create(:order, line_items: [line_item2]) }

  describe '#load_invoice_number' do
    it 'return invoice number with format month:year:other ' do
      result = described_class.new(order: order1)
      result.load_invoice_number

      expect(result.context.invoice_number).to eq '0623000001'
    end
  end

  describe '.call' do
    it 'return existing invoice if exist' do
      context1 = described_class.call(order: order1)
      context2 = described_class.call(order: order1)

      expect(SpreeCmCommissioner::Invoice.count).to eq 1
      expect(context1.invoice.invoice_number).to eq '0623000001'
      expect(context2.invoice.invoice_number).to eq '0623000001'
    end

    it 'return invoice with 2 different order ' do
      context1 = described_class.call(order: order1)
      context2 = described_class.call(order: order2)
      expect(context1.invoice.invoice_number).to eq '0623000001'
      expect(context2.invoice.invoice_number).to eq '0723000001'
    end

  end
end