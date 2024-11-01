require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Ai::TextEnhancer do
  let(:type) { :suggest }
  let(:terms) { 'BookMe+ is where to go in term event ticketing' }

  subject { described_class.new(type: type, lang: :en, terms: terms )}

  describe '.call' do
    it 'return the enhanced text', :vcr do
      subject.call
      expect(subject.context.enhanced_text).to_not be_blank
    end
  end

  describe '#lang' do
    context 'when providing a supported language' do
      it 'return the language' do
        subject = described_class.new(type: type, lang: :es, terms: terms )
        lang = subject.send(:lang)

        expect(lang).to eq :es
      end
    end

    context 'when providing an unsupported lang' do
      it 'return the default language' do
        subject = described_class.new(type: type, lang: :fr, terms: terms )
        lang = subject.send(:lang)

        expect(lang).to eq :en
      end
    end

    context 'when lang is not provided' do
      it 'return the default language' do
        subject = described_class.new(type: type, terms: terms )
        lang = subject.send(:lang)

        expect(lang).to eq :en
      end
    end
  end

  describe '#max_token_count' do
    context 'when providing a max_token_count in range' do
      it 'return the language' do
        subject = described_class.new(type: type, lang: :es, terms: terms, max_token_count: 100 )
        max_token_count = subject.send(:max_token_count)

        expect(max_token_count).to eq 100
      end
    end

    context 'when providing max_token_count out of range' do
      it 'return the default max_token_count' do
        subject = described_class.new(type: type, lang: :fr, terms: terms, max_token_count: 250 )
        max_token_count = subject.send(:max_token_count)

        expect(max_token_count).to eq 150
      end
    end

    context 'when max_token_count is not provided' do
      it 'return the default language' do
        subject = described_class.new(type: type, terms: terms )
        max_token_count = subject.send(:max_token_count)

        expect(max_token_count).to eq 150
      end
    end
  end

end

