require 'spec_helper'

class DummyClass
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :presentation, :option_type_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end

RSpec.describe SpreeCmCommissioner::AttrTypeValidation do
  before(:each) do
    DummyClass.include(described_class)
    DummyClass.act_as_presentation
  end

  context 'when no option type' do
    it 'always valid when no option type' do
      dummy = DummyClass.new(presentation: 'Fake Name', option_type_id: 0)
      expect(dummy.valid?).to be true
    end

    it 'always valid when option_type_id nil' do
      dummy = DummyClass.new(presentation: 'Fake Name', option_type_id: nil)
      expect(dummy.valid?).to be true
    end
  end

  context 'for integer' do
    let(:option_type) { create(:option_type, attr_type: 'integer') }

    it 'invalid when input string' do
      dummy = DummyClass.new(presentation: 'Fake Name', option_type_id: option_type.id)
      expect(dummy.valid?).to be false
    end

    it 'invalid when input float' do
      dummy = DummyClass.new(presentation: '123.9', option_type_id: option_type.id)
      expect(dummy.valid?).to be false
    end

    it 'valid when input integer' do
      dummy0 = DummyClass.new(presentation: 123, option_type_id: option_type.id)
      dummy1 = DummyClass.new(presentation: '123', option_type_id: option_type.id)

      expect(dummy0.valid?).to be true
      expect(dummy1.valid?).to be true
    end
  end

  context 'for float' do
    let(:option_type) { create(:option_type, attr_type: 'float') }

    it 'invalid when input string' do
      dummy = DummyClass.new(presentation: 'Fake Name', option_type_id: option_type.id)
      expect(dummy.valid?).to be false
    end

    it 'valid when input float' do
      dummy0 = DummyClass.new(presentation: '123.0', option_type_id: option_type.id)
      dummy1 = DummyClass.new(presentation: 123.0, option_type_id: option_type.id)

      expect(dummy0.valid?).to be true
      expect(dummy1.valid?).to be true
    end

    it 'valid when input integer' do
      dummy0 = DummyClass.new(presentation: '123', option_type_id: option_type.id)
      dummy1 = DummyClass.new(presentation: 123, option_type_id: option_type.id)

      expect(dummy0.valid?).to be true
      expect(dummy1.valid?).to be true
    end
  end

  context 'for boolean, only accept "1", "0"' do
    let(:option_type) { create(:option_type, attr_type: 'boolean') }

    it 'invalid when input 1 or 0 in integer' do
      dummy0 = DummyClass.new(presentation: 0, option_type_id: option_type.id)
      dummy1 = DummyClass.new(presentation: 1, option_type_id: option_type.id)

      expect(dummy0.valid?).to be false
      expect(dummy1.valid?).to be false
    end

    it 'valid when input string 1 or 0' do
      dummy0 = DummyClass.new(presentation: "0", option_type_id: option_type.id)
      dummy1 = DummyClass.new(presentation: "1", option_type_id: option_type.id)

      expect(dummy0.valid?).to be true
      expect(dummy1.valid?).to be true
    end
  end

  context 'for started_at' do
    let(:option_type) { create(:option_type, attr_type: 'started_at') }

    it 'invalid when input is in wrong format' do
      dummy = DummyClass.new(presentation: 'Invalid Presentation', option_type_id: option_type.id)
      expect(dummy.valid?).to be false
      expect(dummy.errors[:presentation]).to eq ["Invalid format. Should be in '0d0h0m0s' format"]
    end

    it 'valid when input is in right format' do
      dummy = DummyClass.new(presentation: '3d2h0m0s', option_type_id: option_type.id)
      expect(dummy.valid?).to be true
    end
  end
end