require 'spec_helper'

RSpec.describe Spree::Icon, type: :model do
  subject { create(:icon) }

  describe '#url' do
    it 'return fully construct url' do
      expect(::Rails.application.routes.url_helpers).to receive(:cdn_image_url).with(subject.attachment).and_call_original
      expect(subject.url).to start_with('http://localhost:3000/rails/active_storage/blobs/proxy')
    end
  end
end
