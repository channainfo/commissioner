require 'spec_helper'

RSpec.describe Spree::V2::Tenant::CustomerNotificationSerializer, type: :serializer do
  describe '#serializable_hash' do
    let!(:customer_notification) { create(:customer_notification) }

    subject {
      described_class.new(customer_notification, include: [
        :feature_images,
      ]).serializable_hash
    }

    it 'returns exact notification attributes' do
      expect(subject[:data][:attributes].keys).to contain_exactly(
        :title,
        :payload,
        :body,
        :url,
        :started_at,
        :sent_at,
        :notification_type,
        :action_label,
      )
    end

    it 'returns exact notification associations' do
      expect(subject[:data][:relationships].keys).to contain_exactly(
        :feature_images
      )
    end
  end
end
