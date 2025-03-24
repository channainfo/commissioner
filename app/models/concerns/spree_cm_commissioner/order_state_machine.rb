# Make sure to put this concern below other concern or methods that generating additional order info like guests, seat number, etc.
# This will ensure that when each notification is sent with neccessary data.
module SpreeCmCommissioner
  module OrderStateMachine
    extend ActiveSupport::Concern

    included do
      state_machine.before_transition to: :complete, do: :request, if: :need_confirmation?
      state_machine.before_transition to: :complete, do: :generate_bib_number

      state_machine.after_transition to: :complete, do: :precalculate_conversion
      state_machine.after_transition to: :complete, do: :notify_order_complete_app_notification_to_user, unless: :subscription?
      state_machine.after_transition to: :complete, do: :notify_order_complete_telegram_notification_to_user, unless: :subscription?
      state_machine.after_transition to: :complete, do: :send_order_complete_telegram_alert_to_vendors, unless: :need_confirmation?
      state_machine.after_transition to: :complete, do: :send_order_complete_telegram_alert_to_store, unless: :need_confirmation?

      state_machine.after_transition to: :resumed, do: :precalculate_conversion

      # TODO: should test when resumed on order having booking date < Time.now
      state_machine.after_transition to: :resumed, do: :unstock_inventory_in_redis!

      state_machine.after_transition to: :canceled, do: :precalculate_conversion
      state_machine.after_transition to: :canceled, do: :restock_inventory_in_redis!

      # after transition to :complete, finalize! has been called
      # we call unstock_inventory_in_redis! in the finalize! method
      # So if unstock not success, then the state should be rollback
      # So Spree::Checkout::Complete will get failure and rollback payment in vPago
      state_machine.around_transition to: :complete do |transition, block|
        ActiveRecord::Base.transaction do
          block.call # Executes the transition, including state change and callbacks
        end
      end

      scope :accepted, -> { where(request_state: 'accepted') }

      scope :filter_by_request_state, lambda {
        where(state: :complete)
          .where.not(request_state: nil)
          .where.not(payment_state: :paid)
          .order(created_at: :desc)
      }

      state_machine :request_state, initial: nil, use_transactions: false do
        event :request do
          transition from: nil, to: :requested
        end
        after_transition to: :requested, do: :send_order_requested_app_notification_to_user
        after_transition to: :requested, do: :send_order_requested_telegram_alert_to_store

        event :accept do
          transition from: :requested, to: :accepted
        end
        after_transition to: :accepted, do: :send_order_accepted_app_notification_to_user
        after_transition to: :accepted, do: :send_order_accepted_telegram_alert_to_store

        # call confirmation_delivered column directly since confirmation_delivered? is overrided
        after_transition to: :accepted, if: :confirmation_delivered, do: :deliver_order_confirmation_email

        event :reject do
          transition from: :requested, to: :rejected
        end

        after_transition to: :rejected, do: :send_order_rejected_app_notification_to_user
        after_transition to: :rejected, do: :send_order_rejected_telegram_alert_to_store

        after_transition do |order, transition|
          order.log_state_changes(
            old_state: transition.from,
            new_state: transition.to,
            state_name: :request
          )
        end
      end
    end

    def precalculate_conversion
      line_items.each do |item|
        SpreeCmCommissioner::ConversionPreCalculatorJob.perform_later(item.product_id)
      end
    end

    def generate_bib_number
      line_items.find_each(&:generate_remaining_guests)

      line_items.with_bib_prefix.each do |line_item|
        line_item.guests.none_bib.each do |guest|
          guest.generate_bib
          next if guest.save

          guest.errors.each do |msg|
            errors.add(:guests, msg)
          end
        end
      end

      errors.empty?
    end

    def rejected_by(user)
      transaction do
        reject!

        line_items.each do |line_item|
          line_item.rejected_by(user)
        end
      end
    end

    # allow authorized user to accept all requested line items
    def accepted_by(user)
      transaction do
        accept!

        line_items.each do |line_item|
          line_item.accepted_by(user)
        end
      end
    end

    # overrided not to send email yet to user if order needs confirmation
    # it will send after vendors accepted.
    def confirmation_delivered?
      confirmation_delivered || need_confirmation?
    end

    # can_accepted? already use by ransack/visitor.rb
    def can_accept_all?
      approved? && requested?
    end

    def can_reject_all?
      approved? && requested?
    end

    def can_alert_request_to_vendor?
      !accepted? && approved? && need_confirmation?
    end

    def requested_state?
      request_state == 'requested'
    end

    def need_confirmation?
      line_items.any?(&:need_confirmation)
    end

    def send_order_request_telegram_confirmation_alert_to_vendor; end

    def send_order_complete_telegram_alert_to_vendors
      vendor_list.each do |vendor|
        title = '🎫 --- [NEW ORDER FROM BOOKME+] ---'
        chat_id = vendor.preferred_telegram_chat_id
        if chat_id.present?
          factory = OrderTelegramMessageFactory.new(title: title, order: self, vendor: vendor)
          TelegramNotificationSenderJob.perform_later(chat_id: chat_id, message: factory.message, parse_mode: factory.parse_mode)
        end
      end
    end

    def notify_order_complete_app_notification_to_user
      SpreeCmCommissioner::OrderCompleteNotificationSender.call(order: self)
    end

    def notify_order_complete_telegram_notification_to_user
      SpreeCmCommissioner::OrderCompleteTelegramSenderJob.perform_later(id) if user_id.present?
    end

    def send_order_requested_app_notification_to_user
      SpreeCmCommissioner::OrderRequestedNotificationSender.call(order: self)
    end

    def send_order_accepted_app_notification_to_user
      SpreeCmCommissioner::OrderAcceptedNotificationSender.call(order: self)
    end

    def send_order_rejected_app_notification_to_user
      SpreeCmCommissioner::OrderRejectedNotificationSender.call(order: self)
    end

    def send_order_requested_telegram_alert_to_store
      title = '🔔 --- [NEW REQUESTED BY USER] ---'
      chat_id = store.preferred_telegram_order_request_alert_chat_id
      factory = OrderTelegramMessageFactory.new(title: title, order: self)
      TelegramNotificationSenderJob.perform_later(chat_id: chat_id, message: factory.message, parse_mode: factory.parse_mode)
    end

    def send_order_accepted_telegram_alert_to_store
      title = '✅ --- [ORDER ACCEPTED BY VENDOR] ---'
      chat_id = store.preferred_telegram_order_request_alert_chat_id
      factory = OrderTelegramMessageFactory.new(title: title, order: self)
      TelegramNotificationSenderJob.perform_later(chat_id: chat_id, message: factory.message, parse_mode: factory.parse_mode)
    end

    def send_order_rejected_telegram_alert_to_store
      title = '❌ --- [ORDER REJECTED BY VENDOR] ---'
      chat_id = store.preferred_telegram_order_request_alert_chat_id
      factory = OrderTelegramMessageFactory.new(title: title, order: self)
      TelegramNotificationSenderJob.perform_later(chat_id: chat_id, message: factory.message, parse_mode: factory.parse_mode)
    end

    def send_order_complete_telegram_alert_to_store
      title = '🎫 --- [NEW ORDER] ---'
      chat_id = store.preferred_telegram_order_alert_chat_id
      factory = OrderTelegramMessageFactory.new(title: title, order: self)
      TelegramNotificationSenderJob.perform_later(chat_id: chat_id, message: factory.message, parse_mode: factory.parse_mode)
    end
  end
end
