require 'spec_helper'

RSpec.describe SpreeCmCommissioner::TelegramDebugPinCodeSenderJob do
  let(:pin_code) { create(:pin_code) }

  describe '#perform' do
    it 'calls TelegramDebugPinCodeSender with correct pin_code' do
      expect(SpreeCmCommissioner::TelegramDebugPinCodeSender)
        .to receive(:call)
        .with(pin_code: SpreeCmCommissioner::PinCode.find(pin_code.id))

      subject.perform(pin_code.id)
    end
  end
end
