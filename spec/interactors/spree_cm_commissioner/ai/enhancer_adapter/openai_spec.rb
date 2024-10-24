require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Ai::EnhancerAdapter::Openai do
  let(:openai) do
    Class.new do
      include SpreeCmCommissioner::Ai::EnhancerAdapter::Openai
      attr_accessor :terms, :lang, :type, :max_token_count
    end.new

  end

  before(:each) do
    openai.terms = 'BookMe+ is where to go in term event ticketing'
    openai.lang = :en
    openai.type = :suggest
    openai.max_token_count = 150
  end

  describe '#enhence_text', :vcr do
    it 'enhance the text' do
      result = openai.enhance_text
      expect(result).to_not be_blank
    end
  end

  describe '#token_count' do
    it 'return the length of the token' do
      result = openai.token_count
      expect(result).to eq 12
    end
  end

  describe '#prompt' do
    context 'when the type is :suggest' do
      it 'return the prompt command for openai' do
        result = openai.prompt

        expected_result = 'suggest: BookMe+ is where to go in term event ticketing'
        expect(result).to eq expected_result
      end
    end

    context 'when the type is :rewrite' do
      it 'return the prompt command for openai' do
        openai.type = :rewrite

        result = openai.prompt

        expected_result = 'rewrite: BookMe+ is where to go in term event ticketing'
        expect(result).to eq expected_result
      end
    end

    context 'when the type is :summarise' do
      it 'return the prompt command for openai' do
        openai.type = :summarise

        result = openai.prompt

        expected_result = 'summarise: BookMe+ is where to go in term event ticketing'
        expect(result).to eq expected_result
      end
    end
  end

end