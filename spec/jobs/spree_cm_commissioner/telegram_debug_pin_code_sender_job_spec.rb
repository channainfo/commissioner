require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramDebugPinCodeSenderJob do
  let(:pin_code) { create(:pin_code) }
  let(:tenant) { create(:cm_tenant) }
  let!(:vendor) { create(:active_vendor, name: 'Angkor Hotel', tenant_id: tenant.id) }

  describe '#perform' do
    it 'calls TelegramDebugPinCodeSender with correct pin_code and name' do
      expect(SpreeCmCommissioner::TelegramDebugPinCodeSender)
        .to receive(:call)
        .with(pin_code: SpreeCmCommissioner::PinCode.find(pin_code.id), name: vendor.name, error_message: nil)

      subject.perform({ pin_code_id: pin_code.id, tenant_id: tenant.id, error_message: nil })
    end
  end
end
