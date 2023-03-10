require 'spec_helper'

RSpec.describe Spree::Adjustment, type: :model do
  describe 'validations' do
    context 'presence_of :order' do
      let(:source) { create(:tax_rate, calculator: create(:calculator)) }
      let(:listing_price) { create(:cm_listing_price) }
      let(:line_item) { create(:line_item) }

      it 'not required order when adjustable is ListingPrice' do
        adjustment = build(:adjustment, order: nil, adjustable: listing_price, source: source)

        expect { adjustment.save! }.not_to raise_error
      end

      it 'required order when adjustable is not ListingPrice' do
        adjustment = build(:adjustment, order: nil, adjustable: line_item, source: source)

        expect { adjustment.save! }
          .to raise_error(ActiveRecord::RecordInvalid)
          .with_message("Validation failed: Order can't be blank")
      end
    end
  end
end