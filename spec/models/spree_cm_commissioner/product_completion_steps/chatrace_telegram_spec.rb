require 'spec_helper'

RSpec.describe SpreeCmCommissioner::ProductCompletionSteps::ChatraceTelegram, type: :model do
  subject { described_class.new }

  describe '#action_url_for' do
    let(:line_item) { create(:line_item) }

    context 'when entry_point_link is present and line_item has guests' do
      before do
        subject.preferred_entry_point_link = 'https://t.me/ThePlatformKHBot?start=bookmeplus'

        guest = create(:guest, line_item: line_item)
        line_item.reload
      end

      it 'return url of the first guest' do
        expected_url = "#{subject.preferred_entry_point_link}--#{line_item.guests.first.token}"
        expect(subject.action_url_for(line_item)).to eq(expected_url)
      end
    end

    context 'when entry_point_link is blank' do
      before { subject.preferred_entry_point_link = nil }

      it 'returns nil' do
        expect(subject.action_url_for(line_item)).to be_nil
      end
    end

    context 'when line_item does not have guests' do
      it 'returns nil' do
        expect(subject.action_url_for(line_item)).to be_nil
      end
    end
  end

  describe '#completed?' do
    let(:line_item) { create(:line_item) }

    context 'when entry_point_link is present and line_item has guests' do
      before do
        subject.preferred_entry_point_link = 'https://t.me/ThePlatformKHBot?start=bookmeplus'

        guest = create(:guest, preferred_telegram_user_id: '12345', line_item: line_item)
        line_item.reload
      end

      it 'returns completed true if preferred_telegram_user_id is present' do
        expect(subject.completed?(line_item)).to be_truthy
      end

      it 'returns false if preferred_telegram_user_id is absent' do
        line_item.guests.first.update(preferred_telegram_user_id: nil)

        expect(subject.completed?(line_item)).to be_falsy
      end
    end

    context 'when entry_point_link is blank' do
      before { subject.preferred_entry_point_link = nil }

      it 'returns false' do
        expect(subject.completed?(line_item)).to be_falsy
      end
    end

    context 'when line_item does not have guests' do
      it 'returns false' do
        expect(subject.completed?(line_item)).to be_falsy
      end
    end
  end
end
