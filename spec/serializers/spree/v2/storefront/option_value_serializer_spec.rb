require 'spec_helper'

describe Spree::V2::Storefront::OptionValueSerializer, type: :serializer do
  before(:each) do
    ActionController::Base.asset_host = nil
  end

  context 'for display_icon' do
    it 'returns attributes with compiled icon' do
      option_value_with_icon = create(:option_value, icon: "/assets/cm-box.svg")

      subject = described_class.new(option_value_with_icon)

      expect(subject.serializable_hash[:data][:attributes][:display_icon].start_with?("/assets/cm-box")).to be true
      expect(subject.serializable_hash[:data][:attributes][:display_icon].end_with?(".svg")).to be true
    end
  
    it 'returns attribute with default compiled icon when icon nil' do
      option_value_no_icon = create(:option_value, icon: nil)

      subject = described_class.new(option_value_no_icon)

      expect(subject.serializable_hash[:data][:attributes][:display_icon].start_with?("/assets/cm-default-icon")).to be true
      expect(subject.serializable_hash[:data][:attributes][:display_icon].end_with?(".svg")).to be true
    end

    it 'returns exact icon url with asset_host' do
      ActionController::Base.asset_host = 'http://127.0.0.1'

      option_value_no_icon = create(:option_value, icon: nil)
      subject = described_class.new(option_value_no_icon)

      expect(subject.serializable_hash[:data][:attributes][:display_icon].start_with?("http://127.0.0.1/assets/cm-default-icon")).to be true
      expect(subject.serializable_hash[:data][:attributes][:display_icon].end_with?(".svg")).to be true
    end
  end
end
