require 'spec_helper'

RSpec.describe SpreeCmCommissioner::BibNumberSwapper do
  let!(:guest1) { create(:guest, bib_number: 1) }
  let!(:guest2) { create(:guest, bib_number: 2) }

  let(:guests) { SpreeCmCommissioner::Guest.where(id: [guest1.id, guest2.id]) }

  describe '#call' do
    subject(:context) do
      described_class.call(
        guests: guests,
        current_guest: guest1,
        target_guest: guest2
      )
    end

    it 'swaps the bib numbers between guests' do
      expect { context }.to change { guest1.reload.bib_number }.from(1).to(2)
        .and change { guest2.reload.bib_number }.from(2).to(1)
    end

    it 'does not raise an error' do
      expect { context }.not_to raise_error
    end
  end
end
