require 'spec_helper'

class DummyClass
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :name

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end

RSpec.describe SpreeCmCommissioner::ParameterizeName do
  before(:each) do
    DummyClass.include(described_class)
  end

  context 'before validation callback' do
    describe '#convert_name_to_paramaterize' do
      it 'convert sentence name to parameterize on save' do
        dummy = DummyClass.new(name: 'Fake Name')
        dummy.validate

        expect(dummy.name).to eq 'fake-name'
      end

      it 'convert name with underscore to parameterize on save' do
        dummy = DummyClass.new(name: 'Fake_Name')
        dummy.validate

        expect(dummy.name).to eq 'fake_name'
      end

      it 'convert name with underscore to parameterize on save' do
        dummy = DummyClass.new(name: 'Fake_Name123')
        dummy.validate

        expect(dummy.name).to eq 'fake_name123'
      end

      it 'convert name with special character to parameterize on save' do
        dummy = DummyClass.new(name: 'Fake_Name***')
        dummy.validate

        expect(dummy.name).to eq 'fake_name'
      end

      it 'convert name with special character and number to parameterize on save' do
        dummy = DummyClass.new(name: 'Fake_Name***1234')
        dummy.validate

        expect(dummy.name).to eq 'fake_name-1234'
      end

      it 'convert name with only number to parameterize on save' do
        dummy = DummyClass.new(name: '12345')
        dummy.validate

        expect(dummy.name).to eq '12345'
      end
    end
  end
end