require 'spec_helper'

RSpec.describe Spree::Image, type: :model do
  let(:image) { create(:image) }

  describe "#asset_styles" do
    it "merges old styles with product_zoomed style" do
      expected_styles = Spree::Image.styles.merge({ product_zoomed: "1200x1200>" })

      expect(image.asset_styles).to eq(expected_styles)
    end
  end

  describe "#styles" do
    it "returns only the 1200x1200 variant" do
      expected_url = image.cdn_image_url(image.attachment.variant(resize_to_limit: [1200, 1200]))
      expect(image.styles).to eq([{ url: expected_url, width: '1200', height: '1200' }])
    end
  end
end
