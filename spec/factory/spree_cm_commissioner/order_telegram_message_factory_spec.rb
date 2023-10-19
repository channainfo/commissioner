require "spec_helper"

RSpec.describe SpreeCmCommissioner::OrderTelegramMessageFactory do
  describe '#header' do
    it 'return header' do
      subject = described_class.new(title: '🎫 --- [NEW ORDER FROM BOOKME+] ---', order: nil)
      expect(subject.header).to eq "<b>🎫 --- [NEW ORDER FROM BOOKME+] ---</b>"
    end
  end

  describe '#body' do
    context 'for all vendor' do
      let(:vendor) { create(:vendor, name: "Sai") }
      let(:product) { create(:product_with_option_types, name: "5km Running Ticket", vendor: vendor, product_type: :accommodation) }
      let(:line_item) { build(:line_item, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-12')) }
      let(:order) { create(:order, line_items: [line_item]) }

      it 'return body of all line items' do
        subject = described_class.new(title: '🎫 --- [NEW ORDER FROM BOOKME+] ---', order: order)

        expect(subject.body).to eq "Order Number:\n<code>#{order.number}</code>\n\n[ x1 ]\n<b>5km Running Ticket</b>\n<i>🗓️ Jan 11, 2023 -> Jan 12, 2023</i>\n<i>🏪 Sai</i>"
      end
    end

    context 'for specific vendor' do
      let(:vendor1) { create(:vendor, name: "Sai") }
      let(:vendor2) { create(:vendor, name: "Sai 2") }

      let(:product1) { create(:product_with_option_types, name: "5km Running Ticket", vendor: vendor1, product_type: :accommodation) }
      let(:product2) { create(:product_with_option_types, name: "10km Running Ticket", vendor: vendor2, product_type: :accommodation) }

      let(:line_item1) { build(:line_item, product: product1, from_date: date('2023-01-11'), to_date: date('2023-01-12')) }
      let(:line_item2) { build(:line_item, product: product2, from_date: date('2023-01-11'), to_date: date('2023-01-12')) }

      let(:order) { create(:order, line_items: [line_item1, line_item2]) }

      it 'return body with line item of vendor1' do
        subject = described_class.new(title: '🎫 --- [NEW ORDER FROM BOOKME+] ---', order: order, vendor: vendor1)

        expect(subject.body).to eq "Order Number:\n<code>#{order.number}</code>\n\n[ x1 ]\n<b>#{product1.name}</b>\n<i>🗓️ Jan 11, 2023 -> Jan 12, 2023</i>"
      end
    end

    context 'line item with same from date & to date' do
      let(:vendor) { create(:vendor, name: "Sai") }
      let(:product) { create(:product_with_option_types, name: "5km Running Ticket", vendor: vendor, product_type: :accommodation) }
      let(:line_item) { build(:line_item, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-11')) }
      let(:order) { create(:order, line_items: [line_item]) }

      it 'return body of all line items' do
        subject = described_class.new(title: '🎫 --- [NEW ORDER FROM BOOKME+] ---', order: order)

        expect(subject.body).to eq "Order Number:\n<code>#{order.number}</code>\n\n[ x1 ]\n<b>5km Running Ticket</b>\n<i>🗓️ Jan 11, 2023</i>\n<i>🏪 Sai</i>"
      end
    end
  end

  describe '#footer' do
    let(:order) { create(:order, phone_number: "012345678") }

    it 'return footer with customer infos' do
      subject = described_class.new(title: '🎫--- [NEW ORDER FROM BOOKME+] ---', order: order)

      expect(subject.footer).to eq "<b>🙍 Customer Info</b>\nName: #{order.name}\nTel: <code>+85512345678</code>\nEmail: <code>#{order.email}</code>"
    end
  end

  describe '#message' do
    let(:vendor) { create(:vendor, name: "Sai") }
    let(:product) { create(:product_with_option_types, name: "5km Running Ticket", vendor: vendor, product_type: :accommodation) }
    let(:line_item) { build(:line_item, product: product, from_date: date('2023-01-11'), to_date: date('2023-01-12')) }
    let(:order) { create(:order, line_items: [line_item], phone_number: "012345678") }

    it 'return message by combine header, body, footer' do
      subject = described_class.new(title: '🎫--- [NEW ORDER FROM BOOKME+] ---', order: order)

      expect(subject.message).to eq [subject.header, subject.body, subject.footer].join("\n\n")
    end
  end
end