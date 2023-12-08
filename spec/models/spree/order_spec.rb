require 'spec_helper'

RSpec.describe Spree::Order, type: :model do
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
  end

  describe 'paid' do
    let!(:order1) { create(:order, payment_state: :paid) }
    let!(:order2) { create(:order, payment_state: :void) }

    it 'it only return paid order' do
      expect(described_class.paid.size).to eq 1
      expect(described_class.paid.first).to eq order1
    end
  end

  describe '#delivery_required?' do
    let(:product1) { create(:product, name: 'Product 1') }
    let(:product2) { create(:product, name: 'Product 2') }

    let(:line_item1) { create(:line_item, variant: product1.master) }
    let(:line_item2) { create(:line_item, variant: product2.master) }

    let(:order) { create(:order, line_items: [line_item1, line_item2]) }

    context 'required delivery' do
      it 'required delivery when all products are :ecommerce & not digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :ecommerce)

        allow(order.line_items[0]).to receive(:digital?).and_return(false)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq true
      end

      it 'required delivery when some of products are :ecommerce & not digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :service)

        allow(order.line_items[0]).to receive(:digital?).and_return(false)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq true
      end
    end

    context 'not required delivery' do
      it 'not required delivery when products are not :ecommerce (digital? are ignored this case)' do
        order.line_items[0].product.update_columns(product_type: :accommodation)
        order.line_items[1].product.update_columns(product_type: :service)

        expect(order.delivery_required?).to eq false
      end

      it 'not required delivery when some of products are :ecommerce & it is digital' do
        order.line_items[0].product.update_columns(product_type: :ecommerce)
        order.line_items[1].product.update_columns(product_type: :service)

        allow(order.line_items[0]).to receive(:digital?).and_return(true)
        allow(order.line_items[1]).to receive(:digital?).and_return(false)

        expect(order.delivery_required?).to eq false
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

  describe '#FlatPercentItemTotal' do
    let(:calculator) { Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: 50) }
    let!(:promotion) { create(:promotion_with_order_adjustment, starts_at: Date.today - 1.day, expires_at: Date.today + 5.day, match_policy: "any")}
    let!(:order) { create(:order_with_totals, line_items_price: 30, total: 30, item_total: 30) }
    let!(:promotion_action) { Spree::Promotion::Actions::CreateAdjustment.create!(promotion: promotion, calculator: calculator) }
    let!(:order_promotion) { create(:order_promotion, order: order, promotion: promotion)}
    let!(:order_adjustment) { create(:adjustment, order: order, source: promotion_action, adjustable: order)}

    context 'when order has a promotion with a cap' do
      before do
        calculator.update(cap: 20)
      end

      it 'does not adjust promotion order adjustment if within the cap' do
        order.update_with_updater!
        order.reload

        expect(order.item_total.to_f).to eq(30.0)
        expect(order.total.to_f).to eq(15.0)
        expect(order.adjustment_total.to_f).to eq(-15.0)
      end

      it 'adjusts promotion order adjustment to cap if exceeded' do
        create(:line_item, order: order, price: 100)
        order.reload.update_with_updater!
        order.reload

        expect(order.item_total.to_f).to eq(130.0)
        expect(order.total.to_f).to eq(110.0)
        expect(order.adjustment_total.to_f).to eq(-20.0)
      end
    end

    context 'when order has a promotion without a cap' do
      it 'adjust promotion order adjustment' do
        order.reload.update_with_updater!

        expect(order.item_total.to_f).to eq(30.0)
        expect(order.total.to_f).to eq(15.0)
        expect(order.adjustment_total.to_f).to eq(-15.0)
      end

      it 'adjusts promotion order adjustment 50%' do
        create(:line_item, order: order, price: 100)

        order.reload.update_with_updater!
        order.update_totals

        expect(order.item_total.to_f).to eq(130.0)
        expect(order.total.to_f).to eq(65.0)
        expect(order.adjustment_total.to_f).to eq(-65.0)
      end
    end
  end

  describe '#PercentOnLineItem' do
    let(:calculator) { Spree::Calculator::PercentOnLineItem.create(preferred_percent: 20) }
    let!(:promotion) { create(:promotion_with_order_adjustment, starts_at: Date.today - 1.day, expires_at: Date.today + 5.day, match_policy: "any")}
    let!(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order: order, quantity: 2, price: 30.0)}
    let!(:promotion_action) { Spree::Promotion::Actions::CreateItemAdjustments.create!(promotion: promotion, calculator: calculator) }
    let!(:order_promotion) { create(:order_promotion, order: order, promotion: promotion)}
    let!(:order_adjustment) { create(:adjustment, order: order, source: promotion_action, adjustable: line_item)}

    context 'when order has a promotion with a cap' do
      before do
        calculator.update(cap: 20)
      end

      it 'does not adjust promotion line item if within the cap' do
        order.update_with_updater!
        order.reload

        expect(order.item_total.to_f).to eq(60.0)
        expect(order.total.to_f).to eq(48.0)
        expect(order.adjustment_total.to_f).to eq(-12.0)
      end

      it 'adjusts promotion line item to cap if exceeded' do
        line_item2 = create(:line_item, order: order, quantity: 2, price: 60)
        create(:adjustment, order: order, source: promotion_action, adjustable: line_item2)
        order.reload.update_with_updater!
        order.reload

        # line_item1 discount 60x0.2 = 12 < cap 20, line_item2 discount 120x0.2 = 24 > cap 20
        expect(order.item_total.to_f).to eq(180.0)
        expect(order.total.to_f).to eq(148.0)
        expect(order.adjustment_total.to_f).to eq(-32.0)
      end
    end

    context 'when order has a promotion without a cap' do
      it 'adjust promotion line item adjustment' do
        order.reload.update_with_updater!

        expect(order.item_total.to_f).to eq(60.0)
        expect(order.total.to_f).to eq(48.0)
        expect(order.adjustment_total.to_f).to eq(-12.0)
      end

      it 'adjusts promotion line item adjustment 20% ' do
        line_item2 = create(:line_item, order: order, quantity: 2, price: 60)
        create(:adjustment, order: order, source: promotion_action, adjustable: line_item2)

        order.reload.update_with_updater!
        order.update_totals

        # line_item1 discount 60x0.2 = 12 , line_item2 discount 120x0.2 = 24
        expect(order.item_total.to_f).to eq(180.0)
        expect(order.total.to_f).to eq(144.0)
        expect(order.adjustment_total.to_f).to eq(-36.0)
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
end
