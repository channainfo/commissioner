require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductCompletionStep, type: :model do
  it { is_expected.to belong_to(:product).class_name('Spree::Product') }

  describe '#action_url_for' do
    it 'returns nil' do
      expect(subject.action_url_for(nil)).to be_nil
    end
  end

  describe '#completed?' do
    it 'raises an error' do
      expect { subject.completed?(nil) }
        .to raise_error(RuntimeError)
        .with_message("completed? should be implemented in a sub-class of ProductCompletionStep")
    end
  end

  describe '#construct_hash' do
    subject { described_class.new(title: 'title', description: 'description', action_label: 'link-now')}
    let(:line_item) { create(:line_item) }

    it 'constructs the hash correctly' do
      allow(subject).to receive(:action_url_for).and_return('https://example.com')
      allow(subject).to receive(:completed?).and_return(true)

      expect(subject.construct_hash(line_item: line_item)).to eq({
        title: 'title',
        type: nil,
        position: 0,
        description: 'description',
        action_label: 'link-now',
        action_url: 'https://example.com',
        completed: true
      })
    end
  end
end
