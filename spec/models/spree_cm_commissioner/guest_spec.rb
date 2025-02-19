require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Guest, type: :model do
  let(:taxon) { create(:taxon, name: 'University Student') }
  let(:nationality) { create(:taxon, name: 'Khmer') }
  let(:line_item) { create(:line_item) }
  let(:id_card) { create(:id_card) }

  subject { line_item.guests.new }

  describe 'before validation' do
    describe '#assign_seat_number' do
      context 'when guest does not have bib_number' do
        it 'assign seat number = nil' do
          guest = create(:guest, bib_number: nil)
          expect(guest.seat_number).to eq nil
        end
      end

      context 'when assigning seat numbers' do
        let(:option_type) { create(:cm_option_type, :seat_number_positions) }
        let(:option_value) { create(:option_value, name: 'P39,P41,P43,P45,P47', option_type: option_type) }
        let(:product) { create(:product, option_types: [option_type]) }
        let(:variant) { create(:variant, product: product, option_values: [option_value]) }
        let(:line_item1) { create(:line_item, variant: variant, quantity: 1) }
        let(:line_item2) { create(:line_item, variant: variant, quantity: 1) }
        let(:event_id) { 111 }

        before do
          create(:guest, line_item: line_item1, seat_number: 'P01', event_id: event_id)
        end

        it 'does not allow duplicate seat numbers within the same event' do
          guest2 = build(:guest, line_item: line_item2, seat_number: 'P01', event_id: event_id)

          expect(guest2).not_to be_valid
          expect(guest2.errors[:seat_number]).to include('has already been taken')
        end
      end

      context 'when guest variant does not have :seat_number_positions option value' do
        let(:variant) { create(:variant) }
        let(:line_item) { create(:line_item, variant: variant, quantity: 2) }

        it 'assign seat number = nil' do
          guest = create(:guest, bib_number: 'VIP')
          expect(guest.seat_number).to eq nil
        end
      end

      context 'when guest has bib_number & :seat_number_positions option type' do
        let(:option_type) { create(:cm_option_type, :seat_number_positions) }
        let(:option_value) { create(:option_value, name: 'P39,P41,P43,P45,P47', option_type: option_type)}
        let(:product) { create(:product, option_types: [option_type]) }
        let(:variant) { create(:variant, option_values: [option_value]) }
        let(:line_item) { create(:line_item, variant: variant, quantity: 2) }

        context 'when bib invalid (exceed positions range or negative value)' do
          it 'assign seat number = nil if bib_number negative value' do
            invalid_guest_1 = create(:guest, bib_number: -1, line_item: line_item)

            expect(invalid_guest_1.seat_number).to eq nil
          end

          it 'assign seat number = nil if bib_number positions value' do
            invalid_guest_2 = create(:guest, bib_number: 6, line_item: line_item)

            expect(invalid_guest_2.seat_number).to eq nil
          end
        end

        context 'when bib valid' do
          it 'assign seat number base on bib number & seat_number_positions' do
            guest5 = create(:guest, bib_number: 5, line_item: line_item)
            guest2 = create(:guest, bib_number: 2, line_item: line_item)
            guest1 = create(:guest, bib_number: 1, line_item: line_item)
            guest3 = create(:guest, bib_number: 3, line_item: line_item)
            guest4 = create(:guest, bib_number: 4, line_item: line_item)

            expect(guest1.seat_number).to eq 'P39'
            expect(guest2.seat_number).to eq 'P41'
            expect(guest3.seat_number).to eq 'P43'
            expect(guest4.seat_number).to eq 'P45'
            expect(guest5.seat_number).to eq 'P47'
          end
        end

        context 'when seat number already assigned' do
          it 'does not reassign seat number' do
            guest1 = create(:guest, bib_number: 1, line_item: line_item)
            expect(guest1.seat_number).to eq 'P39'

            guest1.update(bib_number: 2)
            expect(guest1.seat_number).to eq 'P39'
          end
        end
      end
    end
  end

  describe 'before create' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }

    describe '#generate_bib' do
      context 'when variant does not set bib-pre-generation-on-create option value' do
        let(:product_with_bib) { create(:cm_bib_number_product, taxons: [section_a]) }
        let(:variant) { product_with_bib.variants.first }
        let(:line_item) { create(:line_item, variant: variant) }

        it 'does not generate bib' do
          guest = create(:guest, line_item: line_item)

          expect(variant.bib_pre_generation_on_create?).to be false
          expect(guest.formatted_bib_number).to be nil
        end
      end

      context 'when variant set "bib-pre-generation-on-create" to true' do
        let(:product_with_bib) { create(:cm_bib_number_product, bib_pre_generation_on_create: true, taxons: [section_a]) }
        let(:variant) { product_with_bib.variants.first }
        let(:line_item) { create(:line_item, variant: variant) }

        it 'generate bib on create (no need to wait until order complete)' do
          guest = create(:guest, line_item: line_item)

          expect(variant.bib_pre_generation_on_create?).to be true
          expect(guest.formatted_bib_number).to eq '3KM001'
        end
      end
    end
  end

  describe '.complete' do
    let(:order1) { create(:order, completed_at: Date.current) }
    let(:order2) { create(:order, completed_at: nil) }

    let(:line_item1) { create(:line_item, order: order1) }
    let(:line_item2) { create(:line_item, order: order2) }

    let!(:guest1) { create(:guest, line_item: line_item1, seat_number: 1) }
    let!(:guest2) { create(:guest, line_item: line_item2, seat_number: 2) }

    it 'return guests that has complete line item' do
      expect(described_class.complete.to_a).to eq [guest1]
    end
  end

  describe '.unassigned_event' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:section) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
    let(:product) { create(:product, product_type: :ecommerce, taxons: [section]) }
    let(:line_item) { create(:line_item, product: product) }

    let!(:guest_with_event_id) { create(:guest, line_item: line_item) }
    let!(:guest_with_no_event_id) { create(:guest) }

    it 'return guests that has no assigned event_id' do
      expect(guest_with_event_id.event_id).to eq event.id
      expect(guest_with_no_event_id.event_id).to eq nil

      expect(described_class.unassigned_event.to_a).to eq [guest_with_no_event_id]
    end
  end

  describe '#allowed_checkout?' do
    context 'when guest_name kyc enabled' do
      it 'return false when first name is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = nil
        subject.last_name = 'Doe'

        expect(subject.allowed_checkout?).to be false
      end

      it 'return false when last name is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = 'Jan'
        subject.last_name = nil

        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when both first name & last name is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_name])

        subject.first_name = 'Jan'
        subject.last_name = 'Doe'

        expect(subject.guest_name?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when guest_gender kyc enabled' do
      it 'return false when gender is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_gender])

        subject.gender = nil

        expect(subject.guest_gender?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when gender is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_gender])

        subject.gender = :male

        expect(subject.guest_gender?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when date of birth kyc enabled' do
      it 'return false when gender is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_dob])

        subject.dob = nil

        expect(subject.guest_dob?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when gender is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_dob])

        subject.dob = Date.current

        expect(subject.guest_dob?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when occupation kyc enabled' do
      it 'return false when occupation is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_occupation])

        subject.occupation = nil

        expect(subject.guest_occupation?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when occupation is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_occupation])

        subject.occupation = taxon

        expect(subject.guest_occupation?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when id card kyc enabled' do
      it 'return false when id_card is nil' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])

        subject.id_card = nil

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return false when id_card is invalid' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])
        allow(id_card).to receive(:allowed_checkout?).and_return(false)

        subject.id_card = id_card

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when id_card is allowed to checkout' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_id_card])
        allow(id_card).to receive(:allowed_checkout?).and_return(true)

        subject.id_card = id_card

        expect(subject.guest_id_card?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end

    context 'when nationality kyc enabled' do
      it 'return false when nationality is not provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_nationality])

        subject.nationality = nil

        expect(subject.guest_nationality?).to be true
        expect(subject.allowed_checkout?).to be false
      end

      it 'return true when nationality is provided' do
        allow(line_item).to receive(:kyc).and_return(SpreeCmCommissioner::KycBitwise::BIT_FIELDS[:guest_nationality])

        subject.nationality = nationality

        expect(subject.guest_nationality?).to be true
        expect(subject.allowed_checkout?).to be true
      end
    end
  end

  describe ".none_bib" do
    let(:order) { create(:order, completed_at: Date.current) }
    let(:line_item) { create(:line_item, order: order) }
    let(:guest1) { create(:guest, line_item: line_item, seat_number: 1) }
    let(:guest2) { create(:guest, line_item: line_item, bib_prefix: '20KM', seat_number: 2) }
    let(:guest3) { create(:guest, line_item: line_item, seat_number: 3) }

    let(:guests) { SpreeCmCommissioner::Guest.where(id: [guest1.id, guest2.id, guest3.id]) }

    it 'return guests that has no bib_prefix' do
      expect(guests.none_bib.to_a).to eq [guest1, guest3]
    end
  end

  describe '#generate_bib' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event1) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }
    let(:event2) { create(:taxon, name: 'BunPhum 2', taxonomy: taxonomy) }

    let(:product_without_bib) { create(:cm_product, product_type: :ecommerce, taxons: [event1]) }
    let(:product_with_bib1) { create(:cm_bib_number_product, product_type: :ecommerce, taxons: [event1]) }
    let(:product_with_bib2) { create(:cm_bib_number_product, product_type: :ecommerce, taxons: [event2]) }

    let(:order) { create(:order, completed_at: Date.current) }

    context "when guest has no prefix" do
      let(:line_item) { create(:line_item, order: order) }
      let(:guest) { create(:guest, line_item: line_item) }

      it 'generate bib_number for guest' do
        expect(guest.bib_number).to eq nil
        expect(guest.bib_prefix).to eq nil
      end
    end


    context "when guest in the same event" do
      context "when guest has the same prefix" do
        let(:line_item) { create(:line_item, order: order, variant: product_with_bib1.variants.first) }
        let(:guest1) { create(:guest, line_item: line_item, seat_number: 1) }
        let(:guest2) { create(:guest, line_item: line_item, seat_number: 2) }

        it 'generate bib_number for guest' do
          guest1.generate_bib!
          guest2.generate_bib!

          expect(guest1.bib_number).to eq 1
          expect(guest2.bib_number).to eq 2
          expect(guest1.formatted_bib_number).to eq '3KM001'
          expect(guest2.formatted_bib_number).to eq '3KM002'
        end
      end

      context "when guest has different prefix" do
        let(:line_item1) { create(:line_item, order: order, variant: product_with_bib1.variants.first) }
        let(:line_item2) { create(:line_item, order: order, variant: product_with_bib1.variants.last) }

        let(:guest1) { create(:guest, line_item: line_item1, seat_number: 1) }
        let(:guest2) { create(:guest, line_item: line_item2, seat_number: 2) }

        it 'generate bib_number for guest' do
          guest1.generate_bib!
          guest2.generate_bib!

          expect(guest1.bib_number).to eq 1
          expect(guest2.bib_number).to eq 1
          expect(guest1.formatted_bib_number).to eq '3KM001'
          expect(guest2.formatted_bib_number).to eq '5KM001'
        end
      end
    end
  end

  describe '#formatted_bib_number' do
    let(:taxonomy) { create(:taxonomy, kind: :event) }
    let(:event) { create(:taxon, name: 'Sai', taxonomy: taxonomy) }
    let(:product_with_bib) { create(:cm_bib_number_product, product_type: :ecommerce, taxons: [event]) }
    let(:variant) { product_with_bib.variants.first }

    let(:order) { create(:order, completed_at: Date.current) }
    let(:line_item) { create(:line_item, order: order, variant: variant) }
    let(:guest) { create(:guest, line_item: line_item) }

    let(:not_display_bib_prefix) { create(:cm_option_value, name: '0', option_type: create(:cm_option_type, :bib_display_prefix)) }
    let(:display_bib_prefix) { create(:cm_option_value, name: '1', option_type: create(:cm_option_type, :bib_display_prefix)) }

    it 'return bib number without prefix when bib_display_prefix is 0' do
      guest.generate_bib!

      variant.update(option_values: [not_display_bib_prefix])

      expect(guest.formatted_bib_number).to eq "001"
    end

    it 'return bib number with prefix when bib_display_prefix is 1' do
      guest.generate_bib!

      variant.update(option_values: [display_bib_prefix])

      expect(guest.formatted_bib_number).to eq "3KM001"
    end
  end

  describe '#checked_in scope' do
    let(:taxon) { create(:taxon) }

    let!(:guest1) { create(:guest, event_id: taxon.id) }
    let!(:guest2) { create(:guest, event_id: taxon.id) }
    let!(:guest3) { create(:guest, event_id: taxon.id) }
    let!(:guest4) { create(:guest, event_id: taxon.id) }

    let!(:check_in1) { create(:cm_check_in, guest_id: guest1.id) }
    let!(:check_in2) { create(:cm_check_in, guest_id: guest2.id) }

    it 'returns the right count of checked-in guests' do
      expect(taxon.guests.checked_ins.count).to eq(2)
    end
  end

  describe '#not_show scope' do
    let(:taxon) { create(:taxon) }

    let!(:guest1) { create(:guest, event_id: taxon.id) }
    let!(:guest2) { create(:guest, event_id: taxon.id) }
    let!(:guest3) { create(:guest, event_id: taxon.id) }
    let!(:guest4) { create(:guest, event_id: taxon.id) }

    let!(:check_in1) { create(:cm_check_in, guest_id: guest1.id) }

    it 'returns the right count of no show guests' do
      expect(taxon.guests.no_show.count).to eq(3)
    end
  end
end
