require 'spec_helper'

RSpec.describe SpreeCmCommissioner::PinCodeCreator do
  describe '#call' do
    context 'with valid attribute' do
      it 'return new pin code' do
        phone_parser = Phonelib.parse('087420441', 'kh')
        
        pin_code_attrs = {
          phone_number: phone_parser.national.gsub!(/[() -]/, ''),
          type: 'SpreeCmCommissioner::PinCodeLogin'
        }
        
        create_pin_code_context = SpreeCmCommissioner::PinCodeCreator.call(pin_code_attrs)
        
        expect(create_pin_code_context.success?).to eq true
        expect(create_pin_code_context.pin_code.present?).to eq true
        expect(create_pin_code_context.pin_code.contact).to eq phone_parser.international.gsub!(/[() -]/, '')
        expect(create_pin_code_context.pin_code.contact_type).to eq 'phone_number'
        expect(create_pin_code_context.pin_code.type).to eq 'SpreeCmCommissioner::PinCodeLogin'
      end
    end
    
    context 'with invalid attribute' do
      it 'return error' do
        pin_code_attrs = {
          email: '087420441',
          type: 'SpreeCmCommissioner::PinCodeLogin'
        }
        
        create_pin_code_context = SpreeCmCommissioner::PinCodeCreator.call(pin_code_attrs)
        
        expect(create_pin_code_context.success?).to eq false
        expect(create_pin_code_context.message).to eq 'Invalid email address'
      end
    end
  end
end
