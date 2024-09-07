require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
  describe '.whitelisted_ransackable_associations' do
    it 'return expected associations' do
      expect(described_class.whitelisted_ransackable_associations).to match_array([
        "shipments", "user", "created_by", "approver", "canceler", "promotions", "bill_address", "ship_address",
        "line_items", "store", "customer", "taxon", "payments", "invoice"
      ])
    end
  end


  describe '.whitelisted_ransackable_attributes' do
    it 'return expected attributes' do
      expect(described_class.whitelisted_ransackable_attributes).to match_array([
        "completed_at", "email", "number", "state", "payment_state", "shipment_state", "total", "item_total",
        "considered_risky", "channel", "intel_phone_number", "phone_number"
      ])
    end
  end

  describe 'validations' do
    context 'state is either cart or address' do
      it 'not required present of email or phone number' do
        order = create(:order, state: 'cart')

        order.email = nil
        order.phone_number = nil

        expect(order.save).to eq true
      end
    end

    context 'state is not either cart or address' do
      it 'validates present of either email or phone number' do
        order = create(:order, state: 'payment')

        order.email = nil
        order.phone_number = nil

        expect { order.save! }
          .to raise_error(ActiveRecord::RecordInvalid)
          .with_message("Validation failed: Email can't be blank, Phone number can't be blank")
      end

      it 'not required phone number when email present' do
        order = create(:order, state: 'payment')

        order.email = 'test@gmail.com'
        order.phone_number = nil

        expect(order.save).to eq true
      end

      it 'not required email when phone number present' do
        order = create(:order, state: 'payment')

        order.email = nil
        order.phone_number = '+855 12345678'

        expect(order.save).to eq true
      end
    end

    describe '#promo_total' do
      it { should validate_presence_of(:promo_total) }

      it do
        should validate_numericality_of(:promo_total)
          .is_greater_than(-described_class::MONEY_THRESHOLD)
          .is_less_than(described_class::MONEY_THRESHOLD)
          .allow_nil
      end

      # for pricing model
      it 'save promo total even if it is positive number' do
        order = build(:order, promo_total: 1)

        expect(order.save).to be true
        expect(order.promo_total).to eq 1
      end

      # for promotion
      it 'save promo total even if it is negative number' do
        order = build(:order, promo_total: -1)

        expect(order.save).to be true
        expect(order.promo_total).to eq(-1)
      end
    end
  end

  describe 'paid' do
    let!(:order1) { create(:order, payment_state: :paid) }
    let!(:order2) { create(:order, payment_state: :void) }

    it 'it only return paid order' do
      expect(described_class.paid.size).to eq 1
      expect(described_class.paid.first).to eq order1
    end
  end

  describe '#collect_payment_methods' do
    context 'when user is nil' do
      let(:order) { create(:order, user: nil) }

      it 'should call super method & collect_payment_methods_for_early_adopter' do
        order.collect_payment_methods

        expect(order.user).to eq nil
        expect(order).to_not receive(:collect_payment_methods_for_early_adopter)
      end
    end

    context 'when user is not early adaopter' do
      let(:user) { create(:user) }
      let(:order) { create(:order, user: user) }

      it 'should call super method & not not call collect_payment_methods_for_early_adopter' do
        order.collect_payment_methods

        expect(order.user).to eq user
        expect(order.user.early_adopter?).to be false
        expect(order).to_not receive(:collect_payment_methods_for_early_adopter)
      end
    end

    context 'when user is early adaopter' do
      let(:user) { create(:cm_early_adopter_user) }
      let(:order) { create(:order, user: user) }

      it 'call collect_payment_methods_for_early_adopter' do
        allow(order).to receive(:collect_payment_methods_for_early_adopter).with(nil).and_return([])

        order.collect_payment_methods

        expect(order.user).to eq user
        expect(order.user.early_adopter?).to be true
        expect(order).to have_received(:collect_payment_methods_for_early_adopter)
      end
    end
  end

  describe '#collect_payment_methods_for_early_adopter' do
    let!(:payment_method_both) { create(:payment_method, display_on: :both) }
    let!(:payment_method_frontend) { create(:payment_method, display_on: :front_end) }
    let!(:payment_method_frontend_for_early_adopter) { create(:payment_method, display_on: :frontend_for_early_adopter) }
    let!(:payment_method_backend) { create(:payment_method, display_on: :backend) }

    let(:order) { create(:order) }

    it 'should return methods that available for early adopter' do
      expect(order.collect_payment_methods_for_early_adopter.size).to eq 3
      expect(order.collect_payment_methods_for_early_adopter[0]).to eq payment_method_both
      expect(order.collect_payment_methods_for_early_adopter[1]).to eq payment_method_frontend
      expect(order.collect_payment_methods_for_early_adopter[2]).to eq payment_method_frontend_for_early_adopter
    end
  end

  describe '#delivery_required?' do
    let(:product1) { create(:product, name: 'Product 1') }
    let(:product2) { create(:product, name: 'Product 2') }

    let(:line_item1) { create(:line_item, variant: product1.master) }
    let(:line_item2) { create(:line_item, variant: product2.master) }

    let(:order) { create(:order, line_items: [line_item1, line_item2]) }

    context 'when some line items required delivery' do
      it 'return true' do
        allow(order.line_items[0]).to receive(:delivery_required?).and_return(true)
        allow(order.line_items[1]).to receive(:delivery_required?).and_return(false)

        expect(order.delivery_required?).to be true
      end
    end

    context 'when all line items required delivery' do
      it 'return true' do
        allow(order.line_items[0]).to receive(:delivery_required?).and_return(true)
        allow(order.line_items[1]).to receive(:delivery_required?).and_return(true)

        expect(order.delivery_required?).to be true
      end
    end

    context 'when none of line items required delivery' do
      it 'return false' do
        allow(order.line_items[0]).to receive(:delivery_required?).and_return(false)
        allow(order.line_items[1]).to receive(:delivery_required?).and_return(false)

        expect(order.delivery_required?).to be false
      end
    end
  end

  context 'callbacks' do
    describe 'before_save :sanitize_phone_number' do
      before(:each) do
        Phonelib.default_country = "KH"
      end

      it 'construct phone number before save' do
        order = build(:order, phone_number: '096 4103 875')

        expect(order.phone_number).to eq '096 4103 875'
        expect(order.intel_phone_number).to eq nil
        expect(order.country_code).to eq nil

        order.save!
        order.reload

        expect(order.phone_number).to eq '0964103875'
        expect(order.intel_phone_number).to eq '+855964103875'
        expect(order.country_code).to eq 'KH'
      end
    end
  end

  describe "#payment_required?" do
    let(:order) { build(:order) }

    it "not required payment when need_confirmation?" do
      allow(order).to receive(:need_confirmation?).and_return(true)

      expect(order.payment_required?).to be false
    end
  end

  describe "#accepted_by" do
    let(:order) { create(:order_with_line_items, state: :complete, request_state: :requested) }
    let(:user) { create(:user) }

    it "transition request state to :accepted and accept all line item" do
      order.accepted_by(user)
      order.reload

      expect(order.request_state).to eq "accepted"
      expect(order.line_items.map(&:accepted?)).to eq [true]
    end
  end

  describe "#confirmation_delivered?" do
    let(:order) { build(:order) }

    it "return true if confirmation_delivered column is true" do
      allow(order).to receive(:confirmation_delivered).and_return(true)

      expect(order.confirmation_delivered?).to be true
    end

    it "return true if order.need_confirmation? is true" do
      allow(order).to receive(:need_confirmation?).and_return(true)

      expect(order.confirmation_delivered?).to be true
    end

    it "return false neither order.need_confirmation? or confirmation_delivered true" do
      allow(order).to receive(:need_confirmation?).and_return(false)
      allow(order).to receive(:confirmation_delivered).and_return(false)

      expect(order.confirmation_delivered?).to be false
    end
  end

  context 'when update payment state to :paid' do
    let(:order) { create(:order_with_line_items, state: :address) }

    it 'trigger notify_order_complete_app_notification_to_user when order is complete and paid' do

      order.payment_state = 'paid'

      expect(order).to receive(:notify_order_complete_app_notification_to_user)

      order.save!
    end
  end

  context 'when update state to :complete' do
    let(:order) { create(:order_with_line_items, state: :address) }

    # make sure order can transition from cart to complete
    before do
      allow(order).to receive(:delivery_required?).and_return(false)
      allow(order).to receive(:payment_required?).and_return(false)
      allow(order).to receive(:confirmation_required?).and_return(false)
    end

    it "calls request when order need_confirmation?" do
      allow(order).to receive(:need_confirmation?).and_return(true)
      allow(order).to receive(:request).and_return(true)

      order.next!

      expect(order).to have_received(:request)
    end

    it "trigger send_order_complete_telegram_alert_to_vendors when not need confirmation" do
      allow(order).to receive(:need_confirmation?).and_return(false)
      allow(order).to receive(:send_order_complete_telegram_alert_to_vendors).and_return(true)

      order.next!

      expect(order).to have_received(:send_order_complete_telegram_alert_to_vendors)
    end

    it "trigger send_order_complete_telegram_alert_to_store when not need confirmation" do
      allow(order).to receive(:need_confirmation?).and_return(false)
      allow(order).to receive(:send_order_complete_telegram_alert_to_store).and_return(true)

      order.next!

      expect(order).to have_received(:send_order_complete_telegram_alert_to_store)
    end
  end

  context 'when transition to request_state :accepted' do
    let!(:order) { create(:order, state: :address, request_state: :requested) }
    let!(:line_item) { create(:cm_need_confirmation_line_item, order: order) }

    it "calls deliver_order_confirmation_email if confirmation_delivered is false" do
      allow(order).to receive(:confirmation_delivered).and_return(true)
      allow(order).to receive(:deliver_order_confirmation_email).and_return(true)

      order.accept!

      expect(order).to have_received(:deliver_order_confirmation_email)
    end

    it "not call deliver_order_confirmation_email if confirmation_delivered is true" do
      allow(order).to receive(:confirmation_delivered).and_return(false)
      allow(order).to receive(:deliver_order_confirmation_email).and_return(true)

      order.accept!

      expect(order).not_to have_received(:deliver_order_confirmation_email)
    end
  end

  describe '#state_changes' do
    let!(:order) { create(:order, state: :address, request_state: :requested, state_changes: []) }

    it 'create a state change on request_state transition' do
      order.accept!

      expect(order.reload.state_changes.size).to eq 1
      expect(order.reload.state_changes.first.name).to eq "request"
      expect(order.reload.state_changes.first.previous_state).to eq "requested"
      expect(order.reload.state_changes.first.next_state).to eq "accepted"
    end
  end

  describe '.search_by_qr_data!' do
    let(:number) { 'R4348234995' }
    let(:token) { 'd9CgNOEWLD-hrGQZduLy6Q1693558578189' }
    let!(:order) { create(:order, number: number, token: token) }

    context 'when the qr_data is invalid format' do
      it 'raises ActiveRecord::RecordNotFound' do
        qr_data = "4348234995-#{token}"

        expect do
          Spree::Order.search_by_qr_data!(qr_data)
        end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Spree::Order with QR data: #{qr_data}")
      end
    end

    context 'when the record is not found' do
      it 'raises ActiveRecord::RecordNotFound' do
        qr_data = "#{number}-T#{token}"

        expect do
          Spree::Order.search_by_qr_data!(qr_data)
        end.to raise_error(ActiveRecord::RecordNotFound, 'Couldn\'t find Spree::Order with [WHERE "spree_orders"."token" = $1]')
      end
    end

    context 'when the record is found' do
      it 'returns the record' do
        found_record = Spree::Order.search_by_qr_data!("#{number}-#{token}")
        expect(found_record).to eq(order)
      end
    end
  end

  describe '#valid_promotion_ids' do
    let!(:order) { create(:order, total: 100) }
    let!(:promotion) { create(:promotion, :with_order_adjustment) }
    let!(:adjustment) do
      adjustment = create(:adjustment, adjustable: order, order: order, source: promotion.actions.first)
      adjustment.update_column(:amount, 10)
      adjustment
    end

    it 'return valid_promotion_ids' do
      order.reload

      expect(order.valid_promotion_ids).to eq [promotion.id]
    end

    it 'return empty valid_promotion_ids when promotion is deleted' do
      promotion.destroy
      order.reload

      expect(order.adjustments.size).to eq 0
      expect(order.valid_promotion_ids).to eq []
    end

    it 'return empty valid_promotion_ids when promotion action is deleted' do
      promotion.actions.destroy_all
      order.reload

      expect(order.adjustments.size).to eq 0
      expect(order.valid_promotion_ids).to eq []
    end

    # still has adjustment, but no source
    it 'return empty valid_promotion_ids when adjustment source is nil' do
      adjustment.update_column(:source_id, nil)

      order.reload

      expect(order.adjustments.size).to eq 1
      expect(order.valid_promotion_ids).to eq []
    end
  end

  describe '#associate_user' do
    let!(:order) { create(:order) }
    let(:user_with_phone_number) { create(:user , phone_number: '012290564') }
    let(:user_with_email) { create(:user , email: 'panhachom@gmail.com') }

    it 'save user phone_number to order if exist' do
      order.associate_user!(user_with_phone_number)
      expect(order.reload.phone_number).to eq user_with_phone_number.phone_number
    end

    it 'not save user phone_number to order if not exist' do
      order.associate_user!(user_with_email)
      expect(order.reload.phone_number).to eq nil
    end
  end
end
