require 'spec_helper'

RSpec.describe SpreeCmCommissioner::GuestCartTransfer, type: :interactor do
  let(:context) { Interactor::Context.new() }
  let(:interactor) { described_class.new(context) }

  describe '#validate_merge_type!' do
    subject(:validate_merge_type!) { interactor.send(:validate_merge_type!) }

    let(:merge_type) { 'replace' }
    let(:context) { Interactor::Context.new(merge_type: merge_type) }

    context 'when merge_type is valid' do
      it 'does not fail the context' do
        expect { validate_merge_type! }.not_to raise_error
        expect(context.message).to be_nil
      end
    end

    context 'when merge_type is invalid' do
      let(:merge_type) { 'invalid_merge_type' }

      it 'fails the context with an appropriate error message' do
        expect { validate_merge_type! }.to raise_error(Interactor::Failure)
        expect(context.message).to eq('Invalid merge type: invalid_merge_type')
      end
    end
  end

  describe "#validate_guest_presence!" do
    subject(:validate_guest_presence!) { interactor.send(:validate_guest_presence!) }

    context 'guest is nil' do
      it 'fails the context' do
        allow(interactor).to receive(:guest).and_return nil

        expect {validate_guest_presence!}.to raise_error(Interactor::Failure)
        expect(context.message).to eq('Guest is invalid!')
      end
    end

    context 'guest is present' do
      let(:guest) { create(:cm_guest_user) }

      it 'does not fail the context' do
        allow(interactor).to receive(:guest).and_return guest

        expect {validate_guest_presence!}.not_to raise_error
      end
    end
  end

  describe "#validate_guest_cart_presence!" do
    subject(:validate_guest_cart_presence!) { interactor.send(:validate_guest_cart_presence!) }

    context 'guest cart is nil' do
      it 'fails the context' do
        allow(interactor).to receive(:guest_cart).and_return nil

        expect {validate_guest_cart_presence!}.to raise_error(Interactor::Failure)
        expect(context.message).to eq('Guest has no cart to transfer!')
      end
    end

    context 'guest cart is present' do
      let(:cart) { create(:order) }

      it 'does not fail the context' do
        allow(interactor).to receive(:guest_cart).and_return cart

        expect {validate_guest_cart_presence!}.not_to raise_error
      end
    end
  end

  describe '#transfer_guest_cart_to_user' do
    subject(:transfer_guest_cart_to_user!) { interactor.send(:transfer_guest_cart_to_user!) }

    before do
      allow(interactor).to receive(:handle_replace_cart!)
      allow(interactor).to receive(:handle_merge_cart!)

      transfer_guest_cart_to_user!
    end

    context 'merge_type is replace' do
      let(:context) { Interactor::Context.new(merge_type: 'replace') }

      it 'calls handle_replace_cart!' do
        expect(interactor).to have_received(:handle_replace_cart!)
        expect(interactor).not_to have_received(:handle_merge_cart!)
      end
    end

    context 'merge_type is merge' do
      let(:context) { Interactor::Context.new(merge_type: 'merge') }

      it 'calls handle_merge_cart!' do
        expect(interactor).to have_received(:handle_merge_cart!)
        expect(interactor).not_to have_received(:handle_replace_cart!)
      end
    end
  end

  describe '#handle_replace_cart!' do
    subject(:handle_replace_cart!) { interactor.send(:handle_replace_cart!) }

    before do
      allow(interactor).to receive(:update_guest_cart_to_user!)
      allow(interactor).to receive(:delete_user_cart!)
    end

    it 'calls update_guest_cart_to_user! and delete_user_cart!' do
      handle_replace_cart!

      expect(interactor).to have_received(:update_guest_cart_to_user!)
      expect(interactor).to have_received(:delete_user_cart!)
    end
  end

  describe '#handle_merge_cart!' do
    subject(:handle_merge_cart!) { interactor.send(:handle_merge_cart!) }

    before do
      allow(interactor).to receive(:merge_cart!)
      allow(interactor).to receive(:update_guest_cart_to_user!)
    end

    context 'user_cart is present' do
      let(:cart) { create(:order) }

      it 'calls merge_cart' do
        allow(interactor).to receive(:user_cart).and_return(cart)
        handle_merge_cart!

        expect(interactor).to have_received(:merge_cart!)
        expect(interactor).not_to have_received(:update_guest_cart_to_user!)
      end
    end

    context 'user_cart is nil' do
      it 'calls update_guest_cart_to_user!' do
        allow(interactor).to receive(:user_cart).and_return(nil)

        handle_merge_cart!

        expect(interactor).to have_received(:update_guest_cart_to_user!)
        expect(interactor).not_to have_received(:merge_cart!)
      end
    end
  end

  describe '#transfer_cart_item!' do
    subject(:transfer_cart_item) { interactor.send(:transfer_cart_item, guest_item) }

    let(:guest_item) { create(:cm_line_item, quantity: 1) }
    let(:user_item) { create(:cm_line_item, product: guest_item.product, variant: guest_item.variant, quantity: 1) }
    let(:user_items) { user_item.order.line_items.index_by(&:variant_id) }

    before do
      allow(interactor).to receive(:user_items).and_return(user_items)
    end

    context 'guest_item is existing_item' do
      it 'merges the quantity' do
        transfer_cart_item

        expect(user_item.reload.quantity).to eq(2)
      end
    end

    context 'guest_item is not exist in user_item' do
      let(:product) { create(:cm_accommodation_product) }
      let(:user_item) { create(:cm_line_item, product: product, quantity: 1) }
      let(:user_cart) { user_item.order }

      it 'transfer the guest line_item to user' do
        allow(interactor).to receive(:user_cart).and_return(user_cart)
        transfer_cart_item

        expect(user_cart.reload.line_items.count).to eq(2)
      end
    end
  end

  describe '#find_guest_user' do
    subject(:find_guest_user) { interactor.send(:find_guest_user) }
    let(:user) { create(:cm_user) }

    context 'user is not a guest' do
      let(:context) { Interactor::Context.new(guest_id: user.id) }

      it 'returns nil' do
        expect(find_guest_user).to be_nil
      end
    end

    context 'user is not present' do
      let(:context) { Interactor::Context.new(guest_id: 'abc') }

      it 'returns nil' do
        expect(find_guest_user).to be_nil
      end
    end

    context 'User is a guest and invalid token' do
      let(:guest) { create(:cm_guest_user) }
      let(:context) { Interactor::Context.new(guest_id: guest.id, guest_token: 'abc') }

      it 'returns nil' do
        expect(find_guest_user).to be_nil
      end
    end

    context 'User is a guest and valid token' do
      let(:guest) { create(:cm_guest_user) }
      let(:guest_token) { SpreeCmCommissioner::UserJwtToken.encode({ user_id: guest.id }, guest.reload.secure_token) }
      let(:context) { Interactor::Context.new(guest_id: guest.id, guest_token: guest_token) }

      it 'returns the guest' do
        expect(find_guest_user).to eq(guest)
      end
    end
  end

  describe '#find_current_order' do
    let!(:user) { create(:cm_user) }
    subject(:find_current_order) { interactor.send(:find_current_order, user) }

    context 'user has cart' do
      let(:context) { Interactor::Context.new(store: store, currency: currency) }
      let(:store) { Spree::Store.default }
      let(:currency) { store.default_currency }
      let!(:cart) { create(:order_with_line_items, store: store, currency: currency, user: user) }

      it 'returns ' do
        expect(find_current_order).to eq(cart)
      end
    end
  end

  describe '.call' do
    let!(:store) { Spree::Store.default }
    let(:currency) { store.default_currency }
    let(:user) { create(:cm_user) }
    let!(:guest) { create(:cm_guest_user) }
    let(:guest_token) { SpreeCmCommissioner::UserJwtToken.encode({ user_id: guest.id }, guest.reload.secure_token) }
    let!(:guest_cart) { create(:order, store: store, user: guest, currency: currency) }
    let(:merge_type) { 'replace' }
    let(:params) do
      {
        store: store,
        currency: currency,
        user: user,
        guest_token: guest_token,
        guest_id: guest.id,
        merge_type: merge_type
      }
    end

    subject(:call_interactor) { described_class.call(params) }

    describe "success scenarios" do
      context "when the user has no existing cart" do
        it "transfers the guest cart to the user" do
          call_interactor

          expect(guest_cart.reload.user).to eq(user)
        end
      end

      context "when the user has an existing cart" do
        let(:merge_type) { 'merge' }
        let(:user_cart) { create(:order, store: store, user: user, currency: currency) }
        let!(:variant1) { create(:cm_base_variant) }
        let!(:variant2) { create(:cm_base_variant) }

        before do
          create(:line_item, order: user_cart, variant_id: variant1.id, quantity: 2)
          create(:line_item, order: guest_cart, variant_id: variant1.id, quantity: 3)
          create(:line_item, order: guest_cart, variant_id: variant2.id, quantity: 1)
        end

        it "merges the guest cart items into the user's cart" do
          call_interactor

          user_cart.reload
          expect(user_cart.line_items.count).to eq(2)
          expect(user_cart.line_items.find_by(variant_id: variant1.id).quantity).to eq(5)
          expect(user_cart.line_items.find_by(variant_id: variant2.id).quantity).to eq(1)
        end

        it "destroys the guest cart after merging" do
          call_interactor
          expect { guest_cart.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe "failure scenarios" do
      context "when merge_type is invalid" do
        let(:merge_type) { 'invalid' }

        it "fails the context with Invalid merge type" do
          context = call_interactor
          expect(context.success?).to be_falsey
          expect(context[:message]).to eq('Invalid merge type: invalid')
        end
      end

      context "when the guest is not found" do
        let(:guest_token) { 'invalid token'}

        it "fails the context with :guest_is_invalid message" do
          expect(subject).to be_failure
          expect(subject[:message]).to eq('Guest is invalid!')
        end
      end

      context "when the guest cart is not found" do
        before do
          guest_cart.destroy
        end

        it "fails the context with :guest_no_cart message" do
          expect(subject).to be_failure
          expect(subject[:message]).to eq('Guest has no cart to transfer!')
        end
      end
    end
  end
end
