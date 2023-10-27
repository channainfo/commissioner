require 'spec_helper'

RSpec.describe SpreeCmCommissioner::Notification, type: :model do

  describe "request_notifications" do
    it "return the latest notification if records have the same notification_id" do
      notification1 = create(:notification,
         type: 'order_requested_notification',
         read_at: nil,
         notificable_id: 1,
         notificable_type: 'Spree::Order'
      )
      notification2 = create(:notification,
        type: 'order_rejected_notification',
        read_at: nil,
        notificable_id: 1,
        notificable_type: 'Spree::Order'
      )

      notifications = SpreeCmCommissioner::Notification.request_notifications

      expect(notifications).to contain_exactly(notification2)
    end
  end
end
