require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemDurationable do
  describe '#date_range' do
    let(:accommodation_line_item) { build(:line_item, product_type: :accommodation, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:transit_line_item) { build(:line_item, product_type: :transit, from_date: '2023-01-10'.to_date, to_date: '2023-01-10'.to_date) }
    let(:event_line_item) { build(:line_item, product_type: :ecommerce, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:no_date_line_item) { build(:line_item, product_type: :ecommerce) }

    it 'return date range base on from_date to to_date' do
      # for accomodation, from_date to to_date is stay date (no checkout date here.)
      expect(accommodation_line_item.date_range).to eq(['2023-01-10'.to_date, '2023-01-11'.to_date, '2023-01-12'.to_date])
      expect(transit_line_item.date_range).to eq(['2023-01-10'.to_date])
      expect(event_line_item.date_range).to eq(['2023-01-10'.to_date, '2023-01-11'.to_date, '2023-01-12'.to_date])
      expect(no_date_line_item.date_range).to eq([])
    end
  end

  describe '#date_unit' do
    let(:accommodation_line_item) { build(:line_item, product_type: :accommodation, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:transit_line_item) { build(:line_item, product_type: :transit, from_date: '2023-01-10'.to_date, to_date: '2023-01-10'.to_date) }
    let(:service_line_item) { build(:line_item, product_type: :service, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:event_line_item) { build(:line_item, product_type: :ecommerce, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:no_date_line_item) { build(:line_item, product_type: :ecommerce) }

    it 'return 3 days / unit for permanent stock & nil for other type' do
      expect(accommodation_line_item.date_unit).to eq 3
      expect(transit_line_item.date_unit).to eq 1
      expect(service_line_item.date_unit).to eq 3
      expect(event_line_item.date_unit).to eq nil
      expect(no_date_line_item.date_unit).to eq nil
    end
  end

  describe '#checkin_date' do
    let(:accommodation_line_item) { build(:line_item, product_type: :accommodation, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:transit_line_item) { build(:line_item, product_type: :transit, from_date: '2023-01-10'.to_date, to_date: '2023-01-10'.to_date) }
    let(:service_line_item) { build(:line_item, product_type: :service, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:event_line_item) { build(:line_item, product_type: :ecommerce, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:no_date_line_item) { build(:line_item, product_type: :ecommerce) }

    it 'just return from_date or nil if not provided' do
      expect(accommodation_line_item.checkin_date).to eq '2023-01-10'.to_date
      expect(transit_line_item.checkin_date).to eq '2023-01-10'.to_date
      expect(service_line_item.checkin_date).to eq '2023-01-10'.to_date
      expect(event_line_item.checkin_date).to eq '2023-01-10'.to_date
      expect(no_date_line_item.checkin_date).to eq nil
    end
  end

  describe '#checkout_date' do
    let(:accommodation_line_item) { build(:line_item, product_type: :accommodation, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:transit_line_item) { build(:line_item, product_type: :transit, from_date: '2023-01-10'.to_date, to_date: '2023-01-10'.to_date) }
    let(:service_line_item) { build(:line_item, product_type: :service, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:event_line_item) { build(:line_item, product_type: :ecommerce, from_date: '2023-01-10'.to_date, to_date: '2023-01-12'.to_date) }
    let(:no_date_line_item) { build(:line_item, product_type: :ecommerce) }

    it 'return to_date exclude checkout for accommodation, while just return to_date for other product_type' do
      expect(accommodation_line_item.checkout_date).to eq '2023-01-11'.to_date # exclude checkout date
      expect(transit_line_item.checkout_date).to eq '2023-01-10'.to_date
      expect(service_line_item.checkout_date).to eq '2023-01-12'.to_date
      expect(event_line_item.checkout_date).to eq '2023-01-12'.to_date
      expect(no_date_line_item.checkout_date).to eq nil
    end
  end
end