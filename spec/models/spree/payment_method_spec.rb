require 'spec_helper'

RSpec.describe Spree::PaymentMethod, type: :model do
  describe '.available_on_frontend_for_early_adopter' do
    let(:payment_method_both) { create(:payment_method, display_on: :both) }
    let(:payment_method_frontend) { create(:payment_method, display_on: :front_end) }
    let(:payment_method_frontend_for_early_adopter) { create(:payment_method, display_on: :frontend_for_early_adopter) }
    let(:payment_method_backend) { create(:payment_method, display_on: :backend) }

    it 'should not return when display on :backend' do
      payment_method_backend

      methods = described_class.available_on_frontend_for_early_adopter
      expect(methods.size).to eq 0
    end

    it 'should return when display on :frontend_for_early_adopter' do
      payment_method_frontend_for_early_adopter

      methods = described_class.available_on_frontend_for_early_adopter
      expect(methods.size).to eq 1
      expect(methods[0]).to eq payment_method_frontend_for_early_adopter
    end

    it 'should return when display on :both' do
      payment_method_both

      methods = described_class.available_on_frontend_for_early_adopter
      expect(methods.size).to eq 1
      expect(methods[0]).to eq payment_method_both
    end

    it 'should return when display on :frontend' do
      payment_method_frontend

      methods = described_class.available_on_frontend_for_early_adopter
      expect(methods.size).to eq 1
      expect(methods[0]).to eq payment_method_frontend
    end
  end
end
