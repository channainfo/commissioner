require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PinCode, type: :model do
  describe 'validations' do
    it { is_expected.to validate_length_of(:code).is_at_most(6) }
    it { is_expected.to validate_presence_of :contact }
    it { is_expected.to validate_presence_of :type }
  end
  
  describe '#check?' do
    context 'when pin code is expired' do
      it 'return expired' do
        pin_code = create(:pin_code, expired_at: Date.today - 1.day)
        
        result = pin_code.check?(pin_code.code)
        expect(result).to eq 'expired'
      end
    end
    
    context 'when pin code reach max attempt' do
      it 'return reached_max_attempt' do
        pin_code = create(:pin_code, number_of_attempt: 3)
        
        result = pin_code.check?(pin_code.code)
        expect(result).to eq 'reached_max_attempt'
      end
    end
    
    context 'when pin code is not macth the code provided' do
      it 'return not_match' do
        pin_code = create(:pin_code, number_of_attempt: 1)
        
        result = pin_code.check?('TEST')
        expect(result).to eq 'not_match'
      end
    end
    
    context 'when pin code is macth with the code provided' do
      it 'return ok' do
        pin_code = create(:pin_code, number_of_attempt: 1)
        
        result = pin_code.check?(pin_code.code)
        expect(result).to eq 'ok'
      end
    end
  end
end
