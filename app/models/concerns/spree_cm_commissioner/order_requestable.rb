module SpreeCmCommissioner
  module OrderRequestable
    extend ActiveSupport::Concern

    included do
      scope :accepted, -> { where(request_state: 'accepted') }

      # use after_update instead of after_transition
      # since it has usecase that order state is forced to update which not fire after_transition

      after_update :notify_order_complete_app_notification_to_user, if: -> { payment_state_changed_to_paid? }
      after_update :request, if: -> { state_changed_to_complete? && need_confirmation? }
      after_update :send_order_complete_telegram_alert_to_vendors, if: -> { state_changed_to_complete? && !need_confirmation? }
      after_update :send_order_complete_telegram_alert_to_store, if: -> { state_changed_to_complete? && !need_confirmation? }

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

    def payment_state_changed_to_paid?
      saved_change_to_payment_state? && payment_state == 'paid'
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
