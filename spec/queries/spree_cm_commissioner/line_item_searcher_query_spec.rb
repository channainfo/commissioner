require 'spec_helper'

RSpec.describe SpreeCmCommissioner::LineItemSearcherQuery do
  let(:taxonomy) { create(:taxonomy, kind: :event) }

  let(:event) { create(:taxon, name: 'BunPhum', taxonomy: taxonomy) }

  let(:section_a) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section A') }
  let(:section_b) { create(:taxon, parent: event, taxonomy: taxonomy, name: 'Section B') }

  let(:product_a) { create(:product, product_type: :ecommerce, taxons: [section_a]) }
  let(:product_b) { create(:product, product_type: :ecommerce, taxons: [section_b]) }

  let(:guest_a) { create(:guest, first_name: 'Ean', last_name: 'Eii') }
  let(:guest_b) { create(:guest, first_name: 'Sao', last_name: 'San') }
  let(:guest_c) { create(:guest, first_name: 'Yea', last_name: 'Yin') }

  let(:complete_line_item_a) { create(:line_item, product: product_a, guests: [guest_a]) }
  let(:complete_line_item_b) { create(:line_item, product: product_b, guests: [guest_b]) }
  let(:uncomplete_line_item_a) { create(:line_item, product: product_b, guests: [guest_c]) }

  let!(:complete_order_a) { create(:order, line_items: [ complete_line_item_a ], completed_at: Time.now, phone_number: '0123456789') }
  let!(:complete_order_b) { create(:order, line_items: [ complete_line_item_b ], completed_at: Time.now, phone_number: '0875432123') }
  let!(:uncompleted_order_a) { create(:order, line_items: [ uncomplete_line_item_a ], completed_at: nil, phone_number: '0663929934') }

  subject do
    guest_a.reload
    guest_b.reload
    guest_c.reload

    described_class.new(params)
  end

  describe '#call' do
    context 'when :event_id is not present' do
      let(:params) { { event_id: nil } }

      it 'return none' do
        expect(subject.call).to eq Spree::LineItem.none
      end
    end

    context 'when :event_id present' do
      context 'when :qr_data is present & is order QR' do
        context 'when order is complete' do
          let(:params) { { event_id: event.id, qr_data: complete_order_a.qr_data } }

          it 'return all line items in order' do
            expect(subject.call).to match_array complete_order_a.line_items
          end
        end

        context 'when order is not yet complete' do
          let(:params) { { event_id: event.id, qr_data: uncompleted_order_a.qr_data } }

          it 'raise not found' do
            expect { subject.call }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'when :qr_data is present & is line item QR' do
        let(:params) { { event_id: event.id, qr_data: complete_line_item_a.qr_data } }

        it 'return all line items in order' do
          expect(subject.call).to match_array [complete_line_item_a]
        end
      end

      context 'when :qr_data is present & not order QR or line item QR (we considered guest QR)' do
        let(:params) { { event_id: event.id, qr_data: guest_a.qr_data} }

        it 'return line items of guest' do
          expect(subject.call).to match_array [guest_a.line_item]
        end
      end

      context 'when :term is present' do
        it 'search line items by its number, guest name, intel phone_number, email & order number' do
          search_by_guest_first_name = described_class.new({ event_id: event.id, term: guest_a.reload.first_name })
          search_by_guest_last_name = described_class.new({ event_id: event.id, term: guest_a.reload.last_name })
          search_by_guest_full_name = described_class.new({ event_id: event.id, term: guest_a.reload.full_name })
          search_by_order_number = described_class.new({ event_id: event.id, term: complete_order_a.reload.number })
          search_by_order_email = described_class.new({ event_id: event.id, term: complete_order_a.reload.email })
          search_by_order_phone = described_class.new({ event_id: event.id, term: complete_order_a.reload.phone_number })
          search_by_line_item_number = described_class.new({ event_id: event.id, term: complete_line_item_a.reload.number })

          expect(search_by_guest_first_name.call).to match_array [guest_a.line_item]
          expect(search_by_guest_last_name.call).to match_array [guest_a.line_item]
          expect(search_by_guest_full_name.call).to match_array [guest_a.line_item]
          expect(search_by_order_number.call).to match_array complete_order_a.line_items
          expect(search_by_order_email.call).to match_array complete_order_a.line_items
          expect(search_by_order_phone.call).to match_array complete_order_a.line_items
          expect(search_by_line_item_number.call).to match_array [complete_line_item_a]
        end
      end

      context 'when :qr_data and :term is not present' do
        let(:params) { { event_id: event.id } }

        it 'return all line items for the event' do
          expect(subject.call).to match_array [complete_line_item_a, complete_line_item_b]
        end
      end
    end
  end
end
