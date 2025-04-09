require 'spec_helper'

RSpec.describe Spree::Role, type: :model do
  describe '#generate_unique_name' do
    let(:vendor) { create(:vendor) }
    let(:role) { build(:role, vendor: vendor, presentation: 'Test Role', name: nil) }

    context 'when name is already present' do
      before { role.name = 'existing-name' }

      it 'does not change the name' do
        expect { role.send(:generate_unique_name) }.not_to change { role.name }
      end
    end

    context 'when presentation is blank' do
      before { role.presentation = '' }

      it 'does not set the name' do
        expect { role.send(:generate_unique_name) }.not_to change { role.name }
      end
    end

    context 'when conditions are met' do
      it 'generates a name based on vendor slug and presentation' do
        allow(vendor).to receive(:slug).and_return('test-vendor')
        role.send(:generate_unique_name)
        expect(role.name).to eq('test-vendor-test-role')
      end

      it 'handles special characters in presentation' do
        allow(vendor).to receive(:slug).and_return('test-vendor')
        role.presentation = 'Test & Role!'
        role.send(:generate_unique_name)
        expect(role.name).to eq('test-vendor-test-role')
      end
    end
  end

  describe 'callbacks' do
    let(:vendor) { create(:vendor) }
    let(:role) { build(:role, vendor: vendor, presentation: 'Test Role', name: nil) }

    it 'calls generate_unique_name before validation when vendor is present' do
      expect(role).to receive(:generate_unique_name)
      role.valid?
    end

    it 'does not call generate_unique_name when vendor is not present' do
      role.vendor = nil
      expect(role).not_to receive(:generate_unique_name)
      role.valid?
    end
  end
end
