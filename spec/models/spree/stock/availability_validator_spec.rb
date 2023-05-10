require 'spec_helper'

RSpec.describe Spree::Stock::AvailabilityValidator do
  context 'product type: accommodation' do
    let(:product) { create(:cm_accommodation_product, permanent_stock: 3) }
    let(:booked_date_from) { '2023-01-10'.to_date }
    let(:booked_date_to) { '2023-01-12'.to_date  }

    let!(:booked_line_item) { create(:line_item, quantity: 1, product: product, from_date: booked_date_from, to_date: booked_date_to) }

    describe '#validate' do
      it 'valid when not either exceed_perminent_stock or any dates are booked' do
        line_item = build(:line_item, quantity: 1, product: product, from_date: '2023-01-13'.to_date, to_date: '2023-01-15'.to_date)
        described_class.new.validate(line_item)

        expect(line_item.errors.size).to eq 0
      end

      it 'invalid when exceed_perminent_stock' do
        line_item = build(:line_item, quantity: 4, product: product, from_date: '2023-01-13'.to_date, to_date: '2023-01-15'.to_date)
        described_class.new.validate(line_item)

        expect(line_item.errors.size).to eq 1
        expect(line_item.errors.details).to eq ({ :quantity => [{ :error => :selected_quantity_not_available }] })
      end

      it 'does not check with booked date if perminent_stock already exceed' do
        line_item = build(:line_item, quantity: 4, product: product, from_date: '2023-01-12'.to_date, to_date: '2023-01-15'.to_date)
        described_class.new.validate(line_item)

        expect(line_item.errors.size).to eq 1
        expect(line_item.errors.details).to eq ({ :quantity => [{ :error => :selected_quantity_not_available }] })
      end

      it 'invalid when any dates already booked' do
        line_item = build(:line_item, quantity: 1, product: product, from_date: '2023-01-12'.to_date, to_date: '2023-01-15'.to_date)
        described_class.new.validate(line_item)

        expect(line_item.errors.size).to eq 1
        expect(line_item.errors.full_messages).to eq (["Quantity Selected item not available on 2023-01-12"])
      end
    end

    describe '#validate_perminent_stock' do
      it 'valid when quantity < permanent_stock' do
        line_item = build(:line_item, quantity: 2, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date)
        valid = described_class.new.validate_perminent_stock(line_item)

        expect(valid).to be true
        expect(line_item.errors.size).to eq 0
      end

      it 'valid when quantity = permanent_stock' do
        line_item = build(:line_item, quantity: 3, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date)
        valid = described_class.new.validate_perminent_stock(line_item)

        expect(valid).to be true
        expect(line_item.errors.size).to eq 0
      end

      it 'invalid when quantity > permanent_stock' do
        line_item = build(:line_item, quantity: 4, product: product, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date)
        valid = described_class.new.validate_perminent_stock(line_item)

        expect(valid).to be false

        expect(line_item.errors.size).to eq 1
        expect(line_item.errors.details).to eq ({ :quantity => [{ :error => :selected_quantity_not_available }] })
      end
    end

    describe '#validate_with_booked_dates' do
      it 'invalid when booking on serveral booked dates' do
        line_item = build(:line_item, quantity: 1, product: product, from_date: '2023-01-11'.to_date, to_date: '2023-01-14'.to_date)
        valid = described_class.new.validate_with_booked_dates(line_item)

        expect(valid).to be false
        expect(line_item.errors.full_messages).to eq (["Quantity Selected item not available on 2023-01-11", "Quantity Selected item not available on 2023-01-12"])
      end

      it 'invalid when booking on a booked date' do
        line_item = build(:line_item, quantity: 1, product: product, from_date: '2023-01-12'.to_date, to_date: '2023-01-14'.to_date)
        valid = described_class.new.validate_with_booked_dates(line_item)

        expect(valid).to be false
        expect(line_item.errors.full_messages).to eq (["Quantity Selected item not available on 2023-01-12"])
      end

      it 'valid when booking date not yet booked' do
        line_item = build(:line_item, quantity: 1, product: product, from_date: '2023-01-13'.to_date, to_date: '2023-01-14'.to_date)
        valid = described_class.new.validate_with_booked_dates(line_item)

        expect(valid).to be true
        expect(line_item.errors.size).to eq 0
      end
    end
  end
end