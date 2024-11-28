require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GuestIdCardManager  do
  let(:id_card) { create(:id_card, card_type: 'passport') }

  let(:guest_with_id_card) { create(:guest , id_card: id_card ) }
  let(:guest) { create(:guest) }

  let(:card_type) { 'student_id_card' }
  let(:front_image_url) { "https://example/front_image.jpg" }
  let(:back_image_url)  { "https://example/front_image.jpg" }

  describe '.call' do
    context 'create_guest_id_card' do
      it 'return error if front_image_url is nil' do
       context = described_class.call(card_type: card_type, guest_id: guest.id)

       expect(context.success?).to eq false
       expect(context.message).to eq 'Image url can not be empty'
      end

      it 'return id_card record if create success' do
        context = described_class.call(
                                      card_type: card_type,
                                      guest_id: guest.id,
                                      front_image_url: front_image_url,
                                      back_image_url: front_image_url
                                    )
        allow(context).to receive(:manage_front_image).and_return(instance_double("context", success?: true))
        allow(context).to receive(:manage_back_image).and_return(instance_double("context", success?: true))

        expect(context.success?).to eq true
      end
    end

    context 'update_guest_id_card' do
      it 'update card type when present' do
        described_class.call(card_type: card_type , guest_id: guest_with_id_card.id)

        expect(id_card.reload.card_type).to eq(card_type)
      end

      it 'update front_image when present' do

        allow(SpreeCmCommissioner::IdCardImageUpdater).to receive(:call).with(
          id_card: id_card,
          image_url: front_image_url ,
          type: 'front_image'
        ).and_return(instance_double("context", success?: true))

        described_class.call(front_image_url: front_image_url, guest_id: guest_with_id_card.id)
      end

      it 'update back_image when present' do

        allow(SpreeCmCommissioner::IdCardImageUpdater).to receive(:call).with(
          id_card: id_card,
          image_url: back_image_url,
          type: 'back_image'
        ).and_return(instance_double("context", success?: true))

        described_class.call(back_image_url: back_image_url, guest_id: guest_with_id_card.id)
      end
    end
  end
end
